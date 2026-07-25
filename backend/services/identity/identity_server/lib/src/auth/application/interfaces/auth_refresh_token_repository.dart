import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;

abstract interface class AuthRefreshTokenRepository {
  Future<protocol.AuthRefreshToken> create(
    Session session, {
    required UuidValue authSessionId,
    required String tokenHash,
    required DateTime expiresAt,
  });

  Future<protocol.AuthRefreshToken?> findById(Session session, UuidValue id);

  Future<protocol.AuthRefreshToken?> findActiveById(
    Session session,
    UuidValue id,
  );

  Future<protocol.AuthRefreshToken?> revoke(Session session, UuidValue id);

  Future<protocol.AuthRefreshToken?> rotate(
    Session session, {
    required UuidValue oldTokenId,
    required UuidValue newTokenId,
  });
}
