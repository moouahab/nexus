import '../../generated/protocol.dart';

Map<String, dynamic> userProfileJson(UserProfile profile) => {
  if (profile.id != null) 'id': profile.id.toString(),
  'identityId': profile.identityId.toString(),
  'displayName': profile.displayName,
  'kind': profile.kind.name,
  'status': profile.status.name,
  if (profile.primaryPartyId != null)
    'primaryPartyId': profile.primaryPartyId.toString(),
  if (profile.email != null) 'email': profile.email,
  if (profile.avatarUri != null) 'avatarUri': profile.avatarUri,
  if (profile.bio != null) 'bio': profile.bio,
  if (profile.locale != null) 'locale': profile.locale,
  if (profile.timezone != null) 'timezone': profile.timezone,
  if (profile.metadata != null) 'metadata': profile.metadata,
  'createdAt': profile.createdAt.toUtc().toIso8601String(),
  if (profile.updatedAt != null)
    'updatedAt': profile.updatedAt!.toUtc().toIso8601String(),
};
