import 'package:identity_server/src/auth/application/exceptions/auth_use_case_exception.dart';
import 'package:identity_server/src/auth/infrastructure/validation/default_username_policy.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultUsernamePolicy', () {
    const policy = DefaultUsernamePolicy();

    test('accepts compact lowercase usernames', () {
      for (final username in ['noxe', 'noxe.dev', 'noxe-dev', 'noxe_dev']) {
        expect(() => policy.validate(username), returnsNormally);
      }
    });

    test('rejects malformed usernames', () {
      for (final username in [
        'no',
        '-noxe',
        'noxe-',
        'noxe..dev',
        'noxe<script>',
        'noxe dev',
        'noxe@dev',
        'a' * 33,
      ]) {
        expect(
          () => policy.validate(username),
          throwsAuthCode(AuthUseCaseExceptionCode.invalidUsername),
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
