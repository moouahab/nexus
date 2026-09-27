import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static const authUrl = 'http://127.0.0.1:8000/v1/auth';
}

abstract final class ApiAuthEndpoints {
  static const login = '/login';
  static const oauthLogin = '/oauth/login';
  static const register = '/register';
  static const me = '/me';
  static const refresh = '/refresh';
  static const logout = '/logout';
}

abstract final class OAuthConfig {
  static const _localGoogleWebClientId =
      '460524402163-bn2ic6e372jmang5la8j4j8iqfdvr8rs.apps.googleusercontent.com';
  static const _localGoogleRedirectUri = 'http://localhost:3000';

  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_WEB_CLIENT_ID',
    defaultValue: _localGoogleWebClientId,
  );
  static const googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_ANDROID_CLIENT_ID',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_IOS_CLIENT_ID',
  );
  static const googleMacosClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_MACOS_CLIENT_ID',
  );
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_SERVER_CLIENT_ID',
    defaultValue: _localGoogleWebClientId,
  );
  static const googleRedirectUri = String.fromEnvironment(
    'GOOGLE_OAUTH_REDIRECT_URI',
    defaultValue: _localGoogleRedirectUri,
  );

  static String get googleClientId {
    if (kIsWeb) return googleWebClientId;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => googleAndroidClientId,
      TargetPlatform.iOS => googleIosClientId,
      TargetPlatform.macOS => googleMacosClientId,
      TargetPlatform.linux => googleServerClientId,
      TargetPlatform.fuchsia || TargetPlatform.windows => '',
    };
  }

  static bool get isGooglePlatformSupported {
    if (kIsWeb) return true;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => true,
      TargetPlatform.fuchsia || TargetPlatform.windows => false,
    };
  }

  static bool get isGoogleConfigured =>
      isGooglePlatformSupported && googleServerClientId.isNotEmpty;
}
