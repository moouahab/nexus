import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/api_config.dart';
import 'auth_api.dart';
import 'google_oauth_authorization.dart';

class GoogleOAuthService {
  GoogleOAuthService();

  static const _scopes = <String>['openid', 'email', 'profile'];

  var _initialized = false;

  Future<void> warmUp() async {
    if (!OAuthConfig.isGooglePlatformSupported ||
        !OAuthConfig.isGoogleConfigured) {
      return;
    }

    await _initialize();
  }

  Future<GoogleOAuthAuthorization> requestAuthorization() async {
    final code = await requestServerAuthCode();
    return GoogleOAuthAuthorization(
      code: code,
      redirectUri: OAuthConfig.googleRedirectUri,
    );
  }

  Future<String> requestServerAuthCode() async {
    if (!OAuthConfig.isGooglePlatformSupported) {
      throw const AuthApiException(
        'Connexion Google non supportée sur cette plateforme pour le moment.',
      );
    }

    if (!OAuthConfig.isGoogleConfigured) {
      throw const AuthApiException(
        'GOOGLE_OAUTH_SERVER_CLIENT_ID est manquant au lancement de l’app.',
      );
    }

    await _initialize();

    final signIn = GoogleSignIn.instance;
    GoogleSignInAccount? account;
    if (signIn.supportsAuthenticate()) {
      account = await signIn.authenticate(scopeHint: _scopes);
      debugPrint('[OAuth] Account selected');
    }

    final authorizationClient =
        account?.authorizationClient ?? signIn.authorizationClient;
    final serverAuth = await authorizationClient.authorizeServer(_scopes);
    final serverAuthCode = serverAuth?.serverAuthCode;
    if (serverAuthCode == null || serverAuthCode.isEmpty) {
      throw const AuthApiException(
        'Google n’a pas retourné de code serveur. Reconnectez le compte.',
      );
    }

    debugPrint('[OAuth] Token received');
    return serverAuthCode;
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    await GoogleSignIn.instance.initialize(
      clientId: OAuthConfig.googleClientId.isEmpty
          ? null
          : OAuthConfig.googleClientId,
      serverClientId: kIsWeb || OAuthConfig.googleServerClientId.isEmpty
          ? null
          : OAuthConfig.googleServerClientId,
    );

    unawaited(GoogleSignIn.instance.attemptLightweightAuthentication());
    _initialized = true;
  }

  String messageForError(Object error) {
    if (error is GoogleSignInException) {
      return switch (error.code) {
        GoogleSignInExceptionCode.canceled => 'Connexion Google annulée.',
        GoogleSignInExceptionCode.interrupted =>
          'Connexion Google interrompue.',
        GoogleSignInExceptionCode.uiUnavailable =>
          'Interface Google indisponible sur cette plateforme.',
        _ => 'Connexion Google refusée. Vérifiez la configuration OAuth.',
      };
    }
    if (error is UnsupportedError) {
      return kIsWeb
          ? 'Connexion Google indisponible dans ce navigateur.'
          : 'Connexion Google non supportée sur cette plateforme.';
    }
    if (error is AuthApiException) {
      return error.message;
    }
    return 'Connexion Google impossible.';
  }
}
