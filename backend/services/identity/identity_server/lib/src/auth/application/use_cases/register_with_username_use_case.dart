import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../domain/auth_result.dart';
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/identity_provider_repository.dart';
import '../interfaces/identity_repository.dart';
import '../interfaces/password_credential_repository.dart';
import '../interfaces/password_hasher.dart';
import '../services/auth_token_issuer.dart';

class RegisterWithUsernameUseCase {
  const RegisterWithUsernameUseCase({
    required IdentityRepository identityRepository,
    required IdentityProviderRepository identityProviderRepository,
    required PasswordCredentialRepository passwordCredentialRepository,
    required PasswordHasher passwordHasher,
    required AuthTokenIssuer authTokenIssuer,
  }) : _identityRepository = identityRepository,
       _identityProviderRepository = identityProviderRepository,
       _passwordCredentialRepository = passwordCredentialRepository,
       _passwordHasher = passwordHasher,
       _authTokenIssuer = authTokenIssuer;

  final IdentityRepository _identityRepository;
  final IdentityProviderRepository _identityProviderRepository;
  final PasswordCredentialRepository _passwordCredentialRepository;
  final PasswordHasher _passwordHasher;
  final AuthTokenIssuer _authTokenIssuer;

  Future<AuthResult> execute(
    Session session, {
    required String username,
    required String password,
    String? email,
  }) async {
    final normalizedUsername = _normalizeRequired(username);
    final normalizedEmail = _normalizeOptional(email);

    await _ensureUsernameAvailable(session, normalizedUsername);

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

    return _authTokenIssuer.issue(
      session,
      identity: identity,
      authMethod: protocol.AuthProvider.username,
    );
  }

  Future<void> _ensureUsernameAvailable(
    Session session,
    String normalizedUsername,
  ) async {
    final existingCredential = await _passwordCredentialRepository
        .findByUsername(session, normalizedUsername);
    if (existingCredential != null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.usernameAlreadyExists,
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
