import 'package:identity_server/src/auth/application/exceptions/authentication_required_exception.dart';
import 'package:identity_server/src/auth/application/services/require_auth.dart';
import 'package:identity_server/src/auth/constants/auth_cookie_names.dart';
import 'package:identity_server/src/auth/domain/auth_claims.dart';
import 'package:identity_server/src/auth/domain/auth_cookie_options.dart';
import 'package:identity_server/src/auth/infrastructure/http/header_auth_cookie_service.dart';
import 'package:identity_server/src/auth/infrastructure/security/hmac_sha256_access_token_service.dart';
import 'package:identity_server/src/generated/protocol.dart' as protocol;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';
import 'fakes/auth_fakes.dart';

void main() {
  withServerpod('RequireAuth', (sessionBuilder, endpoints) {
    late Session session;
    late HmacSha256AccessTokenService accessTokenService;
    late RequireAuth requireAuth;
    late FakeIdentityRepository identities;
    late FakeAuthSessionRepository sessions;
    late UuidValue identityId;
    late UuidValue authSessionId;

    setUp(() {
      session = sessionBuilder.build();
      accessTokenService = HmacSha256AccessTokenService(secret: 'test-secret');
      identities = FakeIdentityRepository();
      sessions = FakeAuthSessionRepository();
      requireAuth = RequireAuth(
        accessTokenService: accessTokenService,
        authCookieService: HeaderAuthCookieService(
          options: AuthCookieOptions.development(),
        ),
        authSessionRepository: sessions,
        identityRepository: identities,
      );
      identityId = const Uuid().v7obj();
      authSessionId = const Uuid().v7obj();
    });

    tearDown(() async {
      await session.close();
    });

    test('rejects missing access token cookie', () async {
      await expectLater(
        requireAuth.fromHeaders(session, headers: const {}),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.missingAccessToken,
        ),
      );
    });

    test('rejects tampered access token cookie', () async {
      final token = accessTokenService.createAccessToken(
        AuthClaims.access(
          identityId: identityId,
          sessionId: authSessionId,
          emailVerified: false,
          authenticationMethods: [protocol.AuthProvider.username],
        ),
      );
      final tampered = '${token.substring(0, token.length - 1)}x';

      await expectLater(
        requireAuth.fromHeaders(
          session,
          headers: {
            'cookie': ['${AuthCookieNames.accessToken}=$tampered'],
          },
        ),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.invalidAccessToken,
        ),
      );
    });

    test('rejects expired access token cookie', () async {
      final token = accessTokenService.createAccessToken(
        AuthClaims.access(
          identityId: identityId,
          sessionId: authSessionId,
          emailVerified: false,
          authenticationMethods: [protocol.AuthProvider.username],
          issuedAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
          lifetime: const Duration(minutes: 1),
        ),
      );

      await expectLater(
        requireAuth.fromHeaders(
          session,
          headers: _accessCookieHeaders(token),
        ),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.invalidAccessToken,
        ),
      );
    });

    test('rejects missing or inactive session', () async {
      final token = _accessToken(
        accessTokenService,
        identityId: identityId,
        authSessionId: authSessionId,
      );

      await expectLater(
        requireAuth.fromHeaders(
          session,
          headers: _accessCookieHeaders(token),
        ),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.sessionNotFound,
        ),
      );

      sessions.byId[authSessionId] = protocol.AuthSession(
        id: authSessionId,
        identityId: identityId,
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        revokedAt: DateTime.now().toUtc(),
        authMethod: protocol.AuthProvider.username,
      );

      await expectLater(
        requireAuth.fromHeaders(
          session,
          headers: _accessCookieHeaders(token),
        ),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.sessionNotFound,
        ),
      );
    });

    test('rejects expired session', () async {
      final token = _accessToken(
        accessTokenService,
        identityId: identityId,
        authSessionId: authSessionId,
      );
      sessions.byId[authSessionId] = protocol.AuthSession(
        id: authSessionId,
        identityId: identityId,
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
        authMethod: protocol.AuthProvider.username,
      );

      await expectLater(
        requireAuth.fromHeaders(
          session,
          headers: _accessCookieHeaders(token),
        ),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.sessionNotFound,
        ),
      );
    });

    test('rejects missing identity', () async {
      final token = _accessToken(
        accessTokenService,
        identityId: identityId,
        authSessionId: authSessionId,
      );
      sessions.byId[authSessionId] = protocol.AuthSession(
        id: authSessionId,
        identityId: identityId,
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        authMethod: protocol.AuthProvider.username,
      );

      await expectLater(
        requireAuth.fromHeaders(
          session,
          headers: _accessCookieHeaders(token),
        ),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.identityNotFound,
        ),
      );
    });

    test('rejects disabled identity', () async {
      final token = _accessToken(
        accessTokenService,
        identityId: identityId,
        authSessionId: authSessionId,
      );
      sessions.byId[authSessionId] = protocol.AuthSession(
        id: authSessionId,
        identityId: identityId,
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        authMethod: protocol.AuthProvider.username,
      );
      identities.byId[identityId] = protocol.Identity(
        id: identityId,
        username: 'noxe',
        status: protocol.IdentityStatus.disabled,
      );

      await expectLater(
        requireAuth.fromHeaders(
          session,
          headers: _accessCookieHeaders(token),
        ),
        throwsAuthRequiredCode(
          AuthenticationRequiredExceptionCode.identityNotActive,
        ),
      );
    });

    test(
      'allows access with valid token, active session and active identity',
      () async {
        final token = accessTokenService.createAccessToken(
          AuthClaims.access(
            identityId: identityId,
            sessionId: authSessionId,
            emailVerified: true,
            authenticationMethods: [protocol.AuthProvider.username],
          ),
        );
        final authSession = protocol.AuthSession(
          id: authSessionId,
          identityId: identityId,
          expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
          authMethod: protocol.AuthProvider.username,
        );
        final identity = protocol.Identity(
          id: identityId,
          username: 'noxe',
          status: protocol.IdentityStatus.active,
        );
        sessions.byId[authSessionId] = authSession;
        identities.byId[identityId] = identity;

        final authenticated = await requireAuth.fromHeaders(
          session,
          headers: _accessCookieHeaders(token),
        );

        expect(authenticated.identityId, identityId);
        expect(authenticated.authSessionId, authSessionId);
        expect(authenticated.identity, identity);
        expect(authenticated.authSession, authSession);
        expect(authenticated.claims.emailVerified, isTrue);
        expect(authenticated.claims.authenticationMethods, [
          protocol.AuthProvider.username,
        ]);
      },
    );
  });
}

String _accessToken(
  HmacSha256AccessTokenService accessTokenService, {
  required UuidValue identityId,
  required UuidValue authSessionId,
}) {
  return accessTokenService.createAccessToken(
    AuthClaims.access(
      identityId: identityId,
      sessionId: authSessionId,
      emailVerified: true,
      authenticationMethods: [protocol.AuthProvider.username],
    ),
  );
}

Map<String, List<String>> _accessCookieHeaders(String token) {
  return {
    'cookie': [
      'theme=dark; ${AuthCookieNames.accessToken}=$token',
    ],
  };
}

Matcher throwsAuthRequiredCode(AuthenticationRequiredExceptionCode code) {
  return throwsA(
    isA<AuthenticationRequiredException>().having(
      (exception) => exception.code,
      'code',
      code,
    ),
  );
}
