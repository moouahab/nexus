import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'auth_context.dart';
import 'auth_claim_names.dart';
import 'auth_token_defaults.dart';
import 'auth_token_types.dart';
import 'nexus_auth_exception.dart';
import 'service_auth_context.dart';

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
    final claims = _verifiedClaims(token);
    final context = AuthContext.fromClaims(claims);
    if (context.isExpired) {
      throw const NexusAuthException.invalidAccessToken(
        'Expired access token.',
      );
    }
    return context;
  }

  ServiceAuthContext verifyServiceToken(
    String token, {
    Iterable<String> requiredScopes = const [],
  }) {
    final claims = _verifiedClaims(token);
    if (claims[AuthClaimNames.tokenType] != AuthTokenTypes.service) {
      throw const NexusAuthException.invalidAccessToken(
        'Expected service token.',
      );
    }

    final context = ServiceAuthContext.fromClaims(claims);
    if (context.isExpired) {
      throw const NexusAuthException.invalidAccessToken(
        'Expired service token.',
      );
    }
    if (!context.audiences.contains(audience)) {
      throw NexusAuthException.invalidAccessToken(
        'Service token is not intended for audience "$audience".',
      );
    }
    if (!context.hasAllScopes(requiredScopes)) {
      throw const NexusAuthException.invalidAccessToken(
        'Service token is missing required scopes.',
      );
    }
    return context;
  }

  Map<String, dynamic> _verifiedClaims(String token) {
    try {
      final jwt = JWT.verify(
        token,
        _publicKey,
        issuer: issuer,
        audience: Audience([audience]),
      );
      return (jwt.payload as Map).cast<String, dynamic>();
    } on Object catch (error) {
      throw NexusAuthException.invalidAccessToken(
        'Invalid RS256 token: $error',
      );
    }
  }

  static String _normalizePem(String value) {
    return value.trim().replaceAll(r'\n', '\n');
  }
}
