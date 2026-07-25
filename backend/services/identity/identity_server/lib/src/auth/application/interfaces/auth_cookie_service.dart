abstract interface class AuthCookieService {
  Map<String, List<String>> createAuthCookies({
    required String accessToken,
    required String refreshToken,
  });

  Map<String, List<String>> clearAuthCookies();

  String? readCookie({
    required Map<String, List<String>> headers,
    required String name,
  });
}
