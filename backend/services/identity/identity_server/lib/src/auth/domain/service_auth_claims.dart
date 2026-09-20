import '../constants/auth_claim_names.dart';
import '../constants/auth_token_defaults.dart';
import '../constants/auth_token_types.dart';

class ServiceAuthClaims {
  const ServiceAuthClaims({
    required this.serviceName,
    required this.issuer,
    required this.audience,
    required this.scopes,
    required this.issuedAt,
    required this.expiresAt,
    this.globalAccess = false,
    this.tenantPartyId,
    this.projectId,
    this.resourceId,
    this.delegatedIdentityId,
  });

  factory ServiceAuthClaims.service({
    required String serviceName,
    required String audience,
    required List<String> scopes,
    DateTime? issuedAt,
    Duration lifetime = AuthTokenDefaults.serviceTokenLifetime,
    String issuer = AuthTokenDefaults.issuer,
    bool globalAccess = false,
    String? tenantPartyId,
    String? projectId,
    String? resourceId,
    String? delegatedIdentityId,
  }) {
    final normalizedServiceName = _requiredTokenValue(
      serviceName,
      'serviceName',
    );
    final normalizedAudience = _requiredTokenValue(audience, 'audience');
    final normalizedScopes = _normalizeScopes(scopes);
    final now = issuedAt ?? DateTime.now().toUtc();
    return ServiceAuthClaims(
      serviceName: normalizedServiceName,
      issuer: issuer,
      audience: normalizedAudience,
      scopes: normalizedScopes,
      issuedAt: now,
      expiresAt: now.add(lifetime),
      globalAccess: globalAccess,
      tenantPartyId: _optionalTokenValue(tenantPartyId, 'tenantPartyId'),
      projectId: _optionalTokenValue(projectId, 'projectId'),
      resourceId: _optionalTokenValue(resourceId, 'resourceId'),
      delegatedIdentityId: _optionalTokenValue(
        delegatedIdentityId,
        'delegatedIdentityId',
      ),
    );
  }

  factory ServiceAuthClaims.fromJson(Map<String, dynamic> json) {
    final subject = json[AuthClaimNames.subject] as String;
    const servicePrefix = 'service:';
    if (!subject.startsWith(servicePrefix) ||
        subject.length == servicePrefix.length) {
      throw const FormatException('Invalid service token subject.');
    }

    return ServiceAuthClaims(
      serviceName: subject.substring(servicePrefix.length),
      issuer: json[AuthClaimNames.issuer] as String,
      audience: _singleAudience(json[AuthClaimNames.audience]),
      scopes: _scopesFromJson(json[AuthClaimNames.scopes]),
      issuedAt: _dateTimeFromEpochSeconds(json[AuthClaimNames.issuedAt]),
      expiresAt: _dateTimeFromEpochSeconds(json[AuthClaimNames.expiresAt]),
      globalAccess: json[AuthClaimNames.globalAccess] == true,
      tenantPartyId: _optionalTokenValue(
        json[AuthClaimNames.tenantPartyId] as String?,
        'tenantPartyId',
      ),
      projectId: _optionalTokenValue(
        json[AuthClaimNames.projectId] as String?,
        'projectId',
      ),
      resourceId: _optionalTokenValue(
        json[AuthClaimNames.resourceId] as String?,
        'resourceId',
      ),
      delegatedIdentityId: _optionalTokenValue(
        json[AuthClaimNames.delegatedIdentityId] as String?,
        'delegatedIdentityId',
      ),
    );
  }

  final String serviceName;
  final String issuer;
  final String audience;
  final List<String> scopes;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool globalAccess;
  final String? tenantPartyId;
  final String? projectId;
  final String? resourceId;
  final String? delegatedIdentityId;

  String get subject => 'service:$serviceName';

  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc());

  bool hasAllScopes(Iterable<String> requiredScopes) {
    return requiredScopes.every(scopes.contains);
  }

  Map<String, dynamic> toJson() {
    return {
      AuthClaimNames.subject: subject,
      AuthClaimNames.issuer: issuer,
      AuthClaimNames.audience: audience,
      AuthClaimNames.tokenType: AuthTokenTypes.service,
      AuthClaimNames.issuedAt: _epochSeconds(issuedAt),
      AuthClaimNames.expiresAt: _epochSeconds(expiresAt),
      AuthClaimNames.scopes: scopes.join(' '),
      if (globalAccess) AuthClaimNames.globalAccess: true,
      if (tenantPartyId != null) AuthClaimNames.tenantPartyId: tenantPartyId,
      if (projectId != null) AuthClaimNames.projectId: projectId,
      if (resourceId != null) AuthClaimNames.resourceId: resourceId,
      if (delegatedIdentityId != null)
        AuthClaimNames.delegatedIdentityId: delegatedIdentityId,
    };
  }

  bool get hasResourceBoundary =>
      globalAccess ||
      tenantPartyId != null ||
      projectId != null ||
      resourceId != null;

  static String _requiredTokenValue(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.contains(RegExp(r'\s'))) {
      throw ArgumentError.value(
        value,
        name,
        'Must be a non-empty token value.',
      );
    }
    return normalized;
  }

  static String? _optionalTokenValue(String? value, String name) {
    if (value == null) return null;
    return _requiredTokenValue(value, name);
  }

  static List<String> _normalizeScopes(List<String> scopes) {
    final normalized =
        scopes
            .map((scope) => scope.trim())
            .where((scope) => scope.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort();
    if (normalized.isEmpty) {
      throw ArgumentError.value(scopes, 'scopes', 'Must not be empty.');
    }
    for (final scope in normalized) {
      if (scope.contains(RegExp(r'\s'))) {
        throw ArgumentError.value(scope, 'scopes', 'Invalid scope value.');
      }
    }
    return normalized;
  }

  static List<String> _scopesFromJson(dynamic value) {
    if (value is String) {
      return _normalizeScopes(value.split(' '));
    }
    if (value is List) {
      return _normalizeScopes(value.cast<String>());
    }
    throw const FormatException('Invalid scope claim.');
  }

  static String _singleAudience(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw const FormatException('Invalid audience claim.');
  }

  static DateTime _dateTimeFromEpochSeconds(dynamic value) {
    return DateTime.fromMillisecondsSinceEpoch(
      (value as int) * 1000,
      isUtc: true,
    );
  }

  static int _epochSeconds(DateTime value) {
    return value.toUtc().millisecondsSinceEpoch ~/ 1000;
  }
}
