import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/interfaces/auth_session_repository.dart';

class ServerpodAuthSessionRepository implements AuthSessionRepository {
  @override
  Future<protocol.AuthSession> create(
    Session session, {
    required UuidValue identityId,
    required DateTime expiresAt,
    required protocol.AuthProvider authMethod,
  }) {
    return protocol.AuthSession.db.insertRow(
      session,
      protocol.AuthSession(
        identityId: identityId,
        expiresAt: expiresAt,
        authMethod: authMethod,
      ),
    );
  }

  @override
  Future<protocol.AuthSession?> findById(Session session, UuidValue id) {
    return protocol.AuthSession.db.findById(session, id);
  }

  @override
  Future<protocol.AuthSession?> findActiveById(
    Session session,
    UuidValue id,
  ) async {
    final authSession = await findById(session, id);
    if (authSession == null) return null;
    if (authSession.revokedAt != null) return null;
    if (!authSession.expiresAt.isAfter(DateTime.now().toUtc())) return null;
    return authSession;
  }

  @override
  Future<protocol.AuthSession?> touch(Session session, UuidValue id) {
    return protocol.AuthSession.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.lastUsedAt(DateTime.now().toUtc()),
      ],
    );
  }

  @override
  Future<protocol.AuthSession?> revoke(Session session, UuidValue id) {
    return protocol.AuthSession.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.revokedAt(DateTime.now().toUtc()),
      ],
    );
  }

  @override
  Future<List<protocol.AuthSession>> revokeAllForIdentity(
    Session session,
    UuidValue identityId,
  ) async {
    final activeSessions = await protocol.AuthSession.db.find(
      session,
      where: (t) => t.identityId.equals(identityId),
    );
    final now = DateTime.now().toUtc();
    return protocol.AuthSession.db.update(
      session,
      [
        for (final authSession in activeSessions)
          if (authSession.revokedAt == null)
            authSession.copyWith(revokedAt: now),
      ],
      columns: (t) => [t.revokedAt],
    );
  }
}
