import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'auth_claim_names.dart';
import 'auth_context.dart';
import 'auth_token_defaults.dart';
import 'auth_token_types.dart';
import 'nexus_auth_exception.dart';
import 'service_auth_context.dart';

class HmacSha256AccessTokenVerifier {
  HmacSha256AccessTokenVerifier({
    required String secret,
    this.issuer = AuthTokenDefaults.issuer,
    this.audience = AuthTokenDefaults.audience,
  }) : _secret = utf8.encode(secret);

  static const _algorithm = 'HS256';

  final List<int> _secret;
  final String issuer;
  final String audience;

  AuthContext verify(String token) {
    final claims = _verifiedClaims(token);
    final context = AuthContext.fromClaims(claims);
    final claimChecks = <bool Function()>[
      () => context.issuer == issuer,
      () => context.audience == audience,
      () => !context.isExpired,
    ];
    if (!claimChecks.every((check) => check())) {
      throw const NexusAuthException.invalidAccessToken(
        'Invalid access token claims.',
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
    final claimChecks = <bool Function()>[
      () => context.issuer == issuer,
      () => context.audiences.contains(audience),
      () => context.hasAllScopes(requiredScopes),
      () => !context.isExpired,
    ];
    if (!claimChecks.every((check) => check())) {
      throw const NexusAuthException.invalidAccessToken(
        'Invalid service token claims.',
      );
    }

    return context;
  }

  Map<String, dynamic> _verifiedClaims(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const NexusAuthException.invalidAccessToken('Malformed token.');
    }

    final signingInput = '${parts[0]}.${parts[1]}';
    final expectedSignature = _sign(signingInput);
    if (!_constantTimeEquals(expectedSignature, parts[2])) {
      throw const NexusAuthException.invalidAccessToken('Invalid signature.');
    }

    final header = _decodeJson(parts[0]);
    final headerChecks = <bool Function()>[
      () => header['alg'] == _algorithm,
      () => header['typ'] == 'JWT',
    ];
    if (!headerChecks.every((check) => check())) {
      throw const NexusAuthException.invalidAccessToken(
        'Unsupported token header.',
      );
    }

    final claims = _decodeJson(parts[1]);
    return claims;
  }

  String _sign(String signingInput) {
    final digest = Hmac(sha256, _secret).convert(utf8.encode(signingInput));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  static Map<String, dynamic> _decodeJson(String value) {
    try {
      return (jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(value))),
              )
              as Map<String, dynamic>)
          .cast<String, dynamic>();
    } on Object catch (error) {
      throw NexusAuthException.invalidAccessToken('Invalid JWT JSON: $error');
    }
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
