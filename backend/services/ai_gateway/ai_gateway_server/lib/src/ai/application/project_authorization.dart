import 'package:serverpod/serverpod.dart';

/// The only boundary allowed to decide whether Projects data may feed a run.
abstract interface class ProjectAuthorization {
  Future<String?> authorizeProject({
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    UuidValue? identityId,
    String? serviceName,
    String? bearerToken,
  });
}

/// Safe production default until the Projects authorization API is deployed.
final class UnavailableProjectAuthorization implements ProjectAuthorization {
  const UnavailableProjectAuthorization();

  @override
  Future<String?> authorizeProject({
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    UuidValue? identityId,
    String? serviceName,
    String? bearerToken,
  }) async => null;
}
