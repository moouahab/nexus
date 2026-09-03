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
  emailAlreadyExists,
  invalidUsername,
  invalidEmail,
  weakPassword,
  missingEmail,
  invalidEmailVerificationCode,
  invalidPasswordResetCode,
  tooManyAttempts,
  missingRefreshToken,
  invalidRefreshToken,
  invalidCsrfToken,
  invalidOAuthProvider,
  invalidOAuthCredentials,
  oauthProviderNotConfigured,
  missingGeneratedId,
}
