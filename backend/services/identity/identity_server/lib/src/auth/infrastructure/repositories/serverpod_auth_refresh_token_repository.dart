import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/interfaces/auth_refresh_token_repository.dart';

class ServerpodAuthRefreshTokenRepository
    implements AuthRefreshTokenRepository {
  @override
  Future<protocol.AuthRefreshToken> create(
    Session session, {
    required UuidValue authSessionId,
    required String tokenHash,
    required DateTime expiresAt,
  }) {
    return protocol.AuthRefreshToken.db.insertRow(
      session,
      protocol.AuthRefreshToken(
        authSessionId: authSessionId,
        tokenHash: tokenHash,
        expiresAt: expiresAt,
      ),
    );
  }

  @override
  Future<protocol.AuthRefreshToken?> findById(Session session, UuidValue id) {
    return protocol.AuthRefreshToken.db.findById(session, id);
  }

  @override
  Future<protocol.AuthRefreshToken?> findActiveById(
    Session session,
    UuidValue id,
  ) async {
    final refreshToken = await findById(session, id);
    if (refreshToken == null) return null;
    if (refreshToken.revokedAt != null) return null;
    if (refreshToken.rotatedAt != null) return null;
    if (!refreshToken.expiresAt.isAfter(DateTime.now().toUtc())) return null;
    return refreshToken;
  }

  @override
  Future<protocol.AuthRefreshToken?> revoke(Session session, UuidValue id) {
    return protocol.AuthRefreshToken.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.revokedAt(DateTime.now().toUtc()),
      ],
    );
  }

  @override
  Future<protocol.AuthRefreshToken?> rotate(
    Session session, {
    required UuidValue oldTokenId,
    required UuidValue newTokenId,
  }) {
    return protocol.AuthRefreshToken.db.updateById(
      session,
      oldTokenId,
      columnValues: (t) => [
        t.rotatedAt(DateTime.now().toUtc()),
        t.replacedByTokenId(newTokenId),
      ],
    );
  }
}
