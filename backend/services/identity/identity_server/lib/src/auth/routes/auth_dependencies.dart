import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart' as protocol;
import '../application/services/auth_token_issuer.dart';
import '../application/services/email_verification_service.dart';
import '../application/services/password_reset_service.dart';
import '../application/services/require_auth.dart';
import '../application/services/service_token_issuer.dart';
import '../application/use_cases/change_email_use_case.dart';
import '../application/use_cases/change_password_use_case.dart';
import '../application/interfaces/auth_cookie_service.dart';
import '../application/interfaces/access_token_service.dart';
import '../application/interfaces/email_verification_sender.dart';
import '../application/interfaces/oauth_provider_verifier.dart';
import '../application/interfaces/password_reset_sender.dart';
import '../application/interfaces/service_token_service.dart';
import '../application/use_cases/login_with_username_use_case.dart';
import '../application/use_cases/login_with_oauth_use_case.dart';
import '../application/use_cases/logout_use_case.dart';
import '../application/use_cases/refresh_session_use_case.dart';
import '../application/use_cases/register_with_username_use_case.dart';
import '../domain/auth_cookie_options.dart';
import '../infrastructure/http/header_auth_cookie_service.dart';
import '../infrastructure/http/header_access_token_reader.dart';
import '../infrastructure/http/csrf_protection.dart';
import '../infrastructure/oauth/apple_oauth_provider_verifier.dart';
import '../infrastructure/oauth/github_oauth_provider_verifier.dart';
import '../infrastructure/oauth/google_oauth_provider_verifier.dart';
import '../infrastructure/email/log_email_verification_sender.dart';
import '../infrastructure/email/log_password_reset_sender.dart';
import '../infrastructure/email/smtp_email_verification_sender.dart';
import '../infrastructure/email/smtp_mail_config.dart';
import '../infrastructure/email/smtp_password_reset_sender.dart';
import '../infrastructure/repositories/serverpod_auth_refresh_token_repository.dart';
import '../infrastructure/repositories/serverpod_auth_session_repository.dart';
import '../infrastructure/repositories/serverpod_email_verification_code_repository.dart';
import '../infrastructure/repositories/serverpod_identity_provider_repository.dart';
import '../infrastructure/repositories/serverpod_identity_repository.dart';
import '../infrastructure/repositories/serverpod_password_credential_repository.dart';
import '../infrastructure/repositories/serverpod_password_reset_code_repository.dart';
import '../infrastructure/security/argon2_password_hasher.dart';
import '../infrastructure/security/argon2_secret_hasher.dart';
import '../infrastructure/security/colon_refresh_token_codec.dart';
import '../infrastructure/security/default_password_policy.dart';
import '../infrastructure/security/hmac_sha256_access_token_service.dart';
import '../infrastructure/security/numeric_verification_code_generator.dart';
import '../infrastructure/security/redis_login_attempt_limiter.dart';
import '../infrastructure/security/redis_otp_rate_limiter.dart';
import '../infrastructure/security/rs256_access_token_service.dart';
import '../infrastructure/security/secure_refresh_token_secret_service.dart';
import '../infrastructure/security/static_service_client_registry.dart';
import '../infrastructure/validation/default_email_policy.dart';
import '../infrastructure/validation/default_username_policy.dart';

class AuthDependencies {
  AuthDependencies._({
    required this.registerWithUsername,
    required this.loginWithUsername,
    required this.loginWithOAuth,
    required this.refreshSession,
    required this.logout,
    required this.changePassword,
    required this.changeEmail,
    required this.requireAuth,
    required this.csrfProtection,
    required this.authCookieService,
    required this.emailVerificationService,
    required this.passwordResetService,
    required this.serviceTokenIssuer,
  });

  static const _loginAttemptLimiter = RedisLoginAttemptLimiter();
  static const _otpRateLimiter = RedisOtpRateLimiter();

