class AuthCookieOptions {
  const AuthCookieOptions({
    required this.secure,
    required this.sameSite,
    required this.accessTokenPath,
    required this.refreshTokenPath,
    required this.accessTokenMaxAge,
    required this.refreshTokenMaxAge,
    this.domain,
  });

  factory AuthCookieOptions.development() {
    return const AuthCookieOptions(
      secure: false,
      sameSite: 'Lax',
      accessTokenPath: '/',
      refreshTokenPath: '/auth',
      accessTokenMaxAge: Duration(minutes: 15),
      refreshTokenMaxAge: Duration(days: 30),
    );
  }

  factory AuthCookieOptions.production({String? domain}) {
    return AuthCookieOptions(
      secure: true,
      sameSite: 'Lax',
      domain: domain,
      accessTokenPath: '/',
      refreshTokenPath: '/auth',
      accessTokenMaxAge: const Duration(minutes: 15),
      refreshTokenMaxAge: const Duration(days: 30),
    );
  }

  final bool secure;
  final String sameSite;
  final String accessTokenPath;
  final String refreshTokenPath;
  final Duration accessTokenMaxAge;
  final Duration refreshTokenMaxAge;
  final String? domain;
}
