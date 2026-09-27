import '../../generated/protocol.dart';

Map<String, dynamic> projectJson(Project value) => {
  'id': value.id.toString(),
  'slug': value.slug,
  'name': value.name,
  if (value.summary != null) 'summary': value.summary,
  'status': value.status.name,
  'visibility': value.visibility.name,
  if (value.tenantPartyId != null)
    'tenantPartyId': value.tenantPartyId.toString(),
  if (value.ownerIdentityId != null)
    'ownerIdentityId': value.ownerIdentityId.toString(),
  'tags': value.tags ?? const <String>[],
  'metadata': value.metadata ?? const <String, String>{},
  'createdAt': value.createdAt.toUtc().toIso8601String(),
  if (value.updatedAt != null)
    'updatedAt': value.updatedAt!.toUtc().toIso8601String(),
  if (value.archivedAt != null)
    'archivedAt': value.archivedAt!.toUtc().toIso8601String(),
};

Map<String, dynamic> participantJson(ProjectParticipant value) => {
  'id': value.id.toString(),
  'projectId': value.projectId.toString(),
  'role': value.role.name,
  'status': value.status.name,
  if (value.identityId != null) 'identityId': value.identityId.toString(),
  if (value.externalId != null) 'externalId': value.externalId,
  if (value.displayName != null) 'displayName': value.displayName,
  if (value.organizationName != null)
    'organizationName': value.organizationName,
  if (value.email != null) 'email': value.email,
  if (value.phone != null) 'phone': value.phone,
  if (value.notes != null) 'notes': value.notes,
  'isPrimary': value.isPrimary,
  'metadata': value.metadata ?? const <String, String>{},
  'createdAt': value.createdAt.toUtc().toIso8601String(),
  if (value.updatedAt != null)
    'updatedAt': value.updatedAt!.toUtc().toIso8601String(),
};

Map<String, dynamic> linkJson(ProjectLink value) => {
  'id': value.id.toString(),
  'projectId': value.projectId.toString(),
  'kind': value.kind.name,
  'service': value.service,
  'externalId': value.externalId,
  if (value.label != null) 'label': value.label,
  if (value.uri != null) 'uri': value.uri,
  'status': value.status.name,
  'metadata': value.metadata ?? const <String, String>{},
  'createdAt': value.createdAt.toUtc().toIso8601String(),
  if (value.updatedAt != null)
    'updatedAt': value.updatedAt!.toUtc().toIso8601String(),
};

Map<String, dynamic> eventJson(ProjectEvent value) => {
  'id': value.id.toString(),
  'projectId': value.projectId.toString(),
  'kind': value.kind.name,
  if (value.message != null) 'message': value.message,
  if (value.actorIdentityId != null)
    'actorIdentityId': value.actorIdentityId.toString(),
  if (value.resourceKind != null) 'resourceKind': value.resourceKind!.name,
  if (value.resourceService != null) 'resourceService': value.resourceService,
  if (value.resourceExternalId != null)
    'resourceExternalId': value.resourceExternalId,
  'payload': value.payload ?? const <String, String>{},
  'occurredAt': value.occurredAt.toUtc().toIso8601String(),
};
