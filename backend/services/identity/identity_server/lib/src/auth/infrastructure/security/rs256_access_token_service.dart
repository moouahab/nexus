import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../application/interfaces/access_token_service.dart';
import '../../constants/auth_token_defaults.dart';
import '../../constants/auth_token_types.dart';
import '../../domain/auth_claims.dart';
import 'hmac_sha256_access_token_service.dart';

class Rs256AccessTokenService implements AccessTokenService {
  Rs256AccessTokenService({
    required String privateKeyPem,
    required String publicKeyPem,
    required this.keyId,
    String issuer = AuthTokenDefaults.issuer,
    String audience = AuthTokenDefaults.audience,
  }) : _privateKey = RSAPrivateKey(_normalizePem(privateKeyPem)),
       _publicKey = RSAPublicKey(_normalizePem(publicKeyPem)),
       _issuer = issuer,
       _audience = audience;

  final RSAPrivateKey _privateKey;
  final RSAPublicKey _publicKey;
  final String keyId;
  final String _issuer;
  final String _audience;

  Map<String, dynamic> jwk() {
    return _publicKey.toJWK(keyID: keyId, algorithm: JWTAlgorithm.RS256);
  }

  @override
  String createAccessToken(AuthClaims claims) {
    final jwt = JWT(
      claims.toJson(),
      header: {
        'kid': keyId,
      },
    );
    return jwt.sign(
      _privateKey,
      algorithm: JWTAlgorithm.RS256,
      noIssueAt: true,
    );
  }

  @override
  AuthClaims verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(
        token,
        _publicKey,
        issuer: _issuer,
        audience: Audience([_audience]),
      );
      final claims = AuthClaims.fromJson(
        (jwt.payload as Map).cast<String, dynamic>(),
      );
      if (claims.tokenType != AuthTokenTypes.access || claims.isExpired) {
        throw const InvalidAccessTokenException('Invalid access token claims.');
      }
      return claims;
    } on InvalidAccessTokenException {
      rethrow;
    } on Object catch (error) {
      throw InvalidAccessTokenException('Invalid RS256 token: $error');
    }
  }

  static String _normalizePem(String value) {
    return value.trim().replaceAll(r'\n', '\n');
  }
}
