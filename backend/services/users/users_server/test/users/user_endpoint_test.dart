import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:users_server/src/generated/protocol.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('User endpoint', (sessionBuilder, endpoints) {
    test('completes a functional profile for an identity', () async {
      final identityId = const Uuid().v7obj();
      final primaryPartyId = const Uuid().v7obj();

      final profile = await endpoints.user.completeProfile(
        sessionBuilder,
        identityId: identityId,
        displayName: '  Alice Consultant  ',
        kind: UserProfileKind.consultant,
        primaryPartyId: primaryPartyId,
        email: ' ALICE@NEXUS.LOCAL ',
        metadata: {' skill ': ' cyber ', 'empty': ' '},
      );

      expect(profile.identityId, identityId);
      expect(profile.displayName, 'Alice Consultant');
      expect(profile.kind, UserProfileKind.consultant);
      expect(profile.status, UserProfileStatus.active);
      expect(profile.primaryPartyId, primaryPartyId);
      expect(profile.email, 'alice@nexus.local');
      expect(profile.metadata, {'skill': 'cyber'});
    });

    test('reads profile by identity id', () async {
      final profile = await endpoints.user.completeProfile(
        sessionBuilder,
        identityId: const Uuid().v7obj(),
        displayName: 'Nina Founder',
        kind: UserProfileKind.organizationMember,
      );

      final byIdentity = await endpoints.user.getProfileByIdentity(
        sessionBuilder,
        profile.identityId,
      );

      expect(byIdentity.id, profile.id);
    });

    test('updates the primary party reference', () async {
      final profile = await endpoints.user.completeProfile(
        sessionBuilder,
        identityId: const Uuid().v7obj(),
        displayName: 'Bob Member',
        kind: UserProfileKind.organizationMember,
      );
      final partyId = const Uuid().v7obj();

      final updated = await endpoints.user.setPrimaryParty(
        sessionBuilder,
        userProfileId: profile.id!,
        primaryPartyId: partyId,
      );

      expect(updated.primaryPartyId, partyId);
      expect(updated.updatedAt, isNotNull);
    });

    test('rejects duplicate profile for the same identity', () async {
      final identityId = const Uuid().v7obj();
      await endpoints.user.completeProfile(
        sessionBuilder,
        identityId: identityId,
        displayName: 'First Profile',
        kind: UserProfileKind.consultant,
      );

      await expectLater(
        endpoints.user.completeProfile(
          sessionBuilder,
          identityId: identityId,
          displayName: 'Second Profile',
          kind: UserProfileKind.consultant,
        ),
        throwsStateError,
      );
    });
  });
}
