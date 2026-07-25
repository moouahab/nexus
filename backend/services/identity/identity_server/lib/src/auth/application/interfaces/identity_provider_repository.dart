import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;

abstract interface class IdentityProviderRepository {
  Future<protocol.IdentityProvider> create(
    Session session, {
    required UuidValue identityId,
    required protocol.AuthProvider provider,
    required String providerUserId,
    String? email,
    bool emailVerified,
  });

  Future<protocol.IdentityProvider?> findByProviderUserId(
    Session session, {
    required protocol.AuthProvider provider,
    required String providerUserId,
  });

  Future<List<protocol.IdentityProvider>> findByIdentityId(
    Session session,
    UuidValue identityId,
  );

  Future<protocol.IdentityProvider?> markUsed(Session session, UuidValue id);
}
