import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/interfaces/password_reset_code_repository.dart';

class ServerpodPasswordResetCodeRepository
    implements PasswordResetCodeRepository {
  @override
  Future<protocol.PasswordResetCode> create(
    Session session, {
    required UuidValue identityId,
    required String email,
    required String codeHash,
    required DateTime expiresAt,
  }) {
    return protocol.PasswordResetCode.db.insertRow(
      session,
      protocol.PasswordResetCode(
        identityId: identityId,
        email: email,
        codeHash: codeHash,
        expiresAt: expiresAt,
      ),
    );
  }

  @override
  Future<protocol.PasswordResetCode?> findActiveByIdentityId(
    Session session,
    UuidValue identityId,
  ) {
    final now = DateTime.now().toUtc();
    return protocol.PasswordResetCode.db.findFirstRow(
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
  Future<void> markConsumed(Session session, UuidValue id) async {
    await protocol.PasswordResetCode.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.consumedAt(DateTime.now().toUtc()),
      ],
    );
  }

  @override
  Future<void> registerFailedAttempt(Session session, UuidValue id) async {
    final code = await protocol.PasswordResetCode.db.findById(session, id);
    if (code == null) return;

    await protocol.PasswordResetCode.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.failedAttempts(code.failedAttempts + 1),
      ],
    );
  }

  @override
  Future<void> revokeActiveForIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    await protocol.PasswordResetCode.db.updateWhere(
      session,
      where: (t) =>
          t.identityId.equals(identityId) &
          t.consumedAt.equals(null as DateTime?),
      columnValues: (t) => [
        t.consumedAt(DateTime.now().toUtc()),
      ],
    );
  }
}
