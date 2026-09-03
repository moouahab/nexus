import 'package:serverpod/serverpod.dart';

import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/auth_session_repository.dart';
import '../interfaces/password_credential_repository.dart';
import '../interfaces/password_hasher.dart';
import '../interfaces/password_policy.dart';
import '../services/auth_audit.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase({
    required PasswordCredentialRepository passwordCredentialRepository,
    required AuthSessionRepository authSessionRepository,
    required PasswordHasher passwordHasher,
    required PasswordPolicy passwordPolicy,
  }) : _passwordCredentialRepository = passwordCredentialRepository,
       _authSessionRepository = authSessionRepository,
       _passwordHasher = passwordHasher,
       _passwordPolicy = passwordPolicy;

  final PasswordCredentialRepository _passwordCredentialRepository;
  final AuthSessionRepository _authSessionRepository;
  final PasswordHasher _passwordHasher;
  final PasswordPolicy _passwordPolicy;

  Future<void> execute(
    Session session, {
    required UuidValue identityId,
    required String currentPassword,
    required String newPassword,
    String? email,
  }) async {
    final credential = await _passwordCredentialRepository.findByIdentityId(
      session,
      identityId,
    );
    if (credential == null) {
      AuthAudit.log(
        session,
        event: 'password_change',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidCredentials.name,
        identityId: identityId,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }

    final currentPasswordIsValid = await _passwordHasher.verifyPassword(
      password: currentPassword,
      passwordHash: credential.passwordHash,
    );
    if (!currentPasswordIsValid) {
      AuthAudit.log(
        session,
        event: 'password_change',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidCredentials.name,
        identityId: identityId,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCredentials,
      );
    }

    _passwordPolicy.validate(
      password: newPassword,
      username: credential.username,
      email: email,
    );

    final passwordHash = await _passwordHasher.hashPassword(newPassword);
    await _passwordCredentialRepository.updatePasswordHash(
      session,
      id: credential.id!,
      passwordHash: passwordHash,
    );
    await _authSessionRepository.revokeAllForIdentity(session, identityId);
    AuthAudit.log(
      session,
      event: 'password_change',
      outcome: 'success',
      identityId: identityId,
    );
  }
}
