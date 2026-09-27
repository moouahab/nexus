import 'package:serverpod/serverpod.dart';

abstract interface class TenantAuthorization {
  Future<bool> canManageTenant({
    required UuidValue tenantPartyId,
    required String? bearerToken,
  });
}

final class UnavailableTenantAuthorization implements TenantAuthorization {
  const UnavailableTenantAuthorization();

  @override
  Future<bool> canManageTenant({
    required UuidValue tenantPartyId,
    required String? bearerToken,
  }) async => false;
}
