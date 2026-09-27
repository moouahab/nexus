import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart';

/// Atomically consumes a Projects authorization grant once across instances.
final class ProjectGrantReplayGuard {
  const ProjectGrantReplayGuard();

  Future<void> consume(
    Session session, {
    required String jwtId,
    required DateTime expiresAt,
  }) async {
    final jwtIdHash = sha256.convert(utf8.encode(jwtId)).toString();
    try {
      await ConsumedProjectAuthorizationGrant.db.deleteWhere(
        session,
        where: (t) => t.expiresAt < DateTime.now().toUtc(),
      );
      await ConsumedProjectAuthorizationGrant.db.insertRow(
        session,
        ConsumedProjectAuthorizationGrant(
          jwtIdHash: jwtIdHash,
          expiresAt: expiresAt,
        ),
      );
    } on DatabaseQueryException catch (error) {
      if (error.code != '23505' ||
          error.constraintName !=
              'consumed_project_authorization_grant_jti_idx') {
        rethrow;
      }
      throw const FormatException('Project authorization grant already used.');
    }
  }
}
