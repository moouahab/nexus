import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:parties_server/src/generated/protocol.dart';
import 'package:parties_server/src/parties/application/party_service.dart';
import 'package:parties_server/src/parties/party_endpoint.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Parties', (sessionBuilder, _) {
    const parties = PartyService();

    Session session() {
      final value = sessionBuilder.build();
      addTearDown(value.close);
      return value;
    }

    test('rejects calls without an explicit auth context', () {
      final endpoint = PartyEndpoint();
      final partyId = const Uuid().v7obj();
      final profileId = const Uuid().v7obj();
      expect(
        () => endpoint.createParty(
          session(),
          kind: PartyKind.company,
          name: 'Unauthorized',
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
        () => endpoint.listMemberships(
          session(),
          userProfileId: profileId,
        ),
        throwsA(
          isA<NotAuthorizedException>().having(
            (error) => error.message,
            'safe message',
            'Authentication failed.',
          ),
        ),
      );
      for (final call in <Future<Object> Function()>[
        () => endpoint.getParty(session(), partyId),
        () => endpoint.listParties(session()),
        () => endpoint.createPartyWithOwner(
          session(),
          userProfileId: profileId,
          kind: PartyKind.company,
          name: 'Unauthorized',
        ),
        () => endpoint.joinParty(
          session(),
          userProfileId: profileId,
          partyId: partyId,
        ),
      ]) {
        expect(
          call,
          throwsA(
            isA<NotAuthorizedException>().having(
              (error) => error.message,
              'safe message',
              'Authentication failed.',
            ),
          ),
        );
      }
    });

    test('creates a company party', () async {
      final party = await parties.createParty(
        session(),
        kind: PartyKind.company,
        name: ' Acme Corp ',
        legalName: ' Acme Corporation SAS ',
        country: ' FR ',
        metadata: {' sector ': ' cyber ', 'empty': ' '},
      );

      expect(party.kind, PartyKind.company);
      expect(party.status, PartyStatus.active);
      expect(party.name, 'Acme Corp');
      expect(party.legalName, 'Acme Corporation SAS');
      expect(party.country, 'FR');
      expect(party.metadata, {'sector': 'cyber'});
    });

    test('creates a party and primary owner membership atomically', () async {
      final userProfileId = const Uuid().v7obj();

      final testSession = session();
      final membership = await parties.createPartyWithOwner(
        testSession,
        userProfileId: userProfileId,
        kind: PartyKind.consultantPractice,
        name: 'Alice Advisory',
      );
      final party = await parties.getParty(
        testSession,
        membership.partyId,
      );

      expect(party.kind, PartyKind.consultantPractice);
      expect(membership.userProfileId, userProfileId);
      expect(membership.role, PartyMembershipRole.consultant);
      expect(membership.status, PartyMembershipStatus.active);
      expect(membership.isPrimary, true);
    });

    test('joins an existing association with pending membership', () async {
      final userProfileId = const Uuid().v7obj();
      final testSession = session();
      final association = await parties.createParty(
        testSession,
        kind: PartyKind.association,
        name: 'Open Rights Association',
      );

      final membership = await parties.joinParty(
        testSession,
        userProfileId: userProfileId,
        partyId: association.id!,
        role: PartyMembershipRole.member,
        status: PartyMembershipStatus.pending,
        isPrimary: false,
      );

      expect(membership.partyId, association.id);
      expect(membership.userProfileId, userProfileId);
      expect(membership.role, PartyMembershipRole.member);
      expect(membership.status, PartyMembershipStatus.pending);
      expect(membership.isPrimary, false);
    });

    test('rejects invalid role for party kind', () async {
      final testSession = session();
      final association = await parties.createParty(
        testSession,
        kind: PartyKind.association,
        name: 'Association',
      );

      await expectLater(
        parties.joinParty(
          testSession,
          userProfileId: const Uuid().v7obj(),
          partyId: association.id!,
          role: PartyMembershipRole.consultant,
          status: PartyMembershipStatus.pending,
          isPrimary: false,
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate membership', () async {
      final userProfileId = const Uuid().v7obj();
      final testSession = session();
      final party = await parties.createParty(
        testSession,
        kind: PartyKind.company,
        name: 'Acme Corp',
      );

      await parties.joinParty(
        testSession,
        userProfileId: userProfileId,
        partyId: party.id!,
        role: PartyMembershipRole.member,
        status: PartyMembershipStatus.pending,
        isPrimary: false,
      );

      await expectLater(
        parties.joinParty(
          testSession,
          userProfileId: userProfileId,
          partyId: party.id!,
          role: PartyMembershipRole.member,
          status: PartyMembershipStatus.pending,
          isPrimary: false,
        ),
        throwsStateError,
      );
    });

    test(
      'membership queries do not leak another profile memberships',
      () async {
        final testSession = session();
        final profileA = const Uuid().v7obj();
        final profileB = const Uuid().v7obj();
        final partyA = await parties.createParty(
          testSession,
          kind: PartyKind.company,
          name: 'Tenant A Company',
        );
        final partyB = await parties.createParty(
          testSession,
          kind: PartyKind.association,
          name: 'Tenant B Association',
        );
        await parties.joinParty(
          testSession,
          userProfileId: profileA,
          partyId: partyA.id!,
          role: PartyMembershipRole.member,
          status: PartyMembershipStatus.active,
          isPrimary: true,
        );
        await parties.joinParty(
          testSession,
          userProfileId: profileB,
          partyId: partyB.id!,
          role: PartyMembershipRole.member,
          status: PartyMembershipStatus.pending,
          isPrimary: false,
        );

        final membershipsA = await parties.listMemberships(
          testSession,
          userProfileId: profileA,
        );
        final activeMembershipsB = await parties.listMemberships(
          testSession,
          userProfileId: profileB,
          status: PartyMembershipStatus.active,
        );

        expect(membershipsA, hasLength(1));
        expect(membershipsA.single.partyId, partyA.id);
        expect(membershipsA.single.userProfileId, profileA);
        expect(activeMembershipsB, isEmpty);
      },
    );
  });
}
