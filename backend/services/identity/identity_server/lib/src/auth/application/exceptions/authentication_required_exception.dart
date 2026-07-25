class AuthenticationRequiredException implements Exception {
  const AuthenticationRequiredException(this.code);

  final AuthenticationRequiredExceptionCode code;

  @override
  String toString() => 'AuthenticationRequiredException: ${code.name}';
}

enum AuthenticationRequiredExceptionCode {
  missingAccessToken,
  invalidAccessToken,
  sessionNotFound,
  identityNotFound,
  identityNotActive,
}
