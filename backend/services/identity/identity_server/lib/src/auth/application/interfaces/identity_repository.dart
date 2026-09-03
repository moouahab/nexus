import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;

abstract interface class IdentityRepository {
  Future<protocol.Identity> create(
    Session session, {
    String? email,
    String? username,
    bool emailVerified,
    protocol.IdentityStatus status,
  });

  Future<protocol.Identity?> findById(Session session, UuidValue id);

  Future<protocol.Identity?> findByEmail(Session session, String email);

  Future<protocol.Identity?> findByUsername(Session session, String username);

  Future<protocol.Identity?> updateStatus(
    Session session,
    UuidValue id,
    protocol.IdentityStatus status,
  );

  Future<protocol.Identity?> updateEmail(
    Session session, {
    required UuidValue id,
    required String email,
    required bool emailVerified,
  });

  Future<protocol.Identity?> markEmailVerified(Session session, UuidValue id);
}
