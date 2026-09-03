import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../domain/auth_result.dart';
import '../../domain/auth_token_transport.dart';
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/identity_repository.dart';
import '../interfaces/login_attempt_limiter.dart';
import '../interfaces/password_credential_repository.dart';
import '../interfaces/password_hasher.dart';
import '../services/auth_audit.dart';
import '../services/auth_token_issuer.dart';
import '../validation/termination_rule.dart';

class LoginWithUsernameUseCase {
  const LoginWithUsernameUseCase({
    required IdentityRepository identityRepository,
    required PasswordCredentialRepository passwordCredentialRepository,
    required PasswordHasher passwordHasher,
    required LoginAttemptLimiter loginAttemptLimiter,
    required AuthTokenIssuer authTokenIssuer,
  }) : _identityRepository = identityRepository,
       _passwordCredentialRepository = passwordCredentialRepository,
       _passwordHasher = passwordHasher,
       _loginAttemptLimiter = loginAttemptLimiter,
       _authTokenIssuer = authTokenIssuer;

  final IdentityRepository _identityRepository;
  final PasswordCredentialRepository _passwordCredentialRepository;
  final PasswordHasher _passwordHasher;
  final LoginAttemptLimiter _loginAttemptLimiter;
  final AuthTokenIssuer _authTokenIssuer;

  Future<AuthResult> execute(
    Session session, {
    required String username,
    required String password,
    AuthTokenTransport tokenTransport = AuthTokenTransport.cookie,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    final isBlocked = await _loginAttemptLimiter.isBlocked(
      session,
      username: normalizedUsername,
    );
    if (isBlocked) {
      AuthAudit.log(
        session,
        event: 'login',
        outcome: 'blocked',
        reasonCode: AuthUseCaseExceptionCode.tooManyAttempts.name,
        subject: normalizedUsername,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.tooManyAttempts,
      );
    }

    final credential = await _passwordCredentialRepository.findByUsername(
      session,
      normalizedUsername,
    );

    if (credential == null) {
      await _registerFailedAttempt(session, normalizedUsername);
      AuthAudit.log(
        session,
        event: 'login',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidCredentials.name,
        subject: normalizedUsername,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }

    final passwordIsValid = await _passwordHasher.verifyPassword(
      password: password,
      passwordHash: credential.passwordHash,
    );
    if (!passwordIsValid) {
      await _registerFailedAttempt(session, normalizedUsername);
      AuthAudit.log(
        session,
        event: 'login',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidCredentials.name,
        subject: normalizedUsername,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }

    final identity = await _identityRepository.findById(
      session,
      credential.identityId,
    );
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => identity == null,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.identityNotFound,
        ),
      ),
      TerminationRule(
        shouldTerminate: () =>
            identity?.status != protocol.IdentityStatus.active,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.identityNotActive,
        ),
      ),
    ]);

    await _loginAttemptLimiter.registerSuccessfulAttempt(
      session,
      username: normalizedUsername,
    );

    final result = await _authTokenIssuer.issue(
      session,
      identity: identity!,
      authMethod: protocol.AuthProvider.username,
      tokenTransport: tokenTransport,
    );
    AuthAudit.log(
      session,
      event: 'login',
      outcome: 'success',
      identityId: result.identityId,
      authSessionId: result.authSessionId,
      provider: protocol.AuthProvider.username.name,
      tokenTransport: tokenTransport.name,
      subject: normalizedUsername,
    );
    return result;
  }

  Future<void> _registerFailedAttempt(
    Session session,
    String normalizedUsername,
  ) {
    return _loginAttemptLimiter.registerFailedAttempt(
      session,
      username: normalizedUsername,
    );
  }
}
