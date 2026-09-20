import 'auth_claim_names.dart';
import 'auth_claim_parser.dart';
import 'nexus_auth_exception.dart';

class ServiceAuthContext {
  const ServiceAuthContext({
    required this.serviceName,
    required this.issuer,
    required this.audiences,
    required this.scopes,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory ServiceAuthContext.fromClaims(Map<String, dynamic> claims) {
    try {
      return ServiceAuthContext(
        serviceName: _serviceNameFromSubject(
          claims[AuthClaimNames.subject] as String,
        ),
        issuer: claims[AuthClaimNames.issuer] as String,
        audiences: audienceClaim(claims),
        scopes: stringListClaim(claims, AuthClaimNames.scopes),
        issuedAt: dateTimeFromEpochSeconds(claims[AuthClaimNames.issuedAt]),
        expiresAt: dateTimeFromEpochSeconds(claims[AuthClaimNames.expiresAt]),
      );
    } on NexusAuthException {
      rethrow;
    } on Object catch (error) {
      throw NexusAuthException.invalidAccessToken(
        'Invalid service token claims: $error',
      );
    }
  }

  final String serviceName;
  final String issuer;
  final List<String> audiences;
  final List<String> scopes;
  final DateTime issuedAt;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc());

  bool hasScope(String scope) => scopes.contains(scope);

  bool hasAllScopes(Iterable<String> requiredScopes) {
    return requiredScopes.every(hasScope);
  }

  static String _serviceNameFromSubject(String subject) {
    const prefix = 'service:';
    if (!subject.startsWith(prefix) || subject.length == prefix.length) {
      throw const NexusAuthException.invalidAccessToken(
        'Service token subject must use "service:<name>".',
      );
    }
    return subject.substring(prefix.length);
  }
}
