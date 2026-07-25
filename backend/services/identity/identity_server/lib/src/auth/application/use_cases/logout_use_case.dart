import 'package:serverpod/serverpod.dart';

import '../../constants/auth_cookie_names.dart';
import '../../domain/auth_result.dart';
import '../../domain/refresh_token_cookie_value.dart';
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/auth_cookie_service.dart';
import '../interfaces/auth_refresh_token_repository.dart';
import '../interfaces/auth_session_repository.dart';
import '../interfaces/refresh_token_codec.dart';

class LogoutUseCase {
  const LogoutUseCase({
    required AuthSessionRepository authSessionRepository,
    required AuthRefreshTokenRepository authRefreshTokenRepository,
    required RefreshTokenCodec refreshTokenCodec,
    required AuthCookieService authCookieService,
  }) : _authSessionRepository = authSessionRepository,
       _authRefreshTokenRepository = authRefreshTokenRepository,
       _refreshTokenCodec = refreshTokenCodec,
       _authCookieService = authCookieService;

  final AuthSessionRepository _authSessionRepository;
  final AuthRefreshTokenRepository _authRefreshTokenRepository;
  final RefreshTokenCodec _refreshTokenCodec;
  final AuthCookieService _authCookieService;

  Future<AuthResult> execute(
    Session session, {
    required Map<String, List<String>> requestHeaders,
  }) async {
    final refreshCookie = _authCookieService.readCookie(
      headers: requestHeaders,
      name: AuthCookieNames.refreshToken,
    );

    if (refreshCookie == null) {
      return _clearedResult();
    }

    final parsedRefreshToken = _decodeRefreshToken(refreshCookie);
    final refreshToken = await _authRefreshTokenRepository.findById(
      session,
      parsedRefreshToken.refreshTokenId,
    );

    if (refreshToken == null) {
      return _clearedResult();
    }

    await _authRefreshTokenRepository.revoke(
      session,
      parsedRefreshToken.refreshTokenId,
    );
    await _authSessionRepository.revoke(session, refreshToken.authSessionId);

    return AuthResult(
      authSessionId: refreshToken.authSessionId,
      responseHeaders: _authCookieService.clearAuthCookies(),
    );
  }

  AuthResult _clearedResult() {
    return AuthResult(
      responseHeaders: _authCookieService.clearAuthCookies(),
    );
  }

  RefreshTokenCookieValue _decodeRefreshToken(String refreshCookie) {
    try {
      return _refreshTokenCodec.decode(refreshCookie);
    } on FormatException {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidRefreshToken,
      );
    }
  }
}
