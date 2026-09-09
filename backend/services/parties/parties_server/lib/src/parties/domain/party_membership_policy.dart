import '../../generated/protocol.dart';

class PartyMembershipPolicy {
  const PartyMembershipPolicy();

  static const initialRoleByPartyKind = <PartyKind, PartyMembershipRole>{
    PartyKind.company: PartyMembershipRole.owner,
    PartyKind.association: PartyMembershipRole.owner,
    PartyKind.consultantPractice: PartyMembershipRole.consultant,
  };

  static const allowedRolesByPartyKind = <PartyKind, Set<PartyMembershipRole>>{
    PartyKind.company: {
      PartyMembershipRole.owner,
      PartyMembershipRole.admin,
      PartyMembershipRole.member,
      PartyMembershipRole.clientReferent,
    },
    PartyKind.association: {
      PartyMembershipRole.owner,
      PartyMembershipRole.admin,
      PartyMembershipRole.member,
      PartyMembershipRole.clientReferent,
    },
    PartyKind.consultantPractice: {
      PartyMembershipRole.owner,
      PartyMembershipRole.admin,
      PartyMembershipRole.consultant,
    },
  };

  PartyMembershipRole initialRoleFor(PartyKind kind) {
    return initialRoleByPartyKind[kind]!;
  }

  bool canUseRoleForParty({
    required PartyMembershipRole role,
    required PartyKind partyKind,
  }) {
    return allowedRolesByPartyKind[partyKind]?.contains(role) ?? false;
  }
}
