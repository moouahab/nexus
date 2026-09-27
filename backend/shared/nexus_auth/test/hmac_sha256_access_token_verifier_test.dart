import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('HmacSha256AccessTokenVerifier', () {
    test('verifies Identity-compatible access token claims', () {
      final identityId = const Uuid().v7obj();
      final sessionId = const Uuid().v7obj();
      final token = _createToken(
        secret: 'test-secret',
        claims: _claims(identityId: identityId, sessionId: sessionId),
      );

      final context = HmacSha256AccessTokenVerifier(
        secret: 'test-secret',
      ).verify(token);

      expect(context.identityId, identityId);
      expect(context.authSessionId, sessionId);
      expect(context.emailVerified, isTrue);
      expect(context.authenticationMethods, ['username']);
    });

    test('rejects malformed, tampered and expired tokens', () {
      final identityId = const Uuid().v7obj();
      final sessionId = const Uuid().v7obj();
      final token = _createToken(
        secret: 'test-secret',
        claims: _claims(identityId: identityId, sessionId: sessionId),
      );
      final parts = token.split('.');

      expect(
        () => HmacSha256AccessTokenVerifier(
          secret: 'test-secret',
        ).verify('bad-token'),
        throwsA(isA<NexusAuthException>()),
      );
      expect(
        () =>
            HmacSha256AccessTokenVerifier(secret: 'other-secret').verify(token),
        throwsA(isA<NexusAuthException>()),
      );
      expect(
        () => HmacSha256AccessTokenVerifier(secret: 'test-secret').verify(
          '${parts[0]}.${_encodeJson(_claims(identityId: identityId, sessionId: sessionId, expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1))))}.${parts[2]}',
        ),
        throwsA(isA<NexusAuthException>()),
      );
    });

    test('verifies service token audience and required scopes', () {
      final token = _createToken(
        secret: 'test-secret',
        claims: _serviceClaims(
          serviceName: 'projects',
          audience: 'users-service',
          scopes: ['users.profile.read', 'parties.membership.read'],
          projectId: 'project-a',
        ),
      );

      final context = HmacSha256AccessTokenVerifier(
        secret: 'test-secret',
        audience: 'users-service',
      ).verifyServiceToken(token, requiredScopes: ['users.profile.read']);

      expect(context.serviceName, 'projects');
      expect(context.audiences, ['users-service']);
      expect(context.scopes, ['users.profile.read', 'parties.membership.read']);
      expect(context.projectId, 'project-a');
      expect(context.allowsProject('project-a'), isTrue);
      expect(context.allowsProject('project-b'), isFalse);
    });

    test('rejects service token with wrong audience or missing scope', () {
      final token = _createToken(
        secret: 'test-secret',
        claims: _serviceClaims(
          serviceName: 'projects',
          audience: 'users-service',
          scopes: ['users.profile.read'],
        ),
      );

      expect(
        () => HmacSha256AccessTokenVerifier(
          secret: 'test-secret',
          audience: 'projects-service',
        ).verifyServiceToken(token),
        throwsA(isA<NexusAuthException>()),
      );
      expect(
        () =>
            HmacSha256AccessTokenVerifier(
              secret: 'test-secret',
              audience: 'users-service',
            ).verifyServiceToken(
              token,
              requiredScopes: ['parties.membership.read'],
            ),
        throwsA(isA<NexusAuthException>()),
      );
      expect(
        () => HmacSha256AccessTokenVerifier(
          secret: 'test-secret',
          audience: 'users-service',
        ).verify(token),
        throwsA(isA<NexusAuthException>()),
      );
    });
  });
}

Map<String, dynamic> _claims({
  required UuidValue identityId,
  required UuidValue sessionId,
  DateTime? expiresAt,
}) {
  final now = DateTime.now().toUtc();
  return {
    AuthClaimNames.subject: identityId.toString(),
    AuthClaimNames.sessionId: sessionId.toString(),
    AuthClaimNames.issuer: AuthTokenDefaults.issuer,
    AuthClaimNames.audience: AuthTokenDefaults.audience,
    AuthClaimNames.tokenType: AuthTokenTypes.access,
    AuthClaimNames.issuedAt: now.millisecondsSinceEpoch ~/ 1000,
    AuthClaimNames.expiresAt:
        (expiresAt ?? now.add(const Duration(minutes: 15)))
            .millisecondsSinceEpoch ~/
        1000,
    AuthClaimNames.emailVerified: true,
    AuthClaimNames.authenticationMethods: ['username'],
  };
}

Map<String, dynamic> _serviceClaims({
  required String serviceName,
  required String audience,
  required List<String> scopes,
  String? projectId,
  DateTime? expiresAt,
}) {
  final now = DateTime.now().toUtc();
  return {
    AuthClaimNames.subject: 'service:$serviceName',
    AuthClaimNames.issuer: AuthTokenDefaults.issuer,
    AuthClaimNames.audience: audience,
    AuthClaimNames.tokenType: AuthTokenTypes.service,
    AuthClaimNames.issuedAt: now.millisecondsSinceEpoch ~/ 1000,
    AuthClaimNames.expiresAt:
        (expiresAt ?? now.add(const Duration(minutes: 5)))
            .millisecondsSinceEpoch ~/
        1000,
    AuthClaimNames.scopes: scopes.join(' '),
    if (projectId != null) AuthClaimNames.projectId: projectId,
  };
}

String _createToken({
  required String secret,
  required Map<String, dynamic> claims,
}) {
  final header = {'alg': 'HS256', 'typ': 'JWT'};
  final signingInput = '${_encodeJson(header)}.${_encodeJson(claims)}';
  final signature = base64UrlEncode(
    Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(signingInput)).bytes,
  ).replaceAll('=', '');
  return '$signingInput.$signature';
}

String _encodeJson(Map<String, dynamic> value) {
  return base64UrlEncode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}
