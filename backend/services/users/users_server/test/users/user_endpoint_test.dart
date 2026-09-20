import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:users_server/src/generated/protocol.dart';
import 'package:users_server/src/users/application/user_profile_service.dart';
import 'package:users_server/src/users/user_endpoint.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('User profiles', (sessionBuilder, _) {
    const profiles = UserProfileService();

    Session session() {
      final value = sessionBuilder.build();
      addTearDown(value.close);
      return value;
    }

    test('rejects endpoint calls without an explicit auth context', () {
      final identityId = const Uuid().v7obj();
      expect(
        () => UserEndpoint().getProfileByIdentity(
          session(),
          identityId,
        ),
        throwsA(
          isA<NotAuthorizedException>()
              .having(
                (error) => error.reason,
                'reason',
                AuthenticationFailureReason.insufficientAccess,
              )
              .having(
                (error) => error.message,
                'safe message',
                'Authentication failed.',
              ),
        ),
      );
      expect(
        () => UserEndpoint().completeProfile(
          session(),
          identityId: identityId,
          displayName: 'Unauthorized',
        ),
        throwsA(
          isA<NotAuthorizedException>().having(
            (error) => error.message,
            'safe message',
            'Authentication failed.',
          ),
        ),
      );
      expect(
        () => UserEndpoint().getMyProfile(session()),
        throwsA(isA<NotAuthorizedException>()),
      );
      expect(
        () => UserEndpoint().completeMyProfile(
          session(),
          displayName: 'Unauthorized',
        ),
        throwsA(isA<NotAuthorizedException>()),
      );
    });

    test('completes a functional profile for an identity', () async {
      final identityId = const Uuid().v7obj();
      final primaryPartyId = const Uuid().v7obj();

      final profile = await profiles.completeProfile(
        session(),
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
      final testSession = session();
      final profile = await profiles.completeProfile(
        testSession,
        identityId: const Uuid().v7obj(),
        displayName: 'Nina Founder',
        kind: UserProfileKind.organizationMember,
      );

      final byIdentity = await profiles.getProfileByIdentity(
        testSession,
        profile.identityId,
      );

      expect(byIdentity.id, profile.id);
    });

    test('updates the primary party reference', () async {
      final testSession = session();
      final profile = await profiles.completeProfile(
        testSession,
        identityId: const Uuid().v7obj(),
        displayName: 'Bob Member',
        kind: UserProfileKind.organizationMember,
      );
      final partyId = const Uuid().v7obj();

      final updated = await profiles.setPrimaryParty(
        testSession,
        userProfileId: profile.id!,
        primaryPartyId: partyId,
      );

      expect(updated.primaryPartyId, partyId);
      expect(updated.updatedAt, isNotNull);
    });

    test('keeps identity profiles and primary parties isolated', () async {
      final testSession = session();
      final identityA = const Uuid().v7obj();
      final identityB = const Uuid().v7obj();
      final partyA = const Uuid().v7obj();
      final partyB = const Uuid().v7obj();
      final profileA = await profiles.completeProfile(
        testSession,
        identityId: identityA,
        displayName: 'Tenant A User',
        kind: UserProfileKind.organizationMember,
        primaryPartyId: partyA,
      );
      final profileB = await profiles.completeProfile(
        testSession,
        identityId: identityB,
        displayName: 'Tenant B User',
        kind: UserProfileKind.organizationMember,
        primaryPartyId: partyB,
      );

      await profiles.setPrimaryParty(
        testSession,
        userProfileId: profileA.id!,
        primaryPartyId: null,
      );

      final reloadedA = await profiles.getProfileByIdentity(
        testSession,
        identityA,
      );
      final reloadedB = await profiles.getProfileByIdentity(
        testSession,
        identityB,
      );
      expect(reloadedA.id, profileA.id);
      expect(reloadedA.primaryPartyId, isNull);
      expect(reloadedB.id, profileB.id);
      expect(reloadedB.primaryPartyId, partyB);
      expect(reloadedB.displayName, 'Tenant B User');
    });

    test('rejects duplicate profile for the same identity', () async {
      final identityId = const Uuid().v7obj();
      final testSession = session();
      await profiles.completeProfile(
        testSession,
        identityId: identityId,
        displayName: 'First Profile',
        kind: UserProfileKind.consultant,
      );

      await expectLater(
        profiles.completeProfile(
          testSession,
          identityId: identityId,
          displayName: 'Second Profile',
          kind: UserProfileKind.consultant,
        ),
        throwsStateError,
      );
    });
  });
}
