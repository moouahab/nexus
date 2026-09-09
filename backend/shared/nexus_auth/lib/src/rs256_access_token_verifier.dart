import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'auth_context.dart';
import 'auth_token_defaults.dart';
import 'nexus_auth_exception.dart';

class Rs256AccessTokenVerifier {
  Rs256AccessTokenVerifier({
    required String publicKeyPem,
    this.issuer = AuthTokenDefaults.issuer,
    this.audience = AuthTokenDefaults.audience,
  }) : _publicKey = RSAPublicKey(_normalizePem(publicKeyPem));

  factory Rs256AccessTokenVerifier.fromJwks({
    required Map<String, dynamic> jwks,
    String? keyId,
    String issuer = AuthTokenDefaults.issuer,
    String audience = AuthTokenDefaults.audience,
  }) {
    final keys = jwks['keys'];
    if (keys is! List) {
      throw const NexusAuthException.invalidAccessToken('Invalid JWKS.');
    }

    for (final jwk in keys) {
      if (jwk is! Map) continue;
      final json = jwk.cast<String, dynamic>();
      if (keyId != null && json['kid'] != keyId) continue;
      if (json['kty'] != 'RSA') continue;

      return Rs256AccessTokenVerifier.fromKey(
        publicKey: JWTKey.fromJWK(json),
        issuer: issuer,
        audience: audience,
      );
    }

    throw const NexusAuthException.invalidAccessToken('No matching JWKS key.');
  }

  Rs256AccessTokenVerifier.fromKey({
    required JWTKey publicKey,
    this.issuer = AuthTokenDefaults.issuer,
    this.audience = AuthTokenDefaults.audience,
  }) : _publicKey = publicKey;

  final JWTKey _publicKey;
  final String issuer;
  final String audience;

  AuthContext verify(String token) {
    try {
      final jwt = JWT.verify(
        token,
        _publicKey,
        issuer: issuer,
        audience: Audience([audience]),
      );
      return AuthContext.fromClaims(
        (jwt.payload as Map).cast<String, dynamic>(),
      );
    } on NexusAuthException {
      rethrow;
    } on Object catch (error) {
      throw NexusAuthException.invalidAccessToken(
        'Invalid RS256 access token: $error',
      );
    }
  }

  static String _normalizePem(String value) {
    return value.trim().replaceAll(r'\n', '\n');
  }
}
