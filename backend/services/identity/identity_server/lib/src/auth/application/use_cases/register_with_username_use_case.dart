import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../domain/auth_result.dart';
import '../../domain/auth_token_transport.dart';
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/email_policy.dart';
import '../interfaces/identity_provider_repository.dart';
import '../interfaces/identity_repository.dart';
import '../interfaces/password_credential_repository.dart';
import '../interfaces/password_hasher.dart';
import '../interfaces/password_policy.dart';
import '../interfaces/username_policy.dart';
import '../services/auth_audit.dart';
import '../services/auth_token_issuer.dart';
import '../services/email_verification_service.dart';

class RegisterWithUsernameUseCase {
  const RegisterWithUsernameUseCase({
    required IdentityRepository identityRepository,
    required IdentityProviderRepository identityProviderRepository,
    required PasswordCredentialRepository passwordCredentialRepository,
    required UsernamePolicy usernamePolicy,
    required EmailPolicy emailPolicy,
    required PasswordHasher passwordHasher,
    required PasswordPolicy passwordPolicy,
    required AuthTokenIssuer authTokenIssuer,
    required EmailVerificationService emailVerificationService,
  }) : _identityRepository = identityRepository,
       _identityProviderRepository = identityProviderRepository,
       _passwordCredentialRepository = passwordCredentialRepository,
       _usernamePolicy = usernamePolicy,
       _emailPolicy = emailPolicy,
       _passwordHasher = passwordHasher,
       _passwordPolicy = passwordPolicy,
       _authTokenIssuer = authTokenIssuer,
       _emailVerificationService = emailVerificationService;

  final IdentityRepository _identityRepository;
  final IdentityProviderRepository _identityProviderRepository;
  final PasswordCredentialRepository _passwordCredentialRepository;
  final UsernamePolicy _usernamePolicy;
  final EmailPolicy _emailPolicy;
  final PasswordHasher _passwordHasher;
  final PasswordPolicy _passwordPolicy;
  final AuthTokenIssuer _authTokenIssuer;
  final EmailVerificationService _emailVerificationService;

  Future<AuthResult> execute(
    Session session, {
    required String username,
    required String password,
    String? email,
    AuthTokenTransport tokenTransport = AuthTokenTransport.cookie,
  }) async {
    final normalizedUsername = _normalizeRequired(username);
    final normalizedEmail = _normalizeOptional(email);

    try {
      _usernamePolicy.validate(normalizedUsername);
      _emailPolicy.validate(normalizedEmail);
      _passwordPolicy.validate(
        password: password,
        username: normalizedUsername,
        email: normalizedEmail,
      );
    } on AuthUseCaseException catch (exception) {
      AuthAudit.log(
        session,
        event: 'register',
        outcome: 'blocked',
        reasonCode: exception.code.name,
        tokenTransport: tokenTransport.name,
        subject: normalizedEmail ?? normalizedUsername,
      );
      rethrow;
    }

    await _ensureUsernameAvailable(session, normalizedUsername);
    await _ensureEmailAvailable(session, normalizedEmail);

    final identity = await _identityRepository.create(
      session,
      username: normalizedUsername,
      email: normalizedEmail,
      emailVerified: false,
      status: protocol.IdentityStatus.active,
    );

    final identityId = identity.id;
    if (identityId == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.missingGeneratedId,
      );
    }

    final passwordHash = await _passwordHasher.hashPassword(password);
    await _passwordCredentialRepository.create(
      session,
      identityId: identityId,
      username: normalizedUsername,
      passwordHash: passwordHash,
    );

    await _identityProviderRepository.create(
      session,
      identityId: identityId,
      provider: protocol.AuthProvider.username,
      providerUserId: normalizedUsername,
      email: normalizedEmail,
      emailVerified: false,
    );

    await _emailVerificationService.start(session, identity: identity);

    final result = await _authTokenIssuer.issue(
      session,
      identity: identity,
      authMethod: protocol.AuthProvider.username,
      tokenTransport: tokenTransport,
    );
    AuthAudit.log(
      session,
      event: 'register',
      outcome: 'success',
      identityId: identityId,
      authSessionId: result.authSessionId,
      provider: protocol.AuthProvider.username,
      tokenTransport: tokenTransport.name,
      subject: normalizedEmail ?? normalizedUsername,
    );
    return result;
  }

  Future<void> _ensureUsernameAvailable(
    Session session,
    String normalizedUsername,
  ) async {
    final existingCredential = await _passwordCredentialRepository
        .findByUsername(session, normalizedUsername);
    if (existingCredential != null) {
      AuthAudit.log(
        session,
        event: 'register',
        outcome: 'blocked',
        reasonCode: 'username_already_exists',
        subject: normalizedUsername,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.usernameAlreadyExists,
      );
    }
  }

  Future<void> _ensureEmailAvailable(
    Session session,
    String? normalizedEmail,
  ) async {
    if (normalizedEmail == null) return;

    final existingIdentity = await _identityRepository.findByEmail(
      session,
      normalizedEmail,
    );
    if (existingIdentity != null) {
      AuthAudit.log(
        session,
        event: 'register',
        outcome: 'blocked',
        reasonCode: 'email_already_exists',
        subject: normalizedEmail,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.emailAlreadyExists,
      );
    }
  }

  String _normalizeRequired(String value) {
    return value.trim().toLowerCase();
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
