import '../../application/exceptions/auth_use_case_exception.dart';
import '../../application/interfaces/username_policy.dart';

class DefaultUsernamePolicy implements UsernamePolicy {
  const DefaultUsernamePolicy({
    this.minLength = 3,
    this.maxLength = 32,
  });

  static final _usernamePattern = RegExp(
    r'^[a-z0-9](?:[a-z0-9_.-]*[a-z0-9])?$',
  );
  static final _repeatedSeparatorPattern = RegExp(r'[_.-]{2,}');

  final int minLength;
  final int maxLength;

  @override
  void validate(String username) {
    if (username.length < minLength ||
        username.length > maxLength ||
        !_usernamePattern.hasMatch(username) ||
        _repeatedSeparatorPattern.hasMatch(username)) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidUsername,
      );
    }
  }
}
