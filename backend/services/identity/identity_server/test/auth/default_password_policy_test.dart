import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/infrastructure/security/default_password_policy.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultPasswordPolicy', () {
    const policy = DefaultPasswordPolicy();

    test('accepts a long password unrelated to the account identifiers', () {
      expect(
        () => policy.validate(
          password: 'correct-horse-battery',
          username: 'noxe',
          email: 'noxe@example.com',
        ),
        returnsNormally,
      );
    });

    test('rejects short, common, and account-derived passwords', () {
      expect(
        () => policy.validate(password: 'short', username: 'noxe'),
        throwsAuthCode(AuthUseCaseExceptionCode.weakPassword),
      );
      expect(
        () => policy.validate(password: 'password123', username: 'noxe'),
        throwsAuthCode(AuthUseCaseExceptionCode.weakPassword),
      );
      expect(
        () => policy.validate(
          password: 'noxe-password-123',
          username: 'noxe',
        ),
        throwsAuthCode(AuthUseCaseExceptionCode.weakPassword),
      );
      expect(
        () => policy.validate(
          password: 'prefix-noxe@example.com',
          username: 'other',
          email: 'noxe@example.com',
        ),
        throwsAuthCode(AuthUseCaseExceptionCode.weakPassword),
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
