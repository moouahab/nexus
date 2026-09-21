import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

final class PartyAuthorization {
  const PartyAuthorization();

  static const membershipReadScope = 'parties.membership.read';
  static const membershipWriteScope = 'parties.membership.write';

  static const _userAuth = AuthContextResolver();
  static const _serviceAuth = AuthContextResolver(
    audience: 'parties-service',
  );

  AuthContext requireUser(Session session) => _userAuth.requireContext(session);

  ServiceAuthContext requireService(
    Session session, {
    required Iterable<String> scopes,
  }) => _serviceAuth.requireServiceContext(
    session,
    requiredScopes: scopes,
  );

  void requireExactBoundary(
    ServiceAuthContext context, {
    required Iterable<UuidValue> resources,
    Iterable<UuidValue> tenants = const [],
  }) {
    if (context.globalAccess) return;
    final resourceIds = resources.map((value) => value.toString()).toSet();
    final tenantIds = tenants.map((value) => value.toString()).toSet();
    if ((context.resourceId != null &&
            resourceIds.contains(context.resourceId)) ||
        (context.tenantPartyId != null &&
            tenantIds.contains(context.tenantPartyId))) {
      return;
    }
    throw const NexusAuthException.invalidAccessToken(
      'Service token resource boundary denied.',
    );
  }
}
