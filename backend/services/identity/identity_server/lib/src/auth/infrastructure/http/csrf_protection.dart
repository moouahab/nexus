import '../../application/exceptions/auth_use_case_exception.dart';
import '../../application/interfaces/auth_cookie_service.dart';
import '../../constants/auth_cookie_names.dart';

class CsrfProtection {
  const CsrfProtection({
    required AuthCookieService authCookieService,
  }) : _authCookieService = authCookieService;

  static const headerName = 'X-CSRF-Token';

  final AuthCookieService _authCookieService;

  bool requiresProtection(Map<String, List<String>> headers) {
    return _readCookie(headers, AuthCookieNames.accessToken) != null ||
        _readCookie(headers, AuthCookieNames.refreshToken) != null;
  }

  void requireValid(Map<String, List<String>> headers) {
    final cookieToken = _readCookie(headers, AuthCookieNames.csrfToken);
    final headerToken = _readHeader(headers, headerName);

    if (cookieToken == null ||
        headerToken == null ||
        !_constantTimeEquals(cookieToken, headerToken)) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidCsrfToken,
      );
    }
  }

  String? _readCookie(Map<String, List<String>> headers, String name) {
    final value = _authCookieService.readCookie(
      headers: headers,
      name: name,
    );
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _readHeader(Map<String, List<String>> headers, String name) {
    final normalizedName = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == normalizedName && entry.value.isNotEmpty) {
        final value = entry.value.first.trim();
        if (value.isNotEmpty) return value;
      }
    }

    return null;
  }

  bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;

    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }
    return difference == 0;
  }
}
