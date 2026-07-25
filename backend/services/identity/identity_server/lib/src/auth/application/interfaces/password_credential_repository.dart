import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;

abstract interface class PasswordCredentialRepository {
  Future<protocol.PasswordCredential> create(
    Session session, {
    required UuidValue identityId,
    required String username,
    required String passwordHash,
  });

  Future<protocol.PasswordCredential?> findByUsername(
    Session session,
    String username,
  );

  Future<protocol.PasswordCredential?> updatePasswordHash(
    Session session, {
    required UuidValue id,
    required String passwordHash,
  });
}
