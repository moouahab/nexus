import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/infrastructure/validation/default_email_policy.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultEmailPolicy', () {
    const policy = DefaultEmailPolicy();

    test('accepts absent and well-formed emails', () {
      expect(() => policy.validate(null), returnsNormally);
      expect(() => policy.validate('noxe@example.com'), returnsNormally);
      expect(() => policy.validate('noxe.dev@example.co.uk'), returnsNormally);
    });

    test('rejects malformed emails', () {
      for (final email in [
        'not-an-email',
        'noxe@localhost',
        'noxe@example',
        'noxe @example.com',
        'noxe@example..com',
      ]) {
        expect(
          () => policy.validate(email),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidEmail),
        );
      }
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
