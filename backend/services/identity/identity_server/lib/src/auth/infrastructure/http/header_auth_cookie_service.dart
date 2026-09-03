import 'dart:convert';
import 'dart:math';

import '../../application/interfaces/auth_cookie_service.dart';
import '../../constants/auth_cookie_names.dart';
import '../../domain/auth_cookie_options.dart';

class HeaderAuthCookieService implements AuthCookieService {
  HeaderAuthCookieService({
    required AuthCookieOptions options,
    Random? random,
  }) : _options = options,
       _random = random ?? Random.secure();

  static const _setCookieHeader = 'set-cookie';
  static const _cookieHeader = 'cookie';

  final AuthCookieOptions _options;
  final Random _random;

  @override
  Map<String, List<String>> createAuthCookies({
    required String accessToken,
    required String refreshToken,
  }) {
    return {
      _setCookieHeader: [
        _buildCookie(
          name: AuthCookieNames.accessToken,
          value: accessToken,
          path: _options.accessTokenPath,
          maxAge: _options.accessTokenMaxAge,
        ),
        _buildCookie(
          name: AuthCookieNames.refreshToken,
          value: refreshToken,
          path: _options.refreshTokenPath,
          maxAge: _options.refreshTokenMaxAge,
        ),
        _buildCookie(
          name: AuthCookieNames.csrfToken,
          value: _generateCsrfToken(),
          path: _options.accessTokenPath,
          maxAge: _options.refreshTokenMaxAge,
          httpOnly: false,
        ),
      ],
    };
  }

  @override
  Map<String, List<String>> clearAuthCookies() {
    return {
      _setCookieHeader: [
        _buildCookie(
          name: AuthCookieNames.accessToken,
          value: '',
          path: _options.accessTokenPath,
          maxAge: Duration.zero,
        ),
        _buildCookie(
          name: AuthCookieNames.refreshToken,
          value: '',
          path: _options.refreshTokenPath,
          maxAge: Duration.zero,
        ),
        _buildCookie(
          name: AuthCookieNames.csrfToken,
          value: '',
          path: _options.accessTokenPath,
          maxAge: Duration.zero,
          httpOnly: false,
        ),
      ],
    };
  }

  @override
  String? readCookie({
    required Map<String, List<String>> headers,
    required String name,
  }) {
    final cookieValues = <String>[];
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == _cookieHeader) {
        cookieValues.addAll(entry.value);
      }
    }

    if (cookieValues.isEmpty) return null;
    for (final header in cookieValues) {
      for (final part in header.split(';')) {
        final separatorIndex = part.indexOf('=');
        if (separatorIndex <= 0) continue;
        final cookieName = part.substring(0, separatorIndex).trim();
        if (cookieName != name) continue;
        return part.substring(separatorIndex + 1).trim();
      }
    }

    return null;
  }

  String _buildCookie({
    required String name,
    required String value,
    required String path,
    required Duration maxAge,
    bool httpOnly = true,
  }) {
    final parts = [
      '$name=$value',
      'Path=$path',
      'Max-Age=${maxAge.inSeconds}',
      if (httpOnly) 'HttpOnly',
      'SameSite=${_options.sameSite}',
      if (_options.secure) 'Secure',
      if (_options.domain != null) 'Domain=${_options.domain}',
    ];

    return parts.join('; ');
  }

  String _generateCsrfToken() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
