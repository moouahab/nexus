import '../../generated/protocol.dart';

Map<String, dynamic> partyJson(Party party) => {
  if (party.id != null) 'id': party.id.toString(),
  'kind': party.kind.name,
  'status': party.status.name,
  'name': party.name,
  if (party.legalName != null) 'legalName': party.legalName,
  if (party.registrationNumber != null)
    'registrationNumber': party.registrationNumber,
  if (party.country != null) 'country': party.country,
  if (party.website != null) 'website': party.website,
  if (party.metadata != null) 'metadata': party.metadata,
  'createdAt': party.createdAt.toUtc().toIso8601String(),
  if (party.updatedAt != null)
    'updatedAt': party.updatedAt!.toUtc().toIso8601String(),
};

Map<String, dynamic> partyMembershipJson(PartyMembership membership) => {
  if (membership.id != null) 'id': membership.id.toString(),
  'userProfileId': membership.userProfileId.toString(),
  'partyId': membership.partyId.toString(),
  'role': membership.role.name,
  'status': membership.status.name,
  'isPrimary': membership.isPrimary,
  if (membership.title != null) 'title': membership.title,
  if (membership.invitedByIdentityId != null)
    'invitedByIdentityId': membership.invitedByIdentityId.toString(),
  if (membership.metadata != null) 'metadata': membership.metadata,
  'createdAt': membership.createdAt.toUtc().toIso8601String(),
  if (membership.updatedAt != null)
    'updatedAt': membership.updatedAt!.toUtc().toIso8601String(),
};
