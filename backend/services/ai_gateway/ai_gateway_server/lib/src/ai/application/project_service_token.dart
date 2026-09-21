import 'package:serverpod/serverpod.dart';

/// Obtains a short-lived token dedicated to one Projects resource boundary.
///
/// Implementations must fail closed: the caller bearer token is never an
/// acceptable fallback because it may have the `ai-gateway` audience.
abstract interface class ProjectServiceTokenIssuer {
  Future<String> issueReadToken(
    Session session, {
    required UuidValue tenantPartyId,
    required UuidValue projectId,
    UuidValue? delegatedIdentityId,
  });
}

final class UnavailableProjectServiceTokenIssuer
    implements ProjectServiceTokenIssuer {
  const UnavailableProjectServiceTokenIssuer();

  @override
  Future<String> issueReadToken(
    Session session, {
    required UuidValue tenantPartyId,
    required UuidValue projectId,
    UuidValue? delegatedIdentityId,
  }) {
    throw StateError('Projects service-token exchange is unavailable.');
  }
}
