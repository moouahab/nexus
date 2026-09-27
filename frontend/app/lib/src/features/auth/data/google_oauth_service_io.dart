import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/api_config.dart';
import 'auth_api.dart';
import 'google_oauth_authorization.dart';

class GoogleOAuthService {
  GoogleOAuthService();

  static const _scopes = <String>['openid', 'email', 'profile'];
  static const _linuxCallbackPath = '/oauth/google/callback';
  static const _linuxCallbackPort = 53682;

  var _initialized = false;

  Future<void> warmUp() async {
    if (!OAuthConfig.isGooglePlatformSupported ||
        !OAuthConfig.isGoogleConfigured ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return;
    }

    await _initialize();
  }

  Future<GoogleOAuthAuthorization> requestAuthorization() async {
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

    if (defaultTargetPlatform == TargetPlatform.linux) {
      return _requestLinuxDesktopAuthorization();
    }

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

    return serverAuthCode;
  }

  Future<GoogleOAuthAuthorization> _requestLinuxDesktopAuthorization() async {
    final HttpServer server;
    try {
      server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        _linuxCallbackPort,
      );
    } on SocketException {
      throw const AuthApiException(
        'Le port de callback Google local est déjà utilisé. Réessayez.',
      );
    }
    final redirectUri = Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: server.port,
      path: _linuxCallbackPath,
    ).toString();
    final state = _randomUrlSafeString(32);
    final codeVerifier = _randomUrlSafeString(64);
    final codeChallenge = _base64UrlNoPadding(
      sha256.convert(utf8.encode(codeVerifier)).bytes,
    );

    final authorizationUri =
        Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
          'client_id': OAuthConfig.googleServerClientId,
          'redirect_uri': redirectUri,
          'response_type': 'code',
          'scope': _scopes.join(' '),
          'state': state,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'access_type': 'offline',
          'prompt': 'select_account',
        });

    try {
      await _openBrowser(authorizationUri);

      final request = await server.first.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          throw const AuthApiException('Connexion Google expirée. Réessayez.');
        },
      );
      return _handleLinuxCallback(
        request,
        expectedState: state,
        redirectUri: redirectUri,
        codeVerifier: codeVerifier,
      );
    } finally {
      await server.close(force: true);
    }
  }

  Future<GoogleOAuthAuthorization> _handleLinuxCallback(
    HttpRequest request, {
    required String expectedState,
    required String redirectUri,
    required String codeVerifier,
  }) async {
    Future<void> closePage({
      required String title,
      required String message,
      required bool autoClose,
    }) async {
      final closeScript = autoClose
          ? '''
<script>
  window.opener = null;
  setTimeout(function () { window.close(); }, 250);
</script>
'''
          : '';
      final body = utf8.encode('''
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Nexus</title>
  $closeScript
</head>
<body>
  <h1>$title</h1>
  <p>$message</p>
</body>
</html>
''');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
        ..headers.set(HttpHeaders.connectionHeader, 'close')
        ..contentLength = body.length
        ..add(body);
      await request.response.flush();
      await request.response.close();
    }

    if (request.uri.path != _linuxCallbackPath) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      throw const AuthApiException('Callback Google invalide.');
    }

    final error = request.uri.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      await closePage(
        title: 'Connexion annulée',
        message: 'Vous pouvez fermer cette fenêtre.',
        autoClose: false,
      );
      throw const AuthApiException('Connexion Google annulée.');
    }

    final state = request.uri.queryParameters['state'];
    final code = request.uri.queryParameters['code'];
    if (state != expectedState || code == null || code.isEmpty) {
      await closePage(
        title: 'Connexion invalide',
        message: 'Vous pouvez fermer cette fenêtre.',
        autoClose: false,
      );
      throw const AuthApiException('Réponse Google invalide.');
    }

    debugPrint('[OAuth] Account selected');
    debugPrint('[OAuth] Token received');
    await closePage(
      title: 'Connexion terminée',
      message:
          'Nexus a reçu la réponse Google. Cette fenêtre peut se fermer automatiquement.',
      autoClose: true,
    );
    return GoogleOAuthAuthorization(
      code: code,
      redirectUri: redirectUri,
      codeVerifier: codeVerifier,
    );
  }

  Future<void> _openBrowser(Uri uri) async {
    final url = uri.toString();
    for (final command in const ['wslview', 'xdg-open', 'sensible-browser']) {
      try {
        final result = await Process.run(command, [url]);
        if (result.exitCode == 0) return;
      } on ProcessException {
        continue;
      }
    }

    throw const AuthApiException(
      'Impossible d’ouvrir le navigateur pour Google.',
    );
  }

  String _randomUrlSafeString(int byteCount) {
    final random = Random.secure();
    final bytes = List<int>.generate(byteCount, (_) => random.nextInt(256));
    return _base64UrlNoPadding(bytes);
  }

  String _base64UrlNoPadding(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    await GoogleSignIn.instance.initialize(
      clientId: OAuthConfig.googleClientId.isEmpty
          ? null
          : OAuthConfig.googleClientId,
      serverClientId: OAuthConfig.googleServerClientId.isEmpty
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
      return 'Connexion Google non supportée sur cette plateforme.';
    }
    if (error is AuthApiException) {
      return error.message;
    }
    return 'Connexion Google impossible.';
  }
}
