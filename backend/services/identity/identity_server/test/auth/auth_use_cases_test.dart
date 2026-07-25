import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/application/services/auth_token_issuer.dart';
import 'package:identity_server/src/auth/application/use_cases/login_with_username_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/logout_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/refresh_session_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/register_with_username_use_case.dart';
import 'package:identity_server/src/auth/constants/auth_cookie_names.dart';
import 'package:identity_server/src/auth/domain/auth_cookie_options.dart';
import 'package:identity_server/src/auth/infrastructure/http/header_auth_cookie_service.dart';
import 'package:identity_server/src/auth/infrastructure/security/colon_refresh_token_codec.dart';
import 'package:identity_server/src/auth/infrastructure/security/hmac_sha256_access_token_service.dart';
import 'package:identity_server/src/generated/protocol.dart' as protocol;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';
import 'fakes/auth_fakes.dart';

void main() {
  withServerpod(
    'Auth use cases',
    (sessionBuilder, endpoints) {
      late Session session;
      late _AuthHarness auth;

      setUp(() {
        session = sessionBuilder.build();
        auth = _AuthHarness();
      });

      tearDown(() async {
        await session.close();
      });

      test(
        'register stores normalized identity and returns auth cookies',
        () async {
          final result = await auth.register.execute(
            session,
            username: '  Noxe  ',
            password: 'test-password',
            email: '  NOXE@Example.COM  ',
          );

          expect(result.identityId, isNotNull);
          expect(result.authSessionId, isNotNull);
          expect(auth.identities.byId[result.identityId]!.username, 'noxe');
          expect(
            auth.identities.byId[result.identityId]!.email,
            'noxe@example.com',
          );
          expect(auth.credentials.byUsername['noxe'], isNotNull);
          expect(
            auth.providers.byId.values.single.provider,
            protocol.AuthProvider.username,
          );
          expect(_hasAuthCookies(result.responseHeaders), isTrue);
        },
      );

      test('register rejects duplicate username', () async {
        await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );

        await expectLater(
          auth.register.execute(
            session,
            username: ' NOXE ',
            password: 'other-password',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.usernameAlreadyExists),
        );
      });

      test('login succeeds and resets previous failed attempts', () async {
        await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );

        await expectLater(
          auth.login.execute(
            session,
            username: 'noxe',
            password: 'bad-password',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidCredentials),
        );

        final result = await auth.login.execute(
          session,
          username: ' NOXE ',
          password: 'test-password',
        );

        expect(result.identityId, isNotNull);
        expect(auth.loginLimiter.failedAttempts['noxe'], isNull);
        expect(_hasAuthCookies(result.responseHeaders), isTrue);
      });

      test('login blocks invalid password brute force', () async {
        await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );

        for (var attempt = 0; attempt < 3; attempt++) {
          await expectLater(
            auth.login.execute(
              session,
              username: 'noxe',
              password: 'bad-password',
            ),
            throwsAuthCode(AuthUseCaseExceptionCode.invalidCredentials),
          );
        }

        await expectLater(
          auth.login.execute(
            session,
            username: 'noxe',
            password: 'test-password',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.tooManyAttempts),
        );
      });

      test('login blocks unknown username brute force too', () async {
        for (var attempt = 0; attempt < 3; attempt++) {
          await expectLater(
            auth.login.execute(
              session,
              username: 'ghost',
              password: 'bad-password',
            ),
            throwsAuthCode(AuthUseCaseExceptionCode.invalidCredentials),
          );
        }

        await expectLater(
          auth.login.execute(
            session,
            username: 'ghost',
            password: 'bad-password',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.tooManyAttempts),
        );
      });

      test('login rejects disabled identity', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );
        await auth.identities.updateStatus(
          session,
          registered.identityId!,
          protocol.IdentityStatus.disabled,
        );

        await expectLater(
          auth.login.execute(
            session,
            username: 'noxe',
            password: 'test-password',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.identityNotActive),
        );
      });

      test('refresh rotates refresh token and rejects reuse', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );
        final oldRefreshCookie = _refreshCookieHeader(
          registered.responseHeaders,
        );

        final refreshed = await auth.refresh.execute(
          session,
          requestHeaders: oldRefreshCookie,
        );

        expect(refreshed.identityId, registered.identityId);
        expect(refreshed.authSessionId, registered.authSessionId);
        expect(auth.refreshTokens.byId.values, hasLength(2));
        expect(
          auth.refreshTokens.byId.values.where(
            (token) => token.rotatedAt != null,
          ),
          hasLength(1),
        );

        await expectLater(
          auth.refresh.execute(session, requestHeaders: oldRefreshCookie),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidRefreshToken),
        );
      });

      test('refresh rejects missing, malformed and tampered cookies', () async {
        await expectLater(
          auth.refresh.execute(session, requestHeaders: const {}),
          throwsAuthCode(AuthUseCaseExceptionCode.missingRefreshToken),
        );

        await expectLater(
          auth.refresh.execute(
            session,
            requestHeaders: {
              'cookie': ['${AuthCookieNames.refreshToken}=bad-token'],
            },
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidRefreshToken),
        );

        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );
        final tamperedCookie = _replaceRefreshSecret(
          registered.responseHeaders,
          'wrong-secret',
        );

        await expectLater(
          auth.refresh.execute(session, requestHeaders: tamperedCookie),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidRefreshToken),
        );
      });

      test('refresh rejects disabled identity', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );
        await auth.identities.updateStatus(
          session,
          registered.identityId!,
          protocol.IdentityStatus.disabled,
        );

        await expectLater(
          auth.refresh.execute(
            session,
            requestHeaders: _refreshCookieHeader(registered.responseHeaders),
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.identityNotActive),
        );
      });

      test('logout revokes session and clears cookies', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
        );

        final result = await auth.logout.execute(
          session,
          requestHeaders: _refreshCookieHeader(registered.responseHeaders),
        );

        expect(result.authSessionId, registered.authSessionId);
        expect(
          auth.sessions.byId[registered.authSessionId]!.revokedAt,
          isNotNull,
        );
        expect(auth.refreshTokens.byId.values.single.revokedAt, isNotNull);
        expect(_clearsAuthCookies(result.responseHeaders), isTrue);
      });

      test('logout without cookie still clears cookies', () async {
        final result = await auth.logout.execute(
          session,
          requestHeaders: const {},
        );

        expect(result.identityId, isNull);
        expect(result.authSessionId, isNull);
        expect(_clearsAuthCookies(result.responseHeaders), isTrue);
      });

      test('XSS-like values are stored as normalized text only', () async {
        const xssUsername = '<script>alert(1)</script>';

        await auth.register.execute(
          session,
          username: xssUsername,
          password: 'test-password',
          email: 'XSS@Example.COM',
        );

        expect(auth.credentials.byUsername[xssUsername], isNotNull);
        expect(auth.identities.byId.values.single.username, xssUsername);
        expect(auth.identities.byId.values.single.email, 'xss@example.com');
      });

      test(
        'SQL-injection-like username does not bypass password checks',
        () async {
          await auth.register.execute(
            session,
            username: 'noxe',
            password: 'test-password',
          );

          await expectLater(
            auth.login.execute(
              session,
              username: "noxe' OR '1'='1",
              password: 'anything',
            ),
            throwsAuthCode(AuthUseCaseExceptionCode.invalidCredentials),
          );
        },
      );
    },
  );
}

