import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/interfaces/identity_repository.dart';

class ServerpodIdentityRepository implements IdentityRepository {
  @override
  Future<protocol.Identity> create(
    Session session, {
    String? email,
    String? username,
    bool emailVerified = false,
    protocol.IdentityStatus status = protocol.IdentityStatus.active,
  }) {
    return protocol.Identity.db.insertRow(
      session,
      protocol.Identity(
        email: email,
        username: username,
        emailVerified: emailVerified,
        status: status,
      ),
    );
  }

  @override
  Future<protocol.Identity?> findById(Session session, UuidValue id) {
    return protocol.Identity.db.findById(session, id);
  }

  @override
  Future<protocol.Identity?> findByEmail(Session session, String email) {
    return protocol.Identity.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );
  }

  @override
  Future<protocol.Identity?> findByUsername(Session session, String username) {
    return protocol.Identity.db.findFirstRow(
      session,
      where: (t) => t.username.equals(username),
    );
  }

  @override
  Future<protocol.Identity?> updateStatus(
    Session session,
    UuidValue id,
    protocol.IdentityStatus status,
  ) {
    return protocol.Identity.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.status(status),
        t.updatedAt(DateTime.now().toUtc()),
      ],
    );
  }

  @override
  Future<protocol.Identity?> updateEmail(
    Session session, {
    required UuidValue id,
    required String email,
    required bool emailVerified,
  }) {
    return protocol.Identity.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.email(email),
        t.emailVerified(emailVerified),
        t.updatedAt(DateTime.now().toUtc()),
      ],
    );
  }

  @override
  Future<protocol.Identity?> markEmailVerified(Session session, UuidValue id) {
    return protocol.Identity.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.emailVerified(true),
        t.updatedAt(DateTime.now().toUtc()),
      ],
    );
  }
}
