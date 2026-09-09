/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:projects_client/src/protocol/projects/models/project.dart'
    as _i3;
import 'package:projects_client/src/protocol/projects/models/project_visibility.dart'
    as _i4;
import 'package:projects_client/src/protocol/projects/models/project_status.dart'
    as _i5;
import 'package:projects_client/src/protocol/projects/models/project_participant.dart'
    as _i6;
import 'package:projects_client/src/protocol/projects/models/project_participant_role.dart'
    as _i7;
import 'package:projects_client/src/protocol/projects/models/project_participant_status.dart'
    as _i8;
import 'package:projects_client/src/protocol/projects/models/project_link.dart'
    as _i9;
import 'package:projects_client/src/protocol/projects/models/project_link_kind.dart'
    as _i10;
import 'package:projects_client/src/protocol/projects/models/project_link_status.dart'
    as _i11;
import 'package:projects_client/src/protocol/projects/models/project_event.dart'
    as _i12;
import 'protocol.dart' as _i13;

/// {@category Endpoint}
class EndpointProject extends _i1.EndpointRef {
  EndpointProject(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'project';

  _i2.Future<_i3.Project> createMyProject({
    required String slug,
    required String name,
    String? summary,
    required _i4.ProjectVisibility visibility,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i3.Project>(
    'project',
    'createMyProject',
    {
      'slug': slug,
      'name': name,
      'summary': summary,
      'visibility': visibility,
      'workspacePath': workspacePath,
      'tags': tags,
      'metadata': metadata,
    },
  );

  _i2.Future<_i3.Project> createProject({
    required String slug,
    required String name,
    String? summary,
    required _i4.ProjectVisibility visibility,
    _i1.UuidValue? ownerIdentityId,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i3.Project>(
    'project',
    'createProject',
    {
      'slug': slug,
      'name': name,
      'summary': summary,
      'visibility': visibility,
      'ownerIdentityId': ownerIdentityId,
      'workspacePath': workspacePath,
      'tags': tags,
      'metadata': metadata,
    },
  );

  _i2.Future<List<_i3.Project>> listProjects({
    _i5.ProjectStatus? status,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i3.Project>>(
    'project',
    'listProjects',
    {
      'status': status,
      'limit': limit,
      'offset': offset,
    },
  );

  _i2.Future<_i3.Project> getProject(_i1.UuidValue projectId) =>
      caller.callServerEndpoint<_i3.Project>(
        'project',
        'getProject',
        {'projectId': projectId},
      );

  _i2.Future<_i3.Project> getProjectBySlug(String slug) =>
      caller.callServerEndpoint<_i3.Project>(
        'project',
        'getProjectBySlug',
        {'slug': slug},
      );

  _i2.Future<_i3.Project> updateProjectProfile({
    required _i1.UuidValue projectId,
    String? name,
    String? summary,
    _i4.ProjectVisibility? visibility,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
    _i1.UuidValue? actorIdentityId,
  }) => caller.callServerEndpoint<_i3.Project>(
    'project',
    'updateProjectProfile',
    {
      'projectId': projectId,
      'name': name,
      'summary': summary,
      'visibility': visibility,
      'workspacePath': workspacePath,
      'tags': tags,
      'metadata': metadata,
      'actorIdentityId': actorIdentityId,
    },
  );

  _i2.Future<_i3.Project> changeProjectStatus({
    required _i1.UuidValue projectId,
    required _i5.ProjectStatus status,
    _i1.UuidValue? actorIdentityId,
    String? reason,
  }) => caller.callServerEndpoint<_i3.Project>(
    'project',
    'changeProjectStatus',
    {
      'projectId': projectId,
      'status': status,
      'actorIdentityId': actorIdentityId,
      'reason': reason,
    },
  );

  _i2.Future<_i3.Project> archiveProject({
    required _i1.UuidValue projectId,
    String? archivePath,
    String? reason,
    _i1.UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i3.Project>(
    'project',
    'archiveProject',
    {
      'projectId': projectId,
      'archivePath': archivePath,
      'reason': reason,
      'actorIdentityId': actorIdentityId,
      'metadata': metadata,
    },
  );

  _i2.Future<_i3.Project> restoreProject({
    required _i1.UuidValue projectId,
    _i1.UuidValue? actorIdentityId,
    String? reason,
  }) => caller.callServerEndpoint<_i3.Project>(
    'project',
    'restoreProject',
    {
      'projectId': projectId,
      'actorIdentityId': actorIdentityId,
      'reason': reason,
    },
  );

  _i2.Future<_i6.ProjectParticipant> assignProjectMember({
    required _i1.UuidValue projectId,
    required _i7.ProjectParticipantRole role,
    _i1.UuidValue? identityId,
    String? displayName,
    String? email,
    required bool isPrimary,
    _i1.UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i6.ProjectParticipant>(
    'project',
    'assignProjectMember',
    {
      'projectId': projectId,
      'role': role,
      'identityId': identityId,
      'displayName': displayName,
      'email': email,
      'isPrimary': isPrimary,
      'actorIdentityId': actorIdentityId,
      'metadata': metadata,
    },
  );

  _i2.Future<_i6.ProjectParticipant> setProjectClient({
    required _i1.UuidValue projectId,
    required String organizationName,
    String? externalId,
    String? displayName,
    String? email,
    String? phone,
    String? notes,
    _i1.UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i6.ProjectParticipant>(
    'project',
    'setProjectClient',
    {
      'projectId': projectId,
      'organizationName': organizationName,
      'externalId': externalId,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'notes': notes,
      'actorIdentityId': actorIdentityId,
      'metadata': metadata,
    },
  );

  _i2.Future<_i6.ProjectParticipant> setClientReferent({
    required _i1.UuidValue projectId,
    required String displayName,
    String? externalId,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    _i1.UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) => caller.callServerEndpoint<_i6.ProjectParticipant>(
    'project',
    'setClientReferent',
    {
      'projectId': projectId,
      'displayName': displayName,
      'externalId': externalId,
      'organizationName': organizationName,
      'email': email,
      'phone': phone,
      'notes': notes,
      'actorIdentityId': actorIdentityId,
      'metadata': metadata,
    },
  );

  _i2.Future<List<_i6.ProjectParticipant>> listParticipants({
    required _i1.UuidValue projectId,
    _i7.ProjectParticipantRole? role,
    _i8.ProjectParticipantStatus? status,
  }) => caller.callServerEndpoint<List<_i6.ProjectParticipant>>(
    'project',
    'listParticipants',
    {
      'projectId': projectId,
      'role': role,
      'status': status,
    },
  );

  _i2.Future<_i6.ProjectParticipant> removeParticipant({
    required _i1.UuidValue participantId,
    _i1.UuidValue? actorIdentityId,
  }) => caller.callServerEndpoint<_i6.ProjectParticipant>(
    'project',
    'removeParticipant',
    {
      'participantId': participantId,
      'actorIdentityId': actorIdentityId,
    },
  );

  _i2.Future<_i9.ProjectLink> linkResource({
    required _i1.UuidValue projectId,
    required _i10.ProjectLinkKind kind,
    required String externalId,
    String? service,
    String? label,
    String? uri,
    Map<String, String>? metadata,
    _i1.UuidValue? actorIdentityId,
  }) => caller.callServerEndpoint<_i9.ProjectLink>(
    'project',
    'linkResource',
    {
      'projectId': projectId,
      'kind': kind,
      'externalId': externalId,
      'service': service,
      'label': label,
      'uri': uri,
      'metadata': metadata,
      'actorIdentityId': actorIdentityId,
    },
  );

  _i2.Future<_i9.ProjectLink> detachLink({
    required _i1.UuidValue linkId,
    _i1.UuidValue? actorIdentityId,
  }) => caller.callServerEndpoint<_i9.ProjectLink>(
    'project',
    'detachLink',
    {
      'linkId': linkId,
      'actorIdentityId': actorIdentityId,
    },
  );

  _i2.Future<List<_i9.ProjectLink>> listLinks({
    required _i1.UuidValue projectId,
    _i10.ProjectLinkKind? kind,
    _i11.ProjectLinkStatus? status,
  }) => caller.callServerEndpoint<List<_i9.ProjectLink>>(
    'project',
    'listLinks',
    {
      'projectId': projectId,
      'kind': kind,
      'status': status,
    },
  );

  _i2.Future<List<_i12.ProjectEvent>> listEvents({
    required _i1.UuidValue projectId,
    required int limit,
    required int offset,
  }) => caller.callServerEndpoint<List<_i12.ProjectEvent>>(
    'project',
    'listEvents',
    {
      'projectId': projectId,
      'limit': limit,
      'offset': offset,
    },
  );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i13.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    project = EndpointProject(this);
  }

  late final EndpointProject project;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {'project': project};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
