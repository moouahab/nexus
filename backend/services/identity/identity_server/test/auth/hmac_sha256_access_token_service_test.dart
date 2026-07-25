import 'dart:convert';

import 'package:identity_server/src/auth/constants/auth_claim_names.dart';
import 'package:identity_server/src/auth/constants/auth_token_defaults.dart';
import 'package:identity_server/src/auth/constants/auth_token_types.dart';
import 'package:identity_server/src/auth/domain/auth_claims.dart';
import 'package:identity_server/src/auth/infrastructure/security/hmac_sha256_access_token_service.dart';
import 'package:identity_server/src/generated/protocol.dart' as protocol;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('HmacSha256AccessTokenService', () {
    late HmacSha256AccessTokenService service;
    late UuidValue identityId;
    late UuidValue sessionId;

    setUp(() {
      service = HmacSha256AccessTokenService(secret: 'test-secret');
      identityId = const Uuid().v7obj();
      sessionId = const Uuid().v7obj();
    });

    test('creates and verifies required JWT claims', () {
      final token = service.createAccessToken(
        AuthClaims.access(
          identityId: identityId,
          sessionId: sessionId,
          emailVerified: true,
          authenticationMethods: [protocol.AuthProvider.username],
        ),
      );

      final claims = service.verifyAccessToken(token);

      expect(claims.subject, identityId.toString());
      expect(claims.sessionId, sessionId.toString());
      expect(claims.issuer, AuthTokenDefaults.issuer);
      expect(claims.audience, AuthTokenDefaults.audience);
      expect(claims.tokenType, AuthTokenTypes.access);
      expect(claims.emailVerified, isTrue);
      expect(claims.authenticationMethods, [protocol.AuthProvider.username]);
    });

    test('rejects malformed tokens', () {
      expect(
        () => service.verifyAccessToken('bad-token'),
        throwsA(isA<InvalidAccessTokenException>()),
      );
    });

    test('rejects tampered payloads', () {
      final token = service.createAccessToken(
        AuthClaims.access(
          identityId: identityId,
          sessionId: sessionId,
          emailVerified: false,
          authenticationMethods: [protocol.AuthProvider.username],
        ),
      );
      final parts = token.split('.');
      final payload = _decodeJson(parts[1])
        ..[AuthClaimNames.subject] = const Uuid().v7();
      final tamperedToken = '${parts[0]}.${_encodeJson(payload)}.${parts[2]}';

      expect(
        () => service.verifyAccessToken(tamperedToken),
        throwsA(isA<InvalidAccessTokenException>()),
      );
    });

    test('rejects wrong issuer, audience and token type', () {
      expectInvalidClaims(
        service,
        AuthClaims.access(
          identityId: identityId,
          sessionId: sessionId,
          emailVerified: false,
          authenticationMethods: [protocol.AuthProvider.username],
          issuer: 'other-service',
        ),
      );
      expectInvalidClaims(
        service,
        AuthClaims.access(
          identityId: identityId,
          sessionId: sessionId,
          emailVerified: false,
          authenticationMethods: [protocol.AuthProvider.username],
          audience: 'other-api',
        ),
      );
      expectInvalidClaims(
        service,
        AuthClaims(
          subject: identityId.toString(),
          sessionId: sessionId.toString(),
          issuer: AuthTokenDefaults.issuer,
          audience: AuthTokenDefaults.audience,
          tokenType: 'refresh',
          issuedAt: DateTime.now().toUtc(),
          expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
          emailVerified: false,
          authenticationMethods: [protocol.AuthProvider.username],
        ),
      );
    });

    test('rejects expired tokens', () {
      expectInvalidClaims(
        service,
        AuthClaims.access(
          identityId: identityId,
          sessionId: sessionId,
          emailVerified: false,
          authenticationMethods: [protocol.AuthProvider.username],
          issuedAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
          lifetime: const Duration(minutes: 1),
        ),
      );
    });
  });
}

void expectInvalidClaims(
  HmacSha256AccessTokenService service,
  AuthClaims claims,
) {
  final token = service.createAccessToken(claims);
  expect(
    () => service.verifyAccessToken(token),
    throwsA(isA<InvalidAccessTokenException>()),
  );
}

Map<String, dynamic> _decodeJson(String value) {
  return (jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(value))))
          as Map<String, dynamic>)
      .cast<String, dynamic>();
}

String _encodeJson(Map<String, dynamic> value) {
  return base64UrlEncode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}
