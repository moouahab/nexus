import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../application/interfaces/access_token_service.dart';
import '../../application/interfaces/service_token_service.dart';
import '../../constants/auth_claim_names.dart';
import '../../constants/auth_token_defaults.dart';
import '../../constants/auth_token_types.dart';
import '../../domain/auth_claims.dart';
import '../../domain/service_auth_claims.dart';
import 'hmac_sha256_access_token_service.dart';

class Rs256AccessTokenService
    implements AccessTokenService, ServiceTokenService {
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
    return _createToken(claims.toJson());
  }

  @override
  String createServiceToken(ServiceAuthClaims claims) {
    return _createToken(claims.toJson());
  }

  String _createToken(Map<String, dynamic> claims) {
    final jwt = JWT(
      claims,
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
      final claims = AuthClaims.fromJson(_verifiedPayload(token));
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

  @override
  ServiceAuthClaims verifyServiceToken(
    String token, {
    Iterable<String> requiredScopes = const [],
  }) {
    try {
      final payload = _verifiedPayload(token);
      if (payload[AuthClaimNames.tokenType] != AuthTokenTypes.service) {
        throw const InvalidAccessTokenException('Invalid token type.');
      }
      final claims = ServiceAuthClaims.fromJson(payload);
      if (claims.isExpired || !claims.hasAllScopes(requiredScopes)) {
        throw const InvalidAccessTokenException(
          'Invalid service token claims.',
        );
      }
      return claims;
    } on InvalidAccessTokenException {
      rethrow;
    } on Object catch (error) {
      throw InvalidAccessTokenException('Invalid RS256 token: $error');
    }
  }

  Map<String, dynamic> _verifiedPayload(String token) {
    final jwt = JWT.verify(
      token,
      _publicKey,
      issuer: _issuer,
      audience: Audience([_audience]),
    );
    return (jwt.payload as Map).cast<String, dynamic>();
  }

  static String _normalizePem(String value) {
    return value.trim().replaceAll(r'\n', '\n');
  }
}