  factory AuthDependencies.fromSession(Session session) {
    final passwordPepper = _requiredPassword(
      session,
      'emailSecretHashPepper',
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
    final emailVerificationCodeRepository =
        ServerpodEmailVerificationCodeRepository();
    final passwordResetCodeRepository = ServerpodPasswordResetCodeRepository();

    const usernamePolicy = DefaultUsernamePolicy();
    const emailPolicy = DefaultEmailPolicy();
    final passwordHasher = Argon2PasswordHasher(pepper: passwordPepper);
    const passwordPolicy = DefaultPasswordPolicy();
    final accessTokenService = accessTokenServiceFromSession(session);
    final serviceTokenService = accessTokenService as ServiceTokenService;
    final secretHasher = Argon2SecretHasher(pepper: refreshPepper);
    final emailVerificationCodeHasher = Argon2SecretHasher(
      pepper: refreshPepper,
    );
    final refreshTokenSecretService = SecureRefreshTokenSecretService(
      secretHasher: secretHasher,
    );
    final smtpMailConfig = SmtpMailConfig.fromSession(session);
    final emailVerificationService = EmailVerificationService(
      codeRepository: emailVerificationCodeRepository,
      identityRepository: identityRepository,
      codeHasher: emailVerificationCodeHasher,
      codeGenerator: NumericVerificationCodeGenerator(),
      sender: _emailVerificationSender(smtpMailConfig),
      resendRateLimiter: _otpRateLimiter,
    );
    final passwordResetService = PasswordResetService(
      identityRepository: identityRepository,
      passwordCredentialRepository: passwordCredentialRepository,
      authSessionRepository: authSessionRepository,
      codeRepository: passwordResetCodeRepository,
      codeHasher: Argon2SecretHasher(pepper: refreshPepper),
      codeGenerator: NumericVerificationCodeGenerator(),
      sender: _passwordResetSender(smtpMailConfig),
      passwordHasher: passwordHasher,
      passwordPolicy: passwordPolicy,
      startRateLimiter: _otpRateLimiter,
    );
    final refreshTokenCodec = ColonRefreshTokenCodec();
    final authCookieService = HeaderAuthCookieService(
      options: _cookieOptions(session),
    );
    final csrfProtection = CsrfProtection(
      authCookieService: authCookieService,
    );
    final accessTokenReader = HeaderAccessTokenReader(
      authCookieService: authCookieService,
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
        usernamePolicy: usernamePolicy,
        emailPolicy: emailPolicy,
        passwordHasher: passwordHasher,
        passwordPolicy: passwordPolicy,
        authTokenIssuer: authTokenIssuer,
        emailVerificationService: emailVerificationService,
      ),
      loginWithUsername: LoginWithUsernameUseCase(
        identityRepository: identityRepository,
        passwordCredentialRepository: passwordCredentialRepository,
        passwordHasher: passwordHasher,
        loginAttemptLimiter: _loginAttemptLimiter,
        authTokenIssuer: authTokenIssuer,
      ),
      loginWithOAuth: LoginWithOAuthUseCase(
        identityRepository: identityRepository,
        identityProviderRepository: identityProviderRepository,
        verifiers: _oauthVerifiers(session),
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
      changePassword: ChangePasswordUseCase(
        passwordCredentialRepository: passwordCredentialRepository,
        authSessionRepository: authSessionRepository,
        passwordHasher: passwordHasher,
        passwordPolicy: passwordPolicy,
      ),
      changeEmail: ChangeEmailUseCase(
        identityRepository: identityRepository,
        identityProviderRepository: identityProviderRepository,
        authSessionRepository: authSessionRepository,
        emailPolicy: emailPolicy,
        emailVerificationService: emailVerificationService,
      ),
      requireAuth: RequireAuth(
        accessTokenService: accessTokenService,
        accessTokenReader: accessTokenReader,
        authSessionRepository: authSessionRepository,
        identityRepository: identityRepository,
      ),
      csrfProtection: csrfProtection,
      authCookieService: authCookieService,
      emailVerificationService: emailVerificationService,
      passwordResetService: passwordResetService,
      serviceTokenIssuer: ServiceTokenIssuer(
        clientRegistry: _serviceClientRegistry(session),
        tokenService: serviceTokenService,
      ),
    );
  }

  final RegisterWithUsernameUseCase registerWithUsername;
  final LoginWithUsernameUseCase loginWithUsername;
  final LoginWithOAuthUseCase loginWithOAuth;
  final RefreshSessionUseCase refreshSession;
  final LogoutUseCase logout;
  final ChangePasswordUseCase changePassword;
  final ChangeEmailUseCase changeEmail;
  final RequireAuth requireAuth;
  final CsrfProtection csrfProtection;
  final AuthCookieService authCookieService;
  final EmailVerificationService emailVerificationService;
  final PasswordResetService passwordResetService;
  final ServiceTokenIssuer serviceTokenIssuer;

  static AccessTokenService accessTokenServiceFromSession(Session session) {
    final privateKey = _optionalPassword(
      session,
      'jwtAccessTokenPrivateKeyPem',
    );
    final publicKey = _optionalPassword(session, 'jwtAccessTokenPublicKeyPem');
    final keyId =
        _optionalPassword(session, 'jwtAccessTokenKeyId') ??
        'identity-access-token-current';

    if (privateKey != null && publicKey != null) {
      return Rs256AccessTokenService(
        privateKeyPem: privateKey,
        publicKeyPem: publicKey,
        keyId: keyId,
      );
    }

    final hmacSecret = _requiredPassword(
      session,
      'jwtHmacSha512PrivateKey',
    );
    return HmacSha256AccessTokenService(secret: hmacSecret);
  }

  static String _requiredPassword(Session session, String key) {
    final value = session.passwords[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required auth secret: $key');
    }
    return value;
  }

  static AuthCookieOptions _cookieOptions(Session session) {
    final apiConfig = session.serverpod.config.apiServer;
    if (apiConfig.publicScheme == 'https') {
      return AuthCookieOptions.production();
    }

    return AuthCookieOptions.development();
  }

  static StaticServiceClientRegistry _serviceClientRegistry(Session session) {
    final registryJson = _optionalPassword(session, 'authServiceClients');
    if (registryJson == null) {
      return StaticServiceClientRegistry(const []);
    }
    return StaticServiceClientRegistry.fromJson(registryJson);
  }

  static EmailVerificationSender _emailVerificationSender(
    SmtpMailConfig? smtpMailConfig,
  ) {
    if (smtpMailConfig == null) return const LogEmailVerificationSender();
    return SmtpEmailVerificationSender(smtpMailConfig);
  }

  static PasswordResetSender _passwordResetSender(
    SmtpMailConfig? smtpMailConfig,
  ) {
    if (smtpMailConfig == null) return const LogPasswordResetSender();
    return SmtpPasswordResetSender(smtpMailConfig);
  }

  static Map<protocol.AuthProvider, OAuthProviderVerifier> _oauthVerifiers(
    Session session,
  ) {
    final verifiers = <protocol.AuthProvider, OAuthProviderVerifier>{};

    final googleEnabled = _optionalBooleanPassword(
      session,
      'googleOAuthEnabled',
    );
    final googleClientId = _optionalPassword(session, 'googleOAuthClientId');
    final googleClientSecret = _optionalPassword(
      session,
      'googleOAuthClientSecret',
    );
    if (googleEnabled && googleClientId != null && googleClientSecret != null) {
      verifiers[protocol.AuthProvider.google] = GoogleOAuthProviderVerifier(
        clientId: googleClientId,
        clientSecret: googleClientSecret,
      );
    }

    final githubEnabled = _optionalBooleanPassword(
      session,
      'githubOAuthEnabled',
    );
    final githubClientId = _optionalPassword(session, 'githubOAuthClientId');
    final githubClientSecret = _optionalPassword(
      session,
      'githubOAuthClientSecret',
    );
    if (githubEnabled && githubClientId != null && githubClientSecret != null) {
      verifiers[protocol.AuthProvider.github] = GitHubOAuthProviderVerifier(
        clientId: githubClientId,
        clientSecret: githubClientSecret,
      );
    }

    final appleEnabled = _optionalBooleanPassword(
      session,
      'appleOAuthEnabled',
    );
    final appleClientId = _optionalPassword(session, 'appleOAuthClientId');
    final appleClientSecret = _optionalPassword(
      session,
      'appleOAuthClientSecret',
    );
    if (appleEnabled && appleClientId != null && appleClientSecret != null) {
      verifiers[protocol.AuthProvider.apple] = AppleOAuthProviderVerifier(
        clientId: appleClientId,
        clientSecret: appleClientSecret,
      );
    }

    return verifiers;
  }

  static String? _optionalPassword(Session session, String key) {
    final value = session.passwords[key]?.trim();
    if (value == null || value.isEmpty || value == '<no value>') return null;
    return value;
  }

  static bool _optionalBooleanPassword(Session session, String key) {
    final value = session.passwords[key]?.trim().toLowerCase();
    return value == 'true' || value == '1' || value == 'yes' || value == 'on';
  }
}
