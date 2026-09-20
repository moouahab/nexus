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
}
