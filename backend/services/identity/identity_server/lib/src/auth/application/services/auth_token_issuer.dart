import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../constants/auth_token_defaults.dart';
import '../../domain/auth_claims.dart';
import '../../domain/auth_result.dart';
import '../../domain/auth_token_transport.dart';
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/access_token_service.dart';
import '../interfaces/auth_cookie_service.dart';
import '../interfaces/auth_refresh_token_repository.dart';
import '../interfaces/auth_session_repository.dart';
import '../interfaces/refresh_token_codec.dart';
import '../interfaces/refresh_token_secret_service.dart';

class AuthTokenIssuer {
  const AuthTokenIssuer({
    required AuthSessionRepository authSessionRepository,
    required AuthRefreshTokenRepository authRefreshTokenRepository,
    required AccessTokenService accessTokenService,
    required RefreshTokenSecretService refreshTokenSecretService,
    required RefreshTokenCodec refreshTokenCodec,
    required AuthCookieService authCookieService,
  }) : _authSessionRepository = authSessionRepository,
       _authRefreshTokenRepository = authRefreshTokenRepository,
       _accessTokenService = accessTokenService,
       _refreshTokenSecretService = refreshTokenSecretService,
       _refreshTokenCodec = refreshTokenCodec,
       _authCookieService = authCookieService;

  final AuthSessionRepository _authSessionRepository;
  final AuthRefreshTokenRepository _authRefreshTokenRepository;
  final AccessTokenService _accessTokenService;
  final RefreshTokenSecretService _refreshTokenSecretService;
  final RefreshTokenCodec _refreshTokenCodec;
  final AuthCookieService _authCookieService;

  Future<AuthResult> issue(
    Session session, {
    required protocol.Identity identity,
    required protocol.AuthProvider authMethod,
    AuthTokenTransport tokenTransport = AuthTokenTransport.cookie,
  }) async {
    final identityId = identity.id;
    if (identityId == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.missingGeneratedId,
      );
    }

    final now = DateTime.now().toUtc();
    final authSession = await _authSessionRepository.create(
      session,
      identityId: identityId,
      expiresAt: now.add(AuthTokenDefaults.refreshTokenLifetime),
      authMethod: authMethod,
    );

    final authSessionId = authSession.id;
    if (authSessionId == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.missingGeneratedId,
      );
    }

    final accessToken = _accessTokenService.createAccessToken(
      AuthClaims.access(
        identityId: identityId,
        sessionId: authSessionId,
        emailVerified: identity.emailVerified,
        authenticationMethods: [authMethod],
        issuedAt: now,
      ),
    );

    final refreshSecret = await _refreshTokenSecretService.createSecret();
    final refreshToken = await _authRefreshTokenRepository.create(
      session,
      authSessionId: authSessionId,
      tokenHash: refreshSecret.hash,
      expiresAt: now.add(AuthTokenDefaults.refreshTokenLifetime),
    );

    final refreshTokenId = refreshToken.id;
    if (refreshTokenId == null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.missingGeneratedId,
      );
    }

    final refreshCookieValue = _refreshTokenCodec.encode(
      refreshTokenId: refreshTokenId,
      secret: refreshSecret.raw,
    );

    return AuthResult(
      identityId: identityId,
      authSessionId: authSessionId,
      accessToken: accessToken,
      refreshToken: refreshCookieValue,
      includeTokensInBody: tokenTransport == AuthTokenTransport.body,
      responseHeaders: switch (tokenTransport) {
        AuthTokenTransport.cookie => _authCookieService.createAuthCookies(
          accessToken: accessToken,
          refreshToken: refreshCookieValue,
        ),
        AuthTokenTransport.body => const {},
      },
    );
  }
}
