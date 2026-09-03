import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/email_verification_code_repository.dart';
import '../interfaces/email_verification_sender.dart';
import '../interfaces/identity_repository.dart';
import '../interfaces/otp_rate_limiter.dart';
import '../interfaces/secret_hasher.dart';
import '../interfaces/verification_code_generator.dart';

class EmailVerificationService {
  const EmailVerificationService({
    required EmailVerificationCodeRepository codeRepository,
    required IdentityRepository identityRepository,
    required SecretHasher codeHasher,
    required VerificationCodeGenerator codeGenerator,
    required EmailVerificationSender sender,
    required OtpRateLimiter resendRateLimiter,
    this.codeLifetime = const Duration(minutes: 15),
    this.maxFailedAttempts = 5,
  }) : _codeRepository = codeRepository,
       _identityRepository = identityRepository,
       _codeHasher = codeHasher,
       _codeGenerator = codeGenerator,
       _sender = sender,
       _resendRateLimiter = resendRateLimiter;

  static const resendAction = 'email_verification_resend';

  final EmailVerificationCodeRepository _codeRepository;
  final IdentityRepository _identityRepository;
  final SecretHasher _codeHasher;
  final VerificationCodeGenerator _codeGenerator;
  final EmailVerificationSender _sender;
  final OtpRateLimiter _resendRateLimiter;
  final Duration codeLifetime;
  final int maxFailedAttempts;

  Future<void> start(
    Session session, {
    required protocol.Identity identity,
  }) async {
    final identityId = identity.id;
    final email = identity.email;
    if (identityId == null || email == null || email.isEmpty) return;
    if (identity.emailVerified) return;

    final code = _codeGenerator.generate();
    final codeHash = await _codeHasher.hashSecret(code);

    await _codeRepository.revokeActiveForIdentity(session, identityId);
    await _codeRepository.create(
      session,
      identityId: identityId,
      email: email,
      codeHash: codeHash,
      expiresAt: DateTime.now().toUtc().add(codeLifetime),
    );
    await _sender.sendVerificationCode(session, email: email, code: code);
  }

  Future<void> resend(
    Session session, {
    required UuidValue identityId,
  }) async {
    final identity = await _identityRepository.findById(session, identityId);
    if (identity == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotFound,
      );
    }
    if (identity.email == null || identity.email!.isEmpty) {
      throw const AuthUseCaseException(AuthUseCaseExceptionCode.missingEmail);
    }

    final email = identity.email!.trim().toLowerCase();
    final isBlocked = await _resendRateLimiter.isBlocked(
      session,
      action: resendAction,
      subject: email,
    );
    if (isBlocked) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.tooManyAttempts,
      );
    }

    await _resendRateLimiter.registerAttempt(
      session,
      action: resendAction,
      subject: email,
    );
    await start(session, identity: identity);
  }

  Future<protocol.Identity> verify(
    Session session, {
    required UuidValue identityId,
    required String code,
  }) async {
    final identity = await _identityRepository.findById(session, identityId);
    if (identity == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotFound,
      );
    }
    if (identity.email == null || identity.email!.isEmpty) {
      throw const AuthUseCaseException(AuthUseCaseExceptionCode.missingEmail);
    }
    if (identity.emailVerified) return identity;

    final verificationCode = await _codeRepository.findActiveByIdentityId(
      session,
      identityId,
    );
    if (verificationCode == null ||
        verificationCode.failedAttempts >= maxFailedAttempts) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidEmailVerificationCode,
      );
    }

    final isValid = await _codeHasher.verifySecret(
      secret: code,
      secretHash: verificationCode.codeHash,
    );
    if (!isValid) {
      await _codeRepository.registerFailedAttempt(
        session,
        verificationCode.id!,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidEmailVerificationCode,
      );
    }

    await _codeRepository.markConsumed(session, verificationCode.id!);
    final verifiedIdentity = await _identityRepository.markEmailVerified(
      session,
      identityId,
    );
    if (verifiedIdentity == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.identityNotFound,
      );
    }

    return verifiedIdentity;
  }
}
