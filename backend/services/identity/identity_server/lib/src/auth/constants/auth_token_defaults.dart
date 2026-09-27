class AuthTokenDefaults {
  const AuthTokenDefaults._();

  static const issuer = 'identity-service';
  static const audience = 'nexus-api';
  static const accessTokenLifetime = Duration(minutes: 15);
  static const serviceTokenLifetime = Duration(minutes: 5);
  static const refreshTokenLifetime = Duration(days: 30);
}
