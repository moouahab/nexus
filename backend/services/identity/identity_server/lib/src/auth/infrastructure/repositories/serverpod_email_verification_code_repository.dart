import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/interfaces/email_verification_code_repository.dart';

class ServerpodEmailVerificationCodeRepository
    implements EmailVerificationCodeRepository {
  @override
  Future<protocol.EmailVerificationCode> create(
    Session session, {
    required UuidValue identityId,
    required String email,
    required String codeHash,
    required DateTime expiresAt,
  }) {
    return protocol.EmailVerificationCode.db.insertRow(
      session,
      protocol.EmailVerificationCode(
        identityId: identityId,
        email: email,
        codeHash: codeHash,
        expiresAt: expiresAt,
      ),
    );
  }

  @override
  Future<protocol.EmailVerificationCode?> findActiveByIdentityId(
    Session session,
    UuidValue identityId,
  ) {
    final now = DateTime.now().toUtc();
    return protocol.EmailVerificationCode.db.findFirstRow(
      session,
      where: (t) =>
          t.identityId.equals(identityId) &
          t.consumedAt.equals(null) &
          (t.expiresAt > now),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  @override
  Future<void> revokeActiveForIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final now = DateTime.now().toUtc();
    await protocol.EmailVerificationCode.db.updateWhere(
      session,
      where: (t) => t.identityId.equals(identityId) & t.consumedAt.equals(null),
      columnValues: (t) => [t.consumedAt(now)],
    );
  }

  @override
  Future<void> registerFailedAttempt(
    Session session,
    UuidValue id,
  ) async {
    final code = await protocol.EmailVerificationCode.db.findById(session, id);
    if (code == null) return;

    await protocol.EmailVerificationCode.db.updateById(
      session,
      id,
      columnValues: (t) => [t.failedAttempts(code.failedAttempts + 1)],
    );
  }

  @override
  Future<void> markConsumed(
    Session session,
    UuidValue id,
  ) async {
    await protocol.EmailVerificationCode.db.updateById(
      session,
      id,
      columnValues: (t) => [t.consumedAt(DateTime.now().toUtc())],
    );
  }
}
