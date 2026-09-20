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
    this.globalAccess = false,
    this.tenantPartyId,
    this.projectId,
    this.resourceId,
    this.delegatedIdentityId,
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
        globalAccess: claims[AuthClaimNames.globalAccess] == true,
        tenantPartyId: _optionalString(claims[AuthClaimNames.tenantPartyId]),
        projectId: _optionalString(claims[AuthClaimNames.projectId]),
        resourceId: _optionalString(claims[AuthClaimNames.resourceId]),
        delegatedIdentityId: _optionalString(
          claims[AuthClaimNames.delegatedIdentityId],
        ),
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
  final bool globalAccess;
  final String? tenantPartyId;
  final String? projectId;
  final String? resourceId;
  final String? delegatedIdentityId;

  bool get hasResourceBoundary =>
      globalAccess ||
      tenantPartyId != null ||
      projectId != null ||
      resourceId != null;

  bool allowsTenant(Object tenantId) =>
      globalAccess || tenantPartyId == tenantId.toString();

  bool allowsProject(Object requestedProjectId, {Object? tenantId}) =>
      globalAccess ||
      projectId == requestedProjectId.toString() ||
      (tenantId != null && allowsTenant(tenantId));

  bool allowsResource(
    Object requestedResourceId, {
    Object? projectId,
    Object? tenantId,
  }) =>
      globalAccess ||
      resourceId == requestedResourceId.toString() ||
      (projectId != null && allowsProject(projectId, tenantId: tenantId));

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

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw const NexusAuthException.invalidAccessToken(
        'Invalid service resource boundary claim.',
      );
    }
    return value.trim();
  }
}
