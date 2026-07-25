import 'package:serverpod/serverpod.dart';

import '../application/services/auth_token_issuer.dart';
import '../application/use_cases/login_with_username_use_case.dart';
import '../application/use_cases/logout_use_case.dart';
import '../application/use_cases/refresh_session_use_case.dart';
import '../application/use_cases/register_with_username_use_case.dart';
import '../domain/auth_cookie_options.dart';
import '../infrastructure/http/header_auth_cookie_service.dart';
import '../infrastructure/repositories/serverpod_auth_refresh_token_repository.dart';
import '../infrastructure/repositories/serverpod_auth_session_repository.dart';
import '../infrastructure/repositories/serverpod_identity_provider_repository.dart';
import '../infrastructure/repositories/serverpod_identity_repository.dart';
import '../infrastructure/repositories/serverpod_password_credential_repository.dart';
import '../infrastructure/security/argon2_password_hasher.dart';
import '../infrastructure/security/argon2_secret_hasher.dart';
import '../infrastructure/security/colon_refresh_token_codec.dart';
import '../infrastructure/security/hmac_sha256_access_token_service.dart';
import '../infrastructure/security/redis_login_attempt_limiter.dart';
import '../infrastructure/security/secure_refresh_token_secret_service.dart';

class AuthDependencies {
  AuthDependencies._({
    required this.registerWithUsername,
    required this.loginWithUsername,
    required this.refreshSession,
    required this.logout,
  });

  static const _loginAttemptLimiter = RedisLoginAttemptLimiter();

  factory AuthDependencies.fromSession(Session session) {
    final passwordPepper = _requiredPassword(
      session,
      'emailSecretHashPepper',
    );
    final jwtSecret = _requiredPassword(
      session,
      'jwtHmacSha512PrivateKey',
    );
    final refreshPepper = _requiredPassword(
      session,
      'jwtRefreshTokenHashPepper',
    );

    final identityRepository = ServerpodIdentityRepository();
    final identityProviderRepository = ServerpodIdentityProviderRepository();
    final passwordCredentialRepository =
        ServerpodPasswordCredentialRepository();
    final authSessionRepository = ServerpodAuthSessionRepository();
    final authRefreshTokenRepository = ServerpodAuthRefreshTokenRepository();

    final passwordHasher = Argon2PasswordHasher(pepper: passwordPepper);
    final accessTokenService = HmacSha256AccessTokenService(secret: jwtSecret);
    final secretHasher = Argon2SecretHasher(pepper: refreshPepper);
    final refreshTokenSecretService = SecureRefreshTokenSecretService(
      secretHasher: secretHasher,
    );
    final refreshTokenCodec = ColonRefreshTokenCodec();
    final authCookieService = HeaderAuthCookieService(
      options: _cookieOptions(session),
    );

    final authTokenIssuer = AuthTokenIssuer(
      authSessionRepository: authSessionRepository,
      authRefreshTokenRepository: authRefreshTokenRepository,
      accessTokenService: accessTokenService,
      refreshTokenSecretService: refreshTokenSecretService,
      refreshTokenCodec: refreshTokenCodec,
      authCookieService: authCookieService,
    );

    return AuthDependencies._(
      registerWithUsername: RegisterWithUsernameUseCase(
        identityRepository: identityRepository,
        identityProviderRepository: identityProviderRepository,
        passwordCredentialRepository: passwordCredentialRepository,
        passwordHasher: passwordHasher,
        authTokenIssuer: authTokenIssuer,
      ),
      loginWithUsername: LoginWithUsernameUseCase(
        identityRepository: identityRepository,
        passwordCredentialRepository: passwordCredentialRepository,
        passwordHasher: passwordHasher,
        loginAttemptLimiter: _loginAttemptLimiter,
        authTokenIssuer: authTokenIssuer,
      ),
      refreshSession: RefreshSessionUseCase(
        identityRepository: identityRepository,
        authSessionRepository: authSessionRepository,
        authRefreshTokenRepository: authRefreshTokenRepository,
        accessTokenService: accessTokenService,
        refreshTokenSecretService: refreshTokenSecretService,
        refreshTokenCodec: refreshTokenCodec,
        authCookieService: authCookieService,
      ),
      logout: LogoutUseCase(
        authSessionRepository: authSessionRepository,
        authRefreshTokenRepository: authRefreshTokenRepository,
        refreshTokenCodec: refreshTokenCodec,
        authCookieService: authCookieService,
      ),
    );
  }

  final RegisterWithUsernameUseCase registerWithUsername;
  final LoginWithUsernameUseCase loginWithUsername;
  final RefreshSessionUseCase refreshSession;
  final LogoutUseCase logout;

  static String _requiredPassword(Session session, String key) {
    final value = session.passwords[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required auth secret: $key');
    }
    return value;
  }

  static AuthCookieOptions _cookieOptions(Session session) {
    final webConfig = session.serverpod.config.webServer;
    if (webConfig?.publicScheme == 'https') {
      return AuthCookieOptions.production();
    }

    return AuthCookieOptions.development();
  }
}
