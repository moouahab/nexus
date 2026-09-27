import 'package:serverpod/serverpod.dart';

import 'auth_claim_names.dart';
import 'auth_claim_parser.dart';
import 'auth_token_types.dart';
import 'nexus_auth_exception.dart';

class AuthContext {
  const AuthContext({
    required this.identityId,
    required this.authSessionId,
    required this.issuer,
    required this.audience,
    required this.emailVerified,
    required this.authenticationMethods,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory AuthContext.fromClaims(Map<String, dynamic> claims) {
    try {
      if (claims[AuthClaimNames.tokenType] != AuthTokenTypes.access) {
        throw const NexusAuthException.invalidAccessToken(
          'Expected user access token.',
        );
      }
      return AuthContext(
        identityId: UuidValue.withValidation(
          claims[AuthClaimNames.subject] as String,
        ),
        authSessionId: UuidValue.withValidation(
          claims[AuthClaimNames.sessionId] as String,
        ),
        issuer: claims[AuthClaimNames.issuer] as String,
        audience: singleAudienceClaim(claims),
        emailVerified: claims[AuthClaimNames.emailVerified] as bool,
        authenticationMethods:
            (claims[AuthClaimNames.authenticationMethods] as List<dynamic>)
                .cast<String>(),
        issuedAt: dateTimeFromEpochSeconds(claims[AuthClaimNames.issuedAt]),
        expiresAt: dateTimeFromEpochSeconds(claims[AuthClaimNames.expiresAt]),
      );
    } on NexusAuthException {
      rethrow;
    } on Object catch (error) {
      throw NexusAuthException.invalidAccessToken(
        'Invalid token claims: $error',
      );
    }
  }

  final UuidValue identityId;
  final UuidValue authSessionId;
  final String issuer;
  final String audience;
  final bool emailVerified;
  final List<String> authenticationMethods;
  final DateTime issuedAt;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc());
}
