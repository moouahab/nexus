import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;

abstract interface class EmailVerificationCodeRepository {
  Future<protocol.EmailVerificationCode> create(
    Session session, {
    required UuidValue identityId,
    required String email,
    required String codeHash,
    required DateTime expiresAt,
  });

  Future<protocol.EmailVerificationCode?> findActiveByIdentityId(
    Session session,
    UuidValue identityId,
  );

  Future<void> revokeActiveForIdentity(
    Session session,
    UuidValue identityId,
  );

  Future<void> registerFailedAttempt(
    Session session,
    UuidValue id,
  );

  Future<void> markConsumed(
    Session session,
    UuidValue id,
  );
}
