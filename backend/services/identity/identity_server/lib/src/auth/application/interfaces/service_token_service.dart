import '../../domain/service_auth_claims.dart';

abstract interface class ServiceTokenService {
  String createServiceToken(ServiceAuthClaims claims);

  ServiceAuthClaims verifyServiceToken(
    String token, {
    Iterable<String> requiredScopes = const [],
  });
}
