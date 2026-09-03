import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../application/exceptions/auth_use_case_exception.dart';
import 'oauth_http_client.dart';

class AppleIdTokenVerifier {
  AppleIdTokenVerifier({
    OAuthHttpClient? httpClient,
    Uri? jwksUrl,
    this.cacheLifetime = const Duration(hours: 1),
    this.clockSkew = const Duration(seconds: 60),
  }) : _httpClient = httpClient ?? OAuthHttpClient(),
       jwksUrl = jwksUrl ?? Uri.https('appleid.apple.com', '/auth/keys');

  final OAuthHttpClient _httpClient;
  final Uri jwksUrl;
  final Duration cacheLifetime;
  final Duration clockSkew;

  List<JWTKey>? _cachedKeys;
  DateTime? _cachedKeysExpiresAt;

  Future<Map<String, dynamic>> verify({
    required String idToken,
    required String audience,
  }) async {
    final keys = await _keys();
    JWTException? lastException;

    for (final key in keys) {
      try {
        final jwt = JWT.verify(
          idToken,
          key,
          issuer: 'https://appleid.apple.com',
          audience: Audience([audience]),
        );
        final claims = (jwt.payload as Map).cast<String, dynamic>();
        _validateClaims(claims);
        return claims;
      } on JWTException catch (exception) {
        lastException = exception;
      } on Object {
        throw const AuthUseCaseException(
          AuthUseCaseExceptionCode.invalidOAuthCredentials,
        );
      }
    }

    if (lastException != null) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }
    throw const AuthUseCaseException(
      AuthUseCaseExceptionCode.invalidOAuthCredentials,
    );
  }

  Future<List<JWTKey>> _keys() async {
    final now = DateTime.now().toUtc();
    final cachedKeys = _cachedKeys;
    final cachedKeysExpiresAt = _cachedKeysExpiresAt;
    if (cachedKeys != null &&
        cachedKeysExpiresAt != null &&
        cachedKeysExpiresAt.isAfter(now)) {
      return cachedKeys;
    }

    final response = await _httpClient.getJson(jwksUrl);
    if (response.statusCode != 200) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final jwks = response.objectBody['keys'];
    if (jwks is! List) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final keys = <JWTKey>[];
    for (final jwk in jwks) {
      if (jwk is! Map) continue;
      try {
        keys.add(JWTKey.fromJWK(jwk.cast<String, dynamic>()));
      } on JWTException {
        continue;
      }
    }

    if (keys.isEmpty) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    _cachedKeys = keys;
    _cachedKeysExpiresAt = now.add(cacheLifetime);
    return keys;
  }

  void _validateClaims(Map<String, dynamic> claims) {
    final subject = claims['sub'];
    if (subject is! String || subject.isEmpty) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }

    final issuedAt = _secondsSinceEpoch(claims['iat']);
    if (issuedAt == null ||
        issuedAt.isAfter(DateTime.now().toUtc().add(clockSkew))) {
      throw const AuthUseCaseException(
        AuthUseCaseExceptionCode.invalidOAuthCredentials,
      );
    }
  }

  DateTime? _secondsSinceEpoch(Object? value) {
    if (value is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      value.toInt() * 1000,
      isUtc: true,
    );
  }
}
