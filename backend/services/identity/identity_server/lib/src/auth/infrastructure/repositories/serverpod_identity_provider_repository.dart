import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart' as protocol;
import '../../application/interfaces/identity_provider_repository.dart';

class ServerpodIdentityProviderRepository
    implements IdentityProviderRepository {
  @override
  Future<protocol.IdentityProvider> create(
    Session session, {
    required UuidValue identityId,
    required protocol.AuthProvider provider,
    required String providerUserId,
    String? email,
    bool emailVerified = false,
  }) {
    return protocol.IdentityProvider.db.insertRow(
      session,
      protocol.IdentityProvider(
        identityId: identityId,
        provider: provider,
        providerUserId: providerUserId,
        email: email,
        emailVerified: emailVerified,
      ),
    );
  }

  @override
  Future<protocol.IdentityProvider?> findByProviderUserId(
    Session session, {
    required protocol.AuthProvider provider,
    required String providerUserId,
  }) {
    return protocol.IdentityProvider.db.findFirstRow(
      session,
      where: (t) =>
          t.provider.equals(provider) & t.providerUserId.equals(providerUserId),
    );
  }

  @override
  Future<List<protocol.IdentityProvider>> findByIdentityId(
    Session session,
    UuidValue identityId,
  ) {
    return protocol.IdentityProvider.db.find(
      session,
      where: (t) => t.identityId.equals(identityId),
    );
  }

  @override
  Future<protocol.IdentityProvider?> markUsed(Session session, UuidValue id) {
    return protocol.IdentityProvider.db.updateById(
      session,
      id,
      columnValues: (t) => [
        t.lastUsedAt(DateTime.now().toUtc()),
      ],
    );
  }
}
