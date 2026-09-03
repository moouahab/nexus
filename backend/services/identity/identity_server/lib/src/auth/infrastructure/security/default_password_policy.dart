import '../../application/exceptions/auth_use_case_exception.dart';
import '../../application/interfaces/password_policy.dart';

class DefaultPasswordPolicy implements PasswordPolicy {
  const DefaultPasswordPolicy({
    this.minLength = 12,
    this.maxLength = 128,
  });

  static const _blockedPasswords = {
    'password',
    'password1',
    'password12',
    'password123',
    'qwerty123456',
    '123456789012',
    'changeme1234',
    'letmein12345',
  };

  final int minLength;
  final int maxLength;

  @override
  void validate({
    required String password,
    required String username,
    String? email,
  }) {
    final normalizedPassword = password.trim().toLowerCase();
    final normalizedUsername = username.trim().toLowerCase();
    final normalizedEmail = email?.trim().toLowerCase();
    final emailLocalPart = normalizedEmail?.split('@').first;

    if (password.length < minLength ||
        password.length > maxLength ||
        normalizedPassword.isEmpty ||
        _blockedPasswords.contains(normalizedPassword) ||
        _containsToken(normalizedPassword, normalizedUsername) ||
        _containsToken(normalizedPassword, normalizedEmail) ||
        _containsToken(normalizedPassword, emailLocalPart)) {
      throw const AuthUseCaseException(AuthUseCaseExceptionCode.weakPassword);
    }
  }

  bool _containsToken(String password, String? token) {
    if (token == null || token.length < 4) return false;
    return password.contains(token);
  }
}
