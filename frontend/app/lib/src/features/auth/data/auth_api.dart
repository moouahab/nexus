import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import 'auth_http_client.dart'
    if (dart.library.js_interop) 'auth_http_client_web.dart';

class AuthLoginResult {
  const AuthLoginResult({
    required this.identityId,
    required this.authSessionId,
    this.tokenType,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.refreshExpiresIn,
  });

  final String identityId;
  final String authSessionId;
  final String? tokenType;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final int? refreshExpiresIn;

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    return AuthLoginResult(
      identityId: _readString(json, 'identityId'),
      authSessionId: _readString(json, 'authSessionId'),
      tokenType: _readOptionalString(json, 'tokenType'),
      accessToken: _readOptionalString(json, 'accessToken'),
      refreshToken: _readOptionalString(json, 'refreshToken'),
      expiresIn: _readOptionalInt(json, 'expiresIn'),
      refreshExpiresIn: _readOptionalInt(json, 'refreshExpiresIn'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw const FormatException('Invalid auth response.');
  }

  static String? _readOptionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    throw const FormatException('Invalid auth response.');
  }

  static int? _readOptionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    throw const FormatException('Invalid auth response.');
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? createAuthHttpClient();

  final http.Client _client;

  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.authUrl}${ApiAuthEndpoints.login}');

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: _jsonHeaders(),
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const AuthApiException('Le serveur ne répond pas.');
    } on http.ClientException {
      throw const AuthApiException('Impossible de joindre le serveur.');
    }

    final body = _decodeBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthLoginResult.fromJson(body);
    }

    throw AuthApiException(_messageForError(response.statusCode, body));
  }

  Future<AuthLoginResult> register({
    required String username,
    required String password,
    required String confirmPassword,
    String? email,
  }) async {
    final uri = Uri.parse('${ApiConfig.authUrl}${ApiAuthEndpoints.register}');
    final requestBody = {
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      if (!kIsWeb) 'tokenTransport': 'body',
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    };

    http.Response response;
    try {
      response = await _client
          .post(uri, headers: _jsonHeaders(), body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const AuthApiException('Le serveur ne répond pas.');
    } on http.ClientException {
      throw const AuthApiException('Impossible de joindre le serveur.');
    }

    final body = _decodeBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthLoginResult.fromJson(body);
    }

    throw AuthApiException(_messageForError(response.statusCode, body));
  }

  Future<AuthLoginResult> oauthLogin({
    required String provider,
    required String code,
    String? redirectUri,
    String? codeVerifier,
  }) async {
    final uri = Uri.parse('${ApiConfig.authUrl}${ApiAuthEndpoints.oauthLogin}');

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: _jsonHeaders(),
            body: jsonEncode({
              'provider': provider,
              'code': code,
              if (redirectUri != null && redirectUri.isNotEmpty)
                'redirectUri': redirectUri,
              if (codeVerifier != null && codeVerifier.isNotEmpty)
                'codeVerifier': codeVerifier,
              if (!kIsWeb) 'tokenTransport': 'body',
            }),
          )
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const AuthApiException('Le serveur ne répond pas.');
    } on http.ClientException {
      throw const AuthApiException('Impossible de joindre le serveur.');
    }

    final body = _decodeBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthLoginResult.fromJson(body);
    }

    throw AuthApiException(_messageForError(response.statusCode, body));
  }

  void close() => _client.close();

  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      if (!kIsWeb) 'X-Auth-Token-Transport': 'body',
    };
  }

  Map<String, dynamic> _decodeBody(String source) {
    if (source.isEmpty) return {};
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const AuthApiException('Réponse serveur invalide.');
  }

  String _messageForError(int statusCode, Map<String, dynamic> body) {
    final error = body['error'];
    return switch ((statusCode, error)) {
      (401, 'invalidCredentials') => 'Identifiant ou mot de passe invalide.',
      (401, 'invalidOAuthCredentials') =>
        'Connexion Google refusée. Réessayez.',
      (403, 'identityNotActive') => 'Ce compte est désactivé.',
      (400, 'oauthProviderNotConfigured') =>
        'La connexion Google n’est pas configurée côté serveur.',
      (400, 'invalidOAuthProvider') => 'Fournisseur OAuth invalide.',
      (409, 'usernameAlreadyExists') => 'Ce nom d’utilisateur existe déjà.',
      (409, 'emailAlreadyExists') => 'Cette adresse e-mail existe déjà.',
      (400, 'invalidUsername') => 'Nom d’utilisateur invalide.',
      (400, 'invalidEmail') => 'Adresse e-mail invalide.',
      (400, 'weakPassword') => 'Mot de passe trop faible.',
      (400, 'passwordConfirmationMismatch') =>
        'Les mots de passe ne correspondent pas.',
      (429, 'tooManyAttempts') =>
        'Trop de tentatives. Réessayez dans quelques minutes.',
      _ => 'Connexion impossible. Réessayez.',
    };
  }
}
