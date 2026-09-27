import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

final class PartyAccess {
  const PartyAccess({
    required this.allowed,
    required this.canManage,
    this.role,
  });

  const PartyAccess.denied() : allowed = false, canManage = false, role = null;

  final bool allowed;
  final bool canManage;
  final PartyMembershipRole? role;

  Map<String, dynamic> toJson() => {
    'allowed': allowed,
    'canManage': canManage,
    if (role != null) 'role': role!.name,
  };
}

abstract interface class IdentityProfileResolver {
  Future<UuidValue?> findProfileId(
    Session session,
    UuidValue identityId,
  );
}

final class PartyAccessService {
  const PartyAccessService();

  static const managerRoles = <PartyMembershipRole>{
    PartyMembershipRole.owner,
    PartyMembershipRole.admin,
  };

  Future<PartyAccess> accessForProfile(
    Session session, {
    required UuidValue userProfileId,
    required UuidValue partyId,
  }) async {
    final membership = await PartyMembership.db.findFirstRow(
      session,
      where: (t) =>
          t.userProfileId.equals(userProfileId) &
          t.partyId.equals(partyId) &
          t.status.equals(PartyMembershipStatus.active),
    );
    if (membership == null) return const PartyAccess.denied();
    return PartyAccess(
      allowed: true,
      canManage: managerRoles.contains(membership.role),
      role: membership.role,
    );
  }

  Future<PartyAccess> accessForIdentity(
    Session session, {
    required UuidValue identityId,
    required UuidValue partyId,
    required IdentityProfileResolver profiles,
  }) async {
    final profileId = await profiles.findProfileId(session, identityId);
    if (profileId == null) return const PartyAccess.denied();
    return accessForProfile(
      session,
      userProfileId: profileId,
      partyId: partyId,
    );
  }

  Future<PartyAccess> requireIdentityCanAccessParty(
    Session session, {
    required UuidValue identityId,
    required UuidValue partyId,
    required IdentityProfileResolver profiles,
    bool management = false,
  }) async {
    final access = await accessForIdentity(
      session,
      identityId: identityId,
      partyId: partyId,
      profiles: profiles,
    );
    if (!access.allowed || (management && !access.canManage)) {
      throw StateError('Party not found.');
    }
    return access;
  }

  Future<List<Party>> listPartiesForIdentity(
    Session session, {
    required UuidValue identityId,
    required IdentityProfileResolver profiles,
    PartyKind? kind,
    PartyStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 100 || offset < 0) {
      throw ArgumentError('Invalid pagination.');
    }
    final profileId = await profiles.findProfileId(session, identityId);
    if (profileId == null) return const [];
    final memberships = await PartyMembership.db.find(
      session,
      where: (t) =>
          t.userProfileId.equals(profileId) &
          t.status.equals(PartyMembershipStatus.active),
    );
    final partyIds = memberships.map((item) => item.partyId).toSet();
    if (partyIds.isEmpty) return const [];
    return Party.db.find(
      session,
      where: (t) {
        var expression = t.id.inSet(partyIds);
        if (kind != null) expression = expression & t.kind.equals(kind);
        if (status != null) expression = expression & t.status.equals(status);
        return expression;
      },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }
}
