import 'dart:convert';
import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final class ProjectAuthorizationGrant {
  const ProjectAuthorizationGrant({
    required this.projectId,
    required this.tenantPartyId,
    required this.identityId,
    required this.jwtId,
    required this.expiresAt,
  });

  final String projectId;
  final String tenantPartyId;
  final String identityId;
  final String jwtId;
  final DateTime expiresAt;
}

final class ProjectAuthorizationGrantCodec {
  const ProjectAuthorizationGrantCodec({
    required this.secret,
    this.lifetime = const Duration(minutes: 10),
  });

  final String secret;
  final Duration lifetime;

  String issue({
    required String projectId,
    required String tenantPartyId,
    required String identityId,
  }) {
    if (secret.trim().isEmpty) throw StateError('Grant signing unavailable.');
    final random = Random.secure();
    final jwtId = base64Url.encode(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    return JWT(
      {
        'projectId': projectId,
        'tenantPartyId': tenantPartyId,
        'identityId': identityId,
        'purpose': 'projects.read.token-exchange',
        'azp': 'ai-gateway',
      },
      issuer: 'projects-service',
      audience: Audience.one('identity-service'),
      jwtId: jwtId,
    ).sign(SecretKey(secret), expiresIn: lifetime);
  }

  ProjectAuthorizationGrant verify(String token) {
    if (secret.trim().isEmpty || token.trim().isEmpty) {
      throw const FormatException('Project authorization grant unavailable.');
    }
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      final payload = jwt.payload;
      if (jwt.issuer != 'projects-service' ||
          jwt.audience?.contains('identity-service') != true ||
          payload is! Map ||
          payload['purpose'] != 'projects.read.token-exchange' ||
          payload['azp'] != 'ai-gateway') {
        throw const FormatException('Invalid project authorization grant.');
      }
      String field(String name) {
        final value = payload[name];
        if (value is! String || value.isEmpty) {
          throw const FormatException('Invalid project authorization grant.');
        }
        return value;
      }

      return ProjectAuthorizationGrant(
        projectId: field('projectId'),
        tenantPartyId: field('tenantPartyId'),
        identityId: field('identityId'),
        jwtId: field('jti'),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          ((payload['exp'] as num) * 1000).toInt(),
          isUtc: true,
        ),
      );
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('Invalid project authorization grant.');
    }
  }
}
