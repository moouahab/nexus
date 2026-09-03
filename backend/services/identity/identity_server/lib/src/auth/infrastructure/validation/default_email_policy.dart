import '../../application/exceptions/auth_use_case_exception.dart';
import '../../application/interfaces/email_policy.dart';

class DefaultEmailPolicy implements EmailPolicy {
  const DefaultEmailPolicy();

  static final _emailPattern = RegExp(
    r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$",
  );

  @override
  void validate(String? email) {
    if (email == null) return;

    if (email.length > 254 ||
        email.contains('..') ||
        !_emailPattern.hasMatch(email)) {
      throw const AuthUseCaseException(AuthUseCaseExceptionCode.invalidEmail);
    }
  }
}