Matcher throwsAuthCode(AuthUseCaseExceptionCode code) {
  return throwsA(
    isA<AuthUseCaseException>().having(
      (exception) => exception.code,
      'code',
      code,
    ),
  );
}

bool _hasAuthCookies(Map<String, List<String>> headers) {
  final cookies = headers['set-cookie'] ?? const [];
  return cookies.any(
        (cookie) => cookie.startsWith(AuthCookieNames.accessToken),
      ) &&
      cookies.any((cookie) => cookie.startsWith(AuthCookieNames.refreshToken));
}

bool _clearsAuthCookies(Map<String, List<String>> headers) {
  final cookies = headers['set-cookie'] ?? const [];
  return cookies.length == 2 &&
      cookies.every((cookie) => cookie.contains('Max-Age=0'));
}

Map<String, List<String>> _refreshCookieHeader(
  Map<String, List<String>> responseHeaders,
) {
  final refreshCookie = responseHeaders['set-cookie']!.firstWhere(
    (cookie) => cookie.startsWith(AuthCookieNames.refreshToken),
  );
  return {
    'cookie': [refreshCookie.split(';').first],
  };
}

Map<String, List<String>> _replaceRefreshSecret(
  Map<String, List<String>> responseHeaders,
  String secret,
) {
  final cookieValue = _refreshCookieHeader(
    responseHeaders,
  )['cookie']!.single.split('=').last;
  final tokenId = cookieValue.split(':').first;
  return {
    'cookie': ['${AuthCookieNames.refreshToken}=$tokenId:$secret'],
  };
}

class _AuthHarness {
  _AuthHarness() {
    issuer = AuthTokenIssuer(
      authSessionRepository: sessions,
      authRefreshTokenRepository: refreshTokens,
      accessTokenService: accessTokens,
      refreshTokenSecretService: refreshSecrets,
      refreshTokenCodec: refreshTokenCodec,
      authCookieService: cookies,
    );

    register = RegisterWithUsernameUseCase(
      identityRepository: identities,
      identityProviderRepository: providers,
      passwordCredentialRepository: credentials,
      passwordHasher: passwordHasher,
      authTokenIssuer: issuer,
    );

    login = LoginWithUsernameUseCase(
      identityRepository: identities,
      passwordCredentialRepository: credentials,
      passwordHasher: passwordHasher,
      loginAttemptLimiter: loginLimiter,
      authTokenIssuer: issuer,
    );

    refresh = RefreshSessionUseCase(
      identityRepository: identities,
      authSessionRepository: sessions,
      authRefreshTokenRepository: refreshTokens,
      accessTokenService: accessTokens,
      refreshTokenSecretService: refreshSecrets,
      refreshTokenCodec: refreshTokenCodec,
      authCookieService: cookies,
    );

    logout = LogoutUseCase(
      authSessionRepository: sessions,
      authRefreshTokenRepository: refreshTokens,
      refreshTokenCodec: refreshTokenCodec,
      authCookieService: cookies,
    );
  }

  final identities = FakeIdentityRepository();
  final providers = FakeIdentityProviderRepository();
  final credentials = FakePasswordCredentialRepository();
  final sessions = FakeAuthSessionRepository();
  final refreshTokens = FakeAuthRefreshTokenRepository();
  final passwordHasher = FakePasswordHasher();
  final refreshSecrets = FakeRefreshTokenSecretService();
  final refreshTokenCodec = ColonRefreshTokenCodec();
  final cookies = HeaderAuthCookieService(
    options: AuthCookieOptions.development(),
  );
  final accessTokens = HmacSha256AccessTokenService(secret: 'test-secret');
  final loginLimiter = FakeLoginAttemptLimiter(maxAttempts: 3);

  late final AuthTokenIssuer issuer;
  late final RegisterWithUsernameUseCase register;
  late final LoginWithUsernameUseCase login;
  late final RefreshSessionUseCase refresh;
  late final LogoutUseCase logout;
}
