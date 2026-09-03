import '../../application/interfaces/access_token_reader.dart';
import '../../application/interfaces/auth_cookie_service.dart';
import '../../constants/auth_cookie_names.dart';

class HeaderAccessTokenReader implements AccessTokenReader {
  const HeaderAccessTokenReader({
    required AuthCookieService authCookieService,
  }) : _authCookieService = authCookieService;

  static const _authorizationHeader = 'authorization';

  final AuthCookieService _authCookieService;

  @override
  String? readAccessToken({
    required Map<String, List<String>> headers,
  }) {
    final cookieToken = _authCookieService.readCookie(
      headers: headers,
      name: AuthCookieNames.accessToken,
    );
    if (cookieToken != null && cookieToken.isNotEmpty) return cookieToken;

    final authorization = _firstHeader(headers, _authorizationHeader);
    if (authorization == null) return null;

    final parts = authorization.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) return null;
    if (parts.first.toLowerCase() != 'bearer') return null;
    if (parts.last.isEmpty) return null;

    return parts.last;
  }

  String? _firstHeader(Map<String, List<String>> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name && entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }

    return null;
  }
}
