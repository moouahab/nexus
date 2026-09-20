import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../application/interfaces/access_token_service.dart';
import '../../application/interfaces/service_token_service.dart';
import '../../application/validation/termination_rule.dart';
import '../../constants/auth_claim_names.dart';
import '../../constants/auth_token_defaults.dart';
import '../../constants/auth_token_types.dart';
import '../../domain/auth_claims.dart';
import '../../domain/service_auth_claims.dart';

class InvalidAccessTokenException implements Exception {
  const InvalidAccessTokenException(this.message);

  final String message;

  @override
  String toString() => 'InvalidAccessTokenException: $message';
}

class HmacSha256AccessTokenService
    implements AccessTokenService, ServiceTokenService {
  HmacSha256AccessTokenService({
    required String secret,
    String issuer = AuthTokenDefaults.issuer,
    String audience = AuthTokenDefaults.audience,
  }) : _secret = utf8.encode(secret),
       _issuer = issuer,
       _audience = audience;

  static const _algorithm = 'HS256';

  final List<int> _secret;
  final String _issuer;
  final String _audience;

  @override
  String createAccessToken(AuthClaims claims) {
    return _createToken(claims.toJson());
  }

  @override
  String createServiceToken(ServiceAuthClaims claims) {
    return _createToken(claims.toJson());
  }

  @override
  AuthClaims verifyAccessToken(String token) {
    try {
      final claims = AuthClaims.fromJson(_verifiedPayload(token));
      TerminationRule.validateAll([
        TerminationRule(
          shouldTerminate: () => claims.issuer != _issuer,
          exception: const InvalidAccessTokenException('Invalid issuer.'),
        ),
        TerminationRule(
          shouldTerminate: () => claims.audience != _audience,
          exception: const InvalidAccessTokenException('Invalid audience.'),
        ),
        TerminationRule(
          shouldTerminate: () => claims.tokenType != AuthTokenTypes.access,
          exception: const InvalidAccessTokenException('Invalid token type.'),
        ),
        TerminationRule(
          shouldTerminate: () => claims.isExpired,
          exception: const InvalidAccessTokenException('Expired token.'),
        ),
      ]);

      return claims;
    } on InvalidAccessTokenException {
      rethrow;
    } on Object catch (error) {
      throw InvalidAccessTokenException('Invalid access token claims: $error');
    }
  }

  @override
  ServiceAuthClaims verifyServiceToken(
    String token, {
    Iterable<String> requiredScopes = const [],
  }) {
    try {
      final payload = _verifiedPayload(token);
      TerminationRule.validateAll([
        TerminationRule(
          shouldTerminate: () =>
              payload[AuthClaimNames.tokenType] != AuthTokenTypes.service,
          exception: const InvalidAccessTokenException('Invalid token type.'),
        ),
      ]);

      final claims = ServiceAuthClaims.fromJson(payload);
      TerminationRule.validateAll([
        TerminationRule(
          shouldTerminate: () => claims.issuer != _issuer,
          exception: const InvalidAccessTokenException('Invalid issuer.'),
        ),
        TerminationRule(
          shouldTerminate: () => claims.audience != _audience,
          exception: const InvalidAccessTokenException('Invalid audience.'),
        ),
        TerminationRule(
          shouldTerminate: () => claims.isExpired,
          exception: const InvalidAccessTokenException('Expired token.'),
        ),
        TerminationRule(
          shouldTerminate: () => !claims.hasAllScopes(requiredScopes),
          exception: const InvalidAccessTokenException('Missing scope.'),
        ),
      ]);

      return claims;
    } on InvalidAccessTokenException {
      rethrow;
    } on Object catch (error) {
      throw InvalidAccessTokenException('Invalid service token claims: $error');
    }
  }

  String _createToken(Map<String, dynamic> claims) {
    final header = {
      'alg': _algorithm,
      'typ': 'JWT',
    };

    final encodedHeader = _base64UrlJson(header);
    final encodedPayload = _base64UrlJson(claims);
    final signingInput = '$encodedHeader.$encodedPayload';
    final signature = _sign(signingInput);

    return '$signingInput.$signature';
  }

  Map<String, dynamic> _verifiedPayload(String token) {
    final parts = token.split('.');
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => parts.length != 3,
        exception: const InvalidAccessTokenException('Malformed token.'),
      ),
    ]);

    final signingInput = '${parts[0]}.${parts[1]}';
    final expectedSignature = _sign(signingInput);
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () =>
            !_constantTimeEquals(expectedSignature, parts[2]),
        exception: const InvalidAccessTokenException('Invalid signature.'),
      ),
    ]);

    final header = _decodeJson(parts[0]);
    TerminationRule.validateAll([
      TerminationRule(
        shouldTerminate: () => header['alg'] != _algorithm,
        exception: const InvalidAccessTokenException('Unsupported algorithm.'),
      ),
      TerminationRule(
        shouldTerminate: () => header['typ'] != 'JWT',
        exception: const InvalidAccessTokenException('Unsupported token type.'),
      ),
    ]);

    return _decodeJson(parts[1]);
  }

  String _sign(String signingInput) {
    final digest = Hmac(sha256, _secret).convert(utf8.encode(signingInput));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  static String _base64UrlJson(Map<String, dynamic> json) {
    return base64UrlEncode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  }

  static Map<String, dynamic> _decodeJson(String value) {
    final normalized = base64Url.normalize(value);
    return (jsonDecode(utf8.decode(base64Url.decode(normalized)))
            as Map<String, dynamic>)
        .cast<String, dynamic>();
  }

  static bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;

    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }
    return difference == 0;
  }
}
