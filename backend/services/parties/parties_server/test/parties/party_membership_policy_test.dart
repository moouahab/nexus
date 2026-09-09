import 'package:parties_server/src/generated/protocol.dart';
import 'package:parties_server/src/parties/domain/party_membership_policy.dart';
import 'package:test/test.dart';

void main() {
  const policy = PartyMembershipPolicy();

  test('maps initial membership roles from party kind', () {
    expect(policy.initialRoleFor(PartyKind.company), PartyMembershipRole.owner);
    expect(
      policy.initialRoleFor(PartyKind.association),
      PartyMembershipRole.owner,
    );
    expect(
      policy.initialRoleFor(PartyKind.consultantPractice),
      PartyMembershipRole.consultant,
    );
  });

  test('allows roles from the role matrix only', () {
    expect(
      policy.canUseRoleForParty(
        role: PartyMembershipRole.clientReferent,
        partyKind: PartyKind.company,
      ),
      true,
    );
    expect(
      policy.canUseRoleForParty(
        role: PartyMembershipRole.consultant,
        partyKind: PartyKind.association,
      ),
      false,
    );
    expect(
      policy.canUseRoleForParty(
        role: PartyMembershipRole.member,
        partyKind: PartyKind.consultantPractice,
      ),
      false,
    );
  });
}
