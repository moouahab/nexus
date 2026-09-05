import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

class AuthLoginResult {
  const AuthLoginResult({
    required this.identityId,
    required this.authSessionId,
    required this.tokenType,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
  });

  final String identityId;
  final String authSessionId;
  final String tokenType;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    return AuthLoginResult(
      identityId: _readString(json, 'identityId'),
      authSessionId: _readString(json, 'authSessionId'),
      tokenType: _readString(json, 'tokenType'),
      accessToken: _readString(json, 'accessToken'),
      refreshToken: _readString(json, 'refreshToken'),
      expiresIn: _readInt(json, 'expiresIn'),
      refreshExpiresIn: _readInt(json, 'refreshExpiresIn'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw const FormatException('Invalid auth response.');
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
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
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.identityUrl}${ApiAuthEndpoints.login}');

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'X-Auth-Token-Transport': 'body',
            },
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
    final uri = Uri.parse(
      '${ApiConfig.identityUrl}${ApiAuthEndpoints.register}',
    );
    final requestBody = {
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'tokenTransport': 'body',
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    };

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
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
      (403, 'identityNotActive') => 'Ce compte est désactivé.',
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
