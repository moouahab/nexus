import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/interfaces/password_credential_repository.dart';

class ServerpodPasswordCredentialRepository
    implements PasswordCredentialRepository {
  @override
  Future<protocol.PasswordCredential> create(
    Session session, {
    required UuidValue identityId,
    required String username,
    required String passwordHash,
  }) {
    return protocol.PasswordCredential.db.insertRow(
      session,
      protocol.PasswordCredential(
        identityId: identityId,
        username: username,
        passwordHash: passwordHash,
      ),
    );
  }

  @override
  Future<protocol.PasswordCredential?> findByUsername(
    Session session,
    String username,
  ) {
    return protocol.PasswordCredential.db.findFirstRow(
      session,
      where: (t) => t.username.equals(username),
    );
  }

  @override
  Future<protocol.PasswordCredential?> updatePasswordHash(
    Session session, {
    required UuidValue id,
    required String passwordHash,
  }) {
    return protocol.PasswordCredential.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.passwordHash(passwordHash),
        t.updatedAt(DateTime.now().toUtc()),
      ],
    );
  }
}
