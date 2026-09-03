import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/auth_session_repository.dart';
import '../interfaces/identity_repository.dart';
import '../interfaces/otp_rate_limiter.dart';
import '../interfaces/password_credential_repository.dart';
import '../interfaces/password_hasher.dart';
import '../interfaces/password_policy.dart';
import '../interfaces/password_reset_code_repository.dart';
import '../interfaces/password_reset_sender.dart';
import '../interfaces/secret_hasher.dart';
import '../interfaces/verification_code_generator.dart';
import 'auth_audit.dart';

class PasswordResetService {
  const PasswordResetService({
    required IdentityRepository identityRepository,
    required PasswordCredentialRepository passwordCredentialRepository,
    required AuthSessionRepository authSessionRepository,
    required PasswordResetCodeRepository codeRepository,
    required SecretHasher codeHasher,
    required VerificationCodeGenerator codeGenerator,
    required PasswordResetSender sender,
    required PasswordHasher passwordHasher,
    required PasswordPolicy passwordPolicy,
    required OtpRateLimiter startRateLimiter,
    this.codeLifetime = const Duration(minutes: 15),
    this.maxFailedAttempts = 5,
  }) : _identityRepository = identityRepository,
       _passwordCredentialRepository = passwordCredentialRepository,
       _authSessionRepository = authSessionRepository,
       _codeRepository = codeRepository,
       _codeHasher = codeHasher,
       _codeGenerator = codeGenerator,
       _sender = sender,
       _passwordHasher = passwordHasher,
       _passwordPolicy = passwordPolicy,
       _startRateLimiter = startRateLimiter;

  static const startAction = 'password_reset_start';

  final IdentityRepository _identityRepository;
  final PasswordCredentialRepository _passwordCredentialRepository;
  final AuthSessionRepository _authSessionRepository;
  final PasswordResetCodeRepository _codeRepository;
  final SecretHasher _codeHasher;
  final VerificationCodeGenerator _codeGenerator;
  final PasswordResetSender _sender;
  final PasswordHasher _passwordHasher;
  final PasswordPolicy _passwordPolicy;
  final OtpRateLimiter _startRateLimiter;
  final Duration codeLifetime;
  final int maxFailedAttempts;

  Future<void> start(
    Session session, {
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final isBlocked = await _startRateLimiter.isBlocked(
      session,
      action: startAction,
      subject: normalizedEmail,
    );
    if (isBlocked) {
      AuthAudit.log(
        session,
        event: 'password_reset_start',
        outcome: 'blocked',
        reasonCode: AuthUseCaseExceptionCode.tooManyAttempts.name,
        subject: normalizedEmail,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.tooManyAttempts,
      );
    }

    await _startRateLimiter.registerAttempt(
      session,
      action: startAction,
      subject: normalizedEmail,
    );

    final identity = await _identityRepository.findByEmail(
      session,
      normalizedEmail,
    );
    if (identity == null || identity.status != protocol.IdentityStatus.active) {
      AuthAudit.log(
        session,
        event: 'password_reset_start',
        outcome: 'accepted',
        reasonCode: 'identity_not_eligible',
        subject: normalizedEmail,
      );
      return;
    }

    final identityId = identity.id;
    if (identityId == null) return;

    final code = _codeGenerator.generate();
    final codeHash = await _codeHasher.hashSecret(code);

    await _codeRepository.revokeActiveForIdentity(session, identityId);
    await _codeRepository.create(
      session,
      identityId: identityId,
      email: normalizedEmail,
      codeHash: codeHash,
      expiresAt: DateTime.now().toUtc().add(codeLifetime),
    );
    await _sender.sendResetCode(session, email: normalizedEmail, code: code);
    AuthAudit.log(
      session,
      event: 'password_reset_start',
      outcome: 'success',
      identityId: identityId,
      subject: normalizedEmail,
    );
  }

  Future<void> finish(
    Session session, {
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final identity = await _identityRepository.findByEmail(
      session,
      normalizedEmail,
    );
    if (identity == null) {
      AuthAudit.log(
        session,
        event: 'password_reset_finish',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidPasswordResetCode.name,
        subject: normalizedEmail,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidPasswordResetCode,
      );
    }
    if (identity.status != protocol.IdentityStatus.active) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotActive,
      );
    }

    final credential = await _passwordCredentialRepository.findByIdentityId(
      session,
      identity.id!,
    );
    if (credential == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotFound,
      );
    }

    _passwordPolicy.validate(
      password: newPassword,
      username: credential.username,
      email: normalizedEmail,
    );

    final resetCode = await _codeRepository.findActiveByIdentityId(
      session,
      identity.id!,
    );
    if (resetCode == null || resetCode.failedAttempts >= maxFailedAttempts) {
      AuthAudit.log(
        session,
        event: 'password_reset_finish',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidPasswordResetCode.name,
        identityId: identity.id,
        subject: normalizedEmail,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidPasswordResetCode,
      );
    }

    final codeIsValid = await _codeHasher.verifySecret(
      secret: code,
      secretHash: resetCode.codeHash,
    );
    if (!codeIsValid) {
      await _codeRepository.registerFailedAttempt(session, resetCode.id!);
      AuthAudit.log(
        session,
        event: 'password_reset_finish',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidPasswordResetCode.name,
        identityId: identity.id,
        subject: normalizedEmail,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidPasswordResetCode,
      );
    }

    final passwordHash = await _passwordHasher.hashPassword(newPassword);
    await _passwordCredentialRepository.updatePasswordHash(
      session,
      id: credential.id!,
      passwordHash: passwordHash,
    );
    await _codeRepository.markConsumed(session, resetCode.id!);
    await _authSessionRepository.revokeAllForIdentity(session, identity.id!);
    AuthAudit.log(
      session,
      event: 'password_reset_finish',
      outcome: 'success',
      identityId: identity.id,
      subject: normalizedEmail,
    );
  }
}
