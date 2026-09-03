import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../constants/auth_cookie_names.dart';
import '../../constants/auth_token_defaults.dart';
import '../../domain/auth_claims.dart';
import '../../domain/auth_result.dart';
import '../../domain/auth_token_transport.dart';
import '../../domain/refresh_token_cookie_value.dart';
import '../exceptions/auth_use_case_exception.dart';
import '../interfaces/access_token_service.dart';
import '../interfaces/auth_cookie_service.dart';
import '../interfaces/auth_refresh_token_repository.dart';
import '../interfaces/auth_session_repository.dart';
import '../interfaces/identity_repository.dart';
import '../interfaces/refresh_token_codec.dart';
import '../interfaces/refresh_token_secret_service.dart';
import '../services/auth_audit.dart';
import '../validation/termination_rule.dart';

class RefreshSessionUseCase {
  const RefreshSessionUseCase({
    required IdentityRepository identityRepository,
    required AuthSessionRepository authSessionRepository,
    required AuthRefreshTokenRepository authRefreshTokenRepository,
    required AccessTokenService accessTokenService,
    required RefreshTokenSecretService refreshTokenSecretService,
    required RefreshTokenCodec refreshTokenCodec,
    required AuthCookieService authCookieService,
  }) : _identityRepository = identityRepository,
       _authSessionRepository = authSessionRepository,
       _authRefreshTokenRepository = authRefreshTokenRepository,
       _accessTokenService = accessTokenService,
       _refreshTokenSecretService = refreshTokenSecretService,
       _refreshTokenCodec = refreshTokenCodec,
       _authCookieService = authCookieService;

  final IdentityRepository _identityRepository;
  final AuthSessionRepository _authSessionRepository;
  final AuthRefreshTokenRepository _authRefreshTokenRepository;
  final AccessTokenService _accessTokenService;
  final RefreshTokenSecretService _refreshTokenSecretService;
  final RefreshTokenCodec _refreshTokenCodec;
  final AuthCookieService _authCookieService;

  Future<AuthResult> execute(
    Session session, {
    required Map<String, List<String>> requestHeaders,
    String? refreshToken,
    AuthTokenTransport tokenTransport = AuthTokenTransport.cookie,
  }) async {
    final refreshCookie =
        refreshToken ??
        _authCookieService.readCookie(
          headers: requestHeaders,
          name: AuthCookieNames.refreshToken,
        );
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => refreshCookie == null,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.missingRefreshToken,
        ),
      ),
    ]);

    final parsedRefreshToken = _decodeRefreshToken(refreshCookie!);
    final activeRefreshToken = await _authRefreshTokenRepository.findActiveById(
      session,
      parsedRefreshToken.refreshTokenId,
    );
    if (activeRefreshToken == null) {
      AuthAudit.log(
        session,
        event: 'refresh',
        outcome: 'failure',
        reasonCode: AuthUseCaseExceptionCode.invalidRefreshToken.name,
      );
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidRefreshToken,
      );
    }

    final secretIsValid = await _refreshTokenSecretService.verifySecret(
      rawSecret: parsedRefreshToken.secret,
      secretHash: activeRefreshToken.tokenHash,
    );
    await AsyncTerminationRule.validateAll([
      AsyncTerminationRule(
        shouldTerminate: () async => !secretIsValid,
        beforeThrow: () async {
          await _authRefreshTokenRepository.revoke(
            session,
            parsedRefreshToken.refreshTokenId,
          );
          AuthAudit.log(
            session,
            event: 'refresh',
            outcome: 'failure',
            reasonCode: AuthUseCaseExceptionCode.invalidRefreshToken.name,
          );
        },
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.invalidRefreshToken,
        ),
      ),
    ]);

    final authSession = await _authSessionRepository.findActiveById(
      session,
      activeRefreshToken.authSessionId,
    );
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => authSession == null,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.invalidRefreshToken,
        ),
      ),
    ]);

    final identity = await _identityRepository.findById(
      session,
      authSession!.identityId,
    );
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => identity == null,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.identityNotFound,
        ),
      ),
      TerminationRule(
        shouldTerminate: () =>
            identity?.status != protocol.IdentityStatus.active,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.identityNotActive,
        ),
      ),
    ]);

    final now = DateTime.now().toUtc();
    final newSecret = await _refreshTokenSecretService.createSecret();
    final newRefreshToken = await _authRefreshTokenRepository.create(
      session,
      authSessionId: authSession.id!,
      tokenHash: newSecret.hash,
      expiresAt: now.add(AuthTokenDefaults.refreshTokenLifetime),
    );
    final newRefreshTokenId = newRefreshToken.id;
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => newRefreshTokenId == null,
        exception: const AuthUseCaseException(
          AuthUseCaseExceptionCode.missingGeneratedId,
        ),
      ),
    ]);

    await _authRefreshTokenRepository.rotate(
      session,
      oldTokenId: parsedRefreshToken.refreshTokenId,
      newTokenId: newRefreshTokenId!,
    );
    await _authSessionRepository.touch(session, authSession.id!);

    final accessToken = _accessTokenService.createAccessToken(
      AuthClaims.access(
        identityId: identity!.id!,
        sessionId: authSession.id!,
        emailVerified: identity.emailVerified,
        authenticationMethods: [authSession.authMethod],
        issuedAt: now,
      ),
    );

    final refreshCookieValue = _refreshTokenCodec.encode(
      refreshTokenId: newRefreshTokenId,
      secret: newSecret.raw,
    );

    final result = AuthResult(
      identityId: identity.id!,
      authSessionId: authSession.id!,
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
    AuthAudit.log(
      session,
      event: 'refresh',
      outcome: 'success',
      identityId: result.identityId,
      authSessionId: result.authSessionId,
      tokenTransport: tokenTransport.name,
    );
    return result;
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
