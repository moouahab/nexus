import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;

abstract interface class AuthSessionRepository {
  Future<protocol.AuthSession> create(
    Session session, {
    required UuidValue identityId,
    required DateTime expiresAt,
    required protocol.AuthProvider authMethod,
  });

  Future<protocol.AuthSession?> findById(Session session, UuidValue id);

  Future<protocol.AuthSession?> findActiveById(Session session, UuidValue id);

  Future<protocol.AuthSession?> touch(Session session, UuidValue id);

  Future<protocol.AuthSession?> revoke(Session session, UuidValue id);

  Future<List<protocol.AuthSession>> revokeAllForIdentity(
    Session session,
    UuidValue identityId,
  );
}
