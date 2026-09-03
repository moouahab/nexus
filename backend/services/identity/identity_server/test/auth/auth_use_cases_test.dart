import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/application/services/auth_token_issuer.dart';
import 'package:identity_server/src/auth/application/services/email_verification_service.dart';
import 'package:identity_server/src/auth/application/services/password_reset_service.dart';
import 'package:identity_server/src/auth/application/use_cases/change_email_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/change_password_use_case.dart';
import 'package:identity_server/src/auth/application/interfaces/oauth_provider_verifier.dart';
import 'package:identity_server/src/auth/application/use_cases/login_with_oauth_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/login_with_username_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/logout_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/refresh_session_use_case.dart';
import 'package:identity_server/src/auth/application/use_cases/register_with_username_use_case.dart';
import 'package:identity_server/src/auth/constants/auth_cookie_names.dart';
import 'package:identity_server/src/auth/domain/auth_cookie_options.dart';
import 'package:identity_server/src/auth/domain/auth_token_transport.dart';
import 'package:identity_server/src/auth/infrastructure/http/header_auth_cookie_service.dart';
import 'package:identity_server/src/auth/infrastructure/security/colon_refresh_token_codec.dart';
import 'package:identity_server/src/auth/infrastructure/security/default_password_policy.dart';
import 'package:identity_server/src/auth/infrastructure/security/hmac_sha256_access_token_service.dart';
import 'package:identity_server/src/auth/infrastructure/validation/default_email_policy.dart';
import 'package:identity_server/src/auth/infrastructure/validation/default_username_policy.dart';
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
            auth.emailVerificationSender.sentCodes['noxe@example.com'],
            '12345678',
          );
          expect(
            auth.providers.byId.values.single.provider,
            protocol.AuthProvider.username,
          );
          expect(_hasAuthCookies(result.responseHeaders), isTrue);
        },
      );

      test('register can return tokens in response body for apps', () async {
        final result = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          tokenTransport: AuthTokenTransport.body,
        );

        expect(result.responseHeaders, isEmpty);
        expect(result.responseBody(), containsPair('tokenType', 'Bearer'));
        expect(result.responseBody()['accessToken'], isA<String>());
        expect(result.responseBody()['refreshToken'], isA<String>());
        expect(result.responseBody()['expiresIn'], 900);
      });

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

      test('register rejects duplicate email', () async {
        await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );

        await expectLater(
          auth.register.execute(
            session,
            username: 'other',
            password: 'test-password',
            email: '  NOXE@Example.COM  ',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.emailAlreadyExists),
        );
      });

      test('email verification marks identity email as verified', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );

        final verified = await auth.emailVerification.verify(
          session,
          identityId: registered.identityId!,
          code: '12345678',
        );

        expect(verified.emailVerified, isTrue);
        expect(
          auth.identities.byId[registered.identityId]!.emailVerified,
          isTrue,
        );
      });

      test('email verification rejects invalid code', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );

        await expectLater(
          auth.emailVerification.verify(
            session,
            identityId: registered.identityId!,
            code: '99999999',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidEmailVerificationCode),
        );
      });

      test('email verification resend replaces active code', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );
        auth.verificationCodeGenerator.nextCode = '87654321';

        await auth.emailVerification.resend(
          session,
          identityId: registered.identityId!,
        );

        expect(
          auth.emailVerificationSender.sentCodes['noxe@example.com'],
          '87654321',
        );
        await expectLater(
          auth.emailVerification.verify(
            session,
            identityId: registered.identityId!,
            code: '12345678',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidEmailVerificationCode),
        );

        final verified = await auth.emailVerification.verify(
          session,
          identityId: registered.identityId!,
          code: '87654321',
        );
        expect(verified.emailVerified, isTrue);
      });

      test('email verification resend is rate limited', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );

        for (var attempt = 0; attempt < 3; attempt++) {
          await auth.emailVerification.resend(
            session,
            identityId: registered.identityId!,
          );
        }

        await expectLater(
          auth.emailVerification.resend(
            session,
            identityId: registered.identityId!,
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.tooManyAttempts),
        );
      });

      test('register rejects weak passwords', () async {
        await expectLater(
          auth.register.execute(
            session,
            username: 'noxe',
            password: 'short',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.weakPassword),
        );

        await expectLater(
          auth.register.execute(
            session,
            username: 'noxe',
            password: 'noxe-password-123',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.weakPassword),
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

      test('oauth login creates an identity and returns body tokens', () async {
        auth.googleVerifier.nextProfile = const OAuthProviderProfile(
          provider: protocol.AuthProvider.google,
          providerUserId: 'google-sub-1',
          email: 'NOXE@Example.COM',
          emailVerified: true,
        );

        final result = await auth.oauthLogin.execute(
          session,
          provider: protocol.AuthProvider.google,
          code: 'oauth-code',
          redirectUri: 'https://app.example.com/auth/callback',
          tokenTransport: AuthTokenTransport.body,
        );

        expect(result.responseHeaders, isEmpty);
        expect(result.responseBody()['tokenType'], 'Bearer');
        final identity = auth.identities.byId[result.identityId]!;
        expect(identity.email, 'noxe@example.com');
        expect(identity.emailVerified, isTrue);
        expect(
          auth.providers.byId.values.single.providerUserId,
          'google-sub-1',
        );
        expect(
          auth.providers.byId.values.single.provider,
          protocol.AuthProvider.google,
        );
      });

      test('oauth login reuses linked provider identity', () async {
        auth.googleVerifier.nextProfile = const OAuthProviderProfile(
          provider: protocol.AuthProvider.google,
          providerUserId: 'google-sub-1',
          email: 'noxe@example.com',
          emailVerified: true,
        );

        final first = await auth.oauthLogin.execute(
          session,
          provider: protocol.AuthProvider.google,
          code: 'first-code',
          redirectUri: 'https://app.example.com/auth/callback',
        );
        final second = await auth.oauthLogin.execute(
          session,
          provider: protocol.AuthProvider.google,
          code: 'second-code',
          redirectUri: 'https://app.example.com/auth/callback',
        );

        expect(second.identityId, first.identityId);
        expect(auth.providers.byId, hasLength(1));
        expect(auth.sessions.byId, hasLength(2));
      });

      test(
        'oauth login links verified email to an existing identity',
        () async {
          final registerResult = await auth.register.execute(
            session,
            username: 'noxe',
            password: 'test-password',
            email: 'noxe@example.com',
          );
          auth.googleVerifier.nextProfile = const OAuthProviderProfile(
            provider: protocol.AuthProvider.google,
            providerUserId: 'google-sub-1',
            email: 'noxe@example.com',
            emailVerified: true,
          );

          final oauthResult = await auth.oauthLogin.execute(
            session,
            provider: protocol.AuthProvider.google,
            code: 'oauth-code',
            redirectUri: 'https://app.example.com/auth/callback',
          );

          expect(oauthResult.identityId, registerResult.identityId);
          expect(
            auth.providers.byId.values.map((provider) => provider.provider),
            containsAll([
              protocol.AuthProvider.username,
              protocol.AuthProvider.google,
            ]),
          );
        },
      );

      test('oauth login rejects unverified email collision', () async {
        await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );
        auth.googleVerifier.nextProfile = const OAuthProviderProfile(
          provider: protocol.AuthProvider.google,
          providerUserId: 'google-sub-1',
          email: 'noxe@example.com',
        );

        await expectLater(
          auth.oauthLogin.execute(
            session,
            provider: protocol.AuthProvider.google,
            code: 'oauth-code',
            redirectUri: 'https://app.example.com/auth/callback',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.emailAlreadyExists),
        );
      });

      test('oauth login rejects disabled linked identity', () async {
        final result = await auth.oauthLogin.execute(
          session,
          provider: protocol.AuthProvider.google,
          code: 'oauth-code',
          redirectUri: 'https://app.example.com/auth/callback',
        );
        await auth.identities.updateStatus(
          session,
          result.identityId!,
          protocol.IdentityStatus.disabled,
        );

        await expectLater(
          auth.oauthLogin.execute(
            session,
            provider: protocol.AuthProvider.google,
            code: 'oauth-code',
            redirectUri: 'https://app.example.com/auth/callback',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.identityNotActive),
        );
      });

      test('oauth login rejects providers that are not configured', () async {
        await expectLater(
          auth.oauthLogin.execute(
            session,
            provider: protocol.AuthProvider.apple,
            code: 'oauth-code',
            redirectUri: 'https://app.example.com/auth/callback',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.oauthProviderNotConfigured),
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

      test(
        'refresh can read refresh token from body and return body tokens',
        () async {
          final registered = await auth.register.execute(
            session,
            username: 'noxe',
            password: 'test-password',
            tokenTransport: AuthTokenTransport.body,
          );

          final refreshed = await auth.refresh.execute(
            session,
            requestHeaders: const {},
            refreshToken: registered.responseBody()['refreshToken'] as String,
            tokenTransport: AuthTokenTransport.body,
          );

          expect(refreshed.identityId, registered.identityId);
          expect(refreshed.authSessionId, registered.authSessionId);
          expect(refreshed.responseHeaders, isEmpty);
          expect(refreshed.responseBody()['accessToken'], isA<String>());
          expect(refreshed.responseBody()['refreshToken'], isA<String>());
          expect(auth.refreshTokens.byId.values, hasLength(2));
        },
      );

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

      test('password reset updates password and revokes sessions', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );

        await auth.passwordReset.start(
          session,
          email: ' NOXE@Example.COM ',
        );

        expect(
          auth.passwordResetSender.sentCodes['noxe@example.com'],
          '12345678',
        );

        await auth.passwordReset.finish(
          session,
          email: 'noxe@example.com',
          code: '12345678',
          newPassword: 'new-test-password',
        );

        expect(
          auth.credentials.byUsername['noxe']!.passwordHash,
          'hash:new-test-password',
        );
        expect(
          auth.sessions.byId[registered.authSessionId]!.revokedAt,
          isNotNull,
        );
        await expectLater(
          auth.login.execute(
            session,
            username: 'noxe',
            password: 'test-password',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidCredentials),
        );

        final loggedIn = await auth.login.execute(
          session,
          username: 'noxe',
          password: 'new-test-password',
        );
        expect(loggedIn.identityId, registered.identityId);
      });

      test('password reset rejects invalid code', () async {
        await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );
        await auth.passwordReset.start(session, email: 'noxe@example.com');

        await expectLater(
          auth.passwordReset.finish(
            session,
            email: 'noxe@example.com',
            code: '99999999',
            newPassword: 'new-test-password',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidPasswordResetCode),
        );
      });

      test('password reset start is rate limited', () async {
        await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );

        for (var attempt = 0; attempt < 3; attempt++) {
          await auth.passwordReset.start(
            session,
            email: ' NOXE@Example.COM ',
          );
        }

        await expectLater(
          auth.passwordReset.start(
            session,
            email: 'noxe@example.com',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.tooManyAttempts),
        );
      });

      test(
        'change password requires current password and revokes sessions',
        () async {
          final registered = await auth.register.execute(
            session,
            username: 'noxe',
            password: 'test-password',
            email: 'noxe@example.com',
          );

          await expectLater(
            auth.changePassword.execute(
              session,
              identityId: registered.identityId!,
              currentPassword: 'bad-password',
              newPassword: 'new-test-password',
              email: 'noxe@example.com',
            ),
            throwsAuthCode(AuthUseCaseExceptionCode.invalidCredentials),
          );

          await auth.changePassword.execute(
            session,
            identityId: registered.identityId!,
            currentPassword: 'test-password',
            newPassword: 'new-test-password',
            email: 'noxe@example.com',
          );

          expect(
            auth.credentials.byUsername['noxe']!.passwordHash,
            'hash:new-test-password',
          );
          expect(
            auth.sessions.byId[registered.authSessionId]!.revokedAt,
            isNotNull,
          );
        },
      );

      test('change email resets verification and sends a new code', () async {
        final registered = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );
        await auth.emailVerification.verify(
          session,
          identityId: registered.identityId!,
          code: '12345678',
        );
        auth.verificationCodeGenerator.nextCode = '87654321';

        final identity = await auth.changeEmail.execute(
          session,
          identityId: registered.identityId!,
          email: ' NEW@Example.COM ',
        );

        expect(identity.email, 'new@example.com');
        expect(identity.emailVerified, isFalse);
        expect(
          auth.emailVerificationSender.sentCodes['new@example.com'],
          '87654321',
        );
        expect(
          auth.providers.byId.values.single.email,
          'new@example.com',
        );
        expect(
          auth.sessions.byId[registered.authSessionId]!.revokedAt,
          isNotNull,
        );
      });

      test('change email rejects duplicate email', () async {
        final first = await auth.register.execute(
          session,
          username: 'noxe',
          password: 'test-password',
          email: 'noxe@example.com',
        );
        await auth.register.execute(
          session,
          username: 'other',
          password: 'test-password',
          email: 'other@example.com',
        );

        await expectLater(
          auth.changeEmail.execute(
            session,
            identityId: first.identityId!,
            email: 'other@example.com',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.emailAlreadyExists),
        );
      });

      test('register rejects unsafe username and invalid email', () async {
        const xssUsername = '<script>alert(1)</script>';

        await expectLater(
          auth.register.execute(
            session,
            username: xssUsername,
            password: 'test-password',
            email: 'xss@example.com',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidUsername),
        );

        await expectLater(
          auth.register.execute(
            session,
            username: 'safe-user',
            password: 'test-password',
            email: 'not-an-email',
          ),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidEmail),
        );
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
  return cookies.length == 3 &&
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
    emailVerification = EmailVerificationService(
      codeRepository: emailVerificationCodes,
      identityRepository: identities,
      codeHasher: codeHasher,
      codeGenerator: verificationCodeGenerator,
      sender: emailVerificationSender,
      resendRateLimiter: otpRateLimiter,
    );

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
      usernamePolicy: usernamePolicy,
      emailPolicy: emailPolicy,
      passwordHasher: passwordHasher,
      passwordPolicy: passwordPolicy,
      authTokenIssuer: issuer,
      emailVerificationService: emailVerification,
    );

    login = LoginWithUsernameUseCase(
      identityRepository: identities,
      passwordCredentialRepository: credentials,
      passwordHasher: passwordHasher,
      loginAttemptLimiter: loginLimiter,
      authTokenIssuer: issuer,
    );

    oauthLogin = LoginWithOAuthUseCase(
      identityRepository: identities,
      identityProviderRepository: providers,
      verifiers: {
        protocol.AuthProvider.google: googleVerifier,
        protocol.AuthProvider.github: githubVerifier,
      },
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

    passwordReset = PasswordResetService(
      identityRepository: identities,
      passwordCredentialRepository: credentials,
      authSessionRepository: sessions,
      codeRepository: passwordResetCodes,
      codeHasher: codeHasher,
      codeGenerator: verificationCodeGenerator,
      sender: passwordResetSender,
      passwordHasher: passwordHasher,
      passwordPolicy: passwordPolicy,
      startRateLimiter: otpRateLimiter,
    );

    changePassword = ChangePasswordUseCase(
      passwordCredentialRepository: credentials,
      authSessionRepository: sessions,
      passwordHasher: passwordHasher,
      passwordPolicy: passwordPolicy,
    );

    changeEmail = ChangeEmailUseCase(
      identityRepository: identities,
      identityProviderRepository: providers,
      authSessionRepository: sessions,
      emailPolicy: emailPolicy,
      emailVerificationService: emailVerification,
    );
  }

  final identities = FakeIdentityRepository();
  final providers = FakeIdentityProviderRepository();
  final credentials = FakePasswordCredentialRepository();
  final sessions = FakeAuthSessionRepository();
  final refreshTokens = FakeAuthRefreshTokenRepository();
  final emailVerificationCodes = FakeEmailVerificationCodeRepository();
  final passwordResetCodes = FakePasswordResetCodeRepository();
  final passwordHasher = FakePasswordHasher();
  final codeHasher = FakeSecretHasher();
  final verificationCodeGenerator = FakeVerificationCodeGenerator();
  final emailVerificationSender = FakeEmailVerificationSender();
  final passwordResetSender = FakePasswordResetSender();
  final usernamePolicy = const DefaultUsernamePolicy();
  final emailPolicy = const DefaultEmailPolicy();
  final passwordPolicy = const DefaultPasswordPolicy();
  final refreshSecrets = FakeRefreshTokenSecretService();
  final refreshTokenCodec = ColonRefreshTokenCodec();
  final cookies = HeaderAuthCookieService(
    options: AuthCookieOptions.development(),
  );
  final accessTokens = HmacSha256AccessTokenService(secret: 'test-secret');
  final loginLimiter = FakeLoginAttemptLimiter(maxAttempts: 3);
  final otpRateLimiter = FakeOtpRateLimiter(maxAttempts: 3);
  final googleVerifier = FakeOAuthProviderVerifier(
    provider: protocol.AuthProvider.google,
  );
  final githubVerifier = FakeOAuthProviderVerifier(
    provider: protocol.AuthProvider.github,
  );

  late final AuthTokenIssuer issuer;
  late final EmailVerificationService emailVerification;
  late final RegisterWithUsernameUseCase register;
  late final LoginWithUsernameUseCase login;
  late final LoginWithOAuthUseCase oauthLogin;
  late final RefreshSessionUseCase refresh;
  late final LogoutUseCase logout;
  late final PasswordResetService passwordReset;
  late final ChangePasswordUseCase changePassword;
  late final ChangeEmailUseCase changeEmail;
}

class FakeOAuthProviderVerifier implements OAuthProviderVerifier {
  FakeOAuthProviderVerifier({required this.provider});

  @override
  final protocol.AuthProvider provider;

  OAuthProviderProfile nextProfile = const OAuthProviderProfile(
    provider: protocol.AuthProvider.google,
    providerUserId: 'provider-user-1',
    email: 'oauth@example.com',
    emailVerified: true,
  );

  @override
  Future<OAuthProviderProfile> verify(
    Session session, {
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    if (code == 'invalid-code') {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    return OAuthProviderProfile(
      provider: provider,
      providerUserId: nextProfile.providerUserId,
      email: nextProfile.email,
      emailVerified: nextProfile.emailVerified,
    );
  }
}
