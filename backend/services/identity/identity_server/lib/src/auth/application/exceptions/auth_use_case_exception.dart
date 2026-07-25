class AuthUseCaseException implements Exception {
  const AuthUseCaseException(this.code);

  final AuthUseCaseExceptionCode code;

  @override
  String toString() => 'AuthUseCaseException: ${code.name}';
}

enum AuthUseCaseExceptionCode {
  invalidCredentials,
  identityNotFound,
  identityNotActive,
  identityAlreadyExists,
  usernameAlreadyExists,
  tooManyAttempts,
  missingRefreshToken,
  invalidRefreshToken,
  missingGeneratedId,
}
