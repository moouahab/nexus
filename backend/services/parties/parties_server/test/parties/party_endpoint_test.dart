import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:parties_server/src/generated/protocol.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Party endpoint', (sessionBuilder, endpoints) {
    test('creates a company party', () async {
      final party = await endpoints.party.createParty(
        sessionBuilder,
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

      final membership = await endpoints.party.createPartyWithOwner(
        sessionBuilder,
        userProfileId: userProfileId,
        kind: PartyKind.consultantPractice,
        name: 'Alice Advisory',
      );
      final party = await endpoints.party.getParty(
        sessionBuilder,
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
      final association = await endpoints.party.createParty(
        sessionBuilder,
        kind: PartyKind.association,
        name: 'Open Rights Association',
      );

      final membership = await endpoints.party.joinParty(
        sessionBuilder,
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
      final association = await endpoints.party.createParty(
        sessionBuilder,
        kind: PartyKind.association,
        name: 'Association',
      );

      await expectLater(
        endpoints.party.joinParty(
          sessionBuilder,
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
      final party = await endpoints.party.createParty(
        sessionBuilder,
        kind: PartyKind.company,
        name: 'Acme Corp',
      );

      await endpoints.party.joinParty(
        sessionBuilder,
        userProfileId: userProfileId,
        partyId: party.id!,
        role: PartyMembershipRole.member,
        status: PartyMembershipStatus.pending,
        isPrimary: false,
      );

      await expectLater(
        endpoints.party.joinParty(
          sessionBuilder,
          userProfileId: userProfileId,
          partyId: party.id!,
          role: PartyMembershipRole.member,
          status: PartyMembershipStatus.pending,
          isPrimary: false,
        ),
        throwsStateError,
      );
    });
  });
}
