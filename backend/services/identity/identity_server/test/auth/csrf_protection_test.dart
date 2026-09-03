import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/constants/auth_cookie_names.dart';
import 'package:identity_server/src/auth/domain/auth_cookie_options.dart';
import 'package:identity_server/src/auth/infrastructure/http/csrf_protection.dart';
import 'package:identity_server/src/auth/infrastructure/http/header_auth_cookie_service.dart';
import 'package:test/test.dart';

void main() {
  group('CsrfProtection', () {
    final cookieService = HeaderAuthCookieService(
      options: AuthCookieOptions.development(),
    );
    final protection = CsrfProtection(authCookieService: cookieService);

    test('requires protection when auth cookies are present', () {
      expect(
        protection.requiresProtection({
          'cookie': ['${AuthCookieNames.refreshToken}=refresh-token'],
        }),
        isTrue,
      );
      expect(protection.requiresProtection(const {}), isFalse);
    });

    test('accepts matching csrf cookie and header', () {
      expect(
        () => protection.requireValid({
          'cookie': ['${AuthCookieNames.csrfToken}=csrf-token'],
          'x-csrf-token': ['csrf-token'],
        }),
        returnsNormally,
      );
    });

    test('rejects missing or mismatched csrf values', () {
      expect(
        () => protection.requireValid({
          'cookie': ['${AuthCookieNames.csrfToken}=csrf-token'],
        }),
        throwsAuthCode(AuthUseCaseExceptionCode.invalidCsrfToken),
      );
      expect(
        () => protection.requireValid({
          'cookie': ['${AuthCookieNames.csrfToken}=csrf-token'],
          'X-CSRF-Token': ['wrong-token'],
        }),
        throwsAuthCode(AuthUseCaseExceptionCode.invalidCsrfToken),
      );
    });
  });
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
