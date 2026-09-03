import 'package:identity_server/src/auth/constants/auth_cookie_names.dart';
import 'package:identity_server/src/auth/domain/auth_cookie_options.dart';
import 'package:identity_server/src/auth/infrastructure/http/header_auth_cookie_service.dart';
import 'package:test/test.dart';

void main() {
  group('HeaderAuthCookieService', () {
    test('creates HttpOnly auth cookies with scoped paths', () {
      final service = HeaderAuthCookieService(
        options: AuthCookieOptions.development(),
      );

      final headers = service.createAuthCookies(
        accessToken: 'access.jwt',
        refreshToken: 'refresh.secret',
      );

      final cookies = headers['set-cookie']!;
      expect(cookies, hasLength(3));
      expect(cookies[0], contains('${AuthCookieNames.accessToken}=access.jwt'));
      expect(cookies[0], contains('Path=/'));
      expect(cookies[0], contains('HttpOnly'));
      expect(cookies[0], contains('SameSite=Lax'));
      expect(cookies[1], contains('${AuthCookieNames.refreshToken}='));
      expect(cookies[1], contains('Path=/auth'));
      expect(cookies[1], contains('HttpOnly'));
      expect(cookies[2], contains('${AuthCookieNames.csrfToken}='));
      expect(cookies[2], contains('Path=/'));
      expect(cookies[2], isNot(contains('HttpOnly')));
    });

    test('adds Secure flag in production', () {
      final service = HeaderAuthCookieService(
        options: AuthCookieOptions.production(domain: 'example.com'),
      );

      final cookies = service.createAuthCookies(
        accessToken: 'access.jwt',
        refreshToken: 'refresh.secret',
      )['set-cookie']!;

      expect(cookies.every((cookie) => cookie.contains('Secure')), isTrue);
      expect(
        cookies.every((cookie) => cookie.contains('Domain=example.com')),
        isTrue,
      );
    });

    test('clears auth cookies with Max-Age zero', () {
      final service = HeaderAuthCookieService(
        options: AuthCookieOptions.development(),
      );

      final cookies = service.clearAuthCookies()['set-cookie']!;

      expect(cookies, hasLength(3));
      expect(cookies.every((cookie) => cookie.contains('Max-Age=0')), isTrue);
    });

    test('reads cookies from request headers', () {
      final service = HeaderAuthCookieService(
        options: AuthCookieOptions.development(),
      );

      final value = service.readCookie(
        headers: {
          'cookie': [
            'theme=dark; ${AuthCookieNames.refreshToken}=refresh-value',
          ],
        },
        name: AuthCookieNames.refreshToken,
      );

      expect(value, 'refresh-value');
    });

    test('reads cookies from request headers regardless of header case', () {
      final service = HeaderAuthCookieService(
        options: AuthCookieOptions.development(),
      );

      final value = service.readCookie(
        headers: {
          'Cookie': [
            'theme=dark; ${AuthCookieNames.accessToken}=access-value',
          ],
        },
        name: AuthCookieNames.accessToken,
      );

      expect(value, 'access-value');
    });
  });
}
