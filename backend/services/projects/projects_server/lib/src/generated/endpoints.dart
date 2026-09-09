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
import 'package:serverpod/serverpod.dart' as _i1;
import '../projects/project_endpoint.dart' as _i2;
import 'package:projects_server/src/generated/projects/models/project_visibility.dart'
    as _i3;
import 'package:projects_server/src/generated/projects/models/project_status.dart'
    as _i4;
import 'package:projects_server/src/generated/projects/models/project_participant_role.dart'
    as _i5;
import 'package:projects_server/src/generated/projects/models/project_participant_status.dart'
    as _i6;
import 'package:projects_server/src/generated/projects/models/project_link_kind.dart'
    as _i7;
import 'package:projects_server/src/generated/projects/models/project_link_status.dart'
    as _i8;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'project': _i2.ProjectEndpoint()
        ..initialize(
          server,
          'project',
          null,
        ),
    };
    connectors['project'] = _i1.EndpointConnector(
      name: 'project',
      endpoint: endpoints['project']!,
      methodConnectors: {
        'createMyProject': _i1.MethodConnector(
          name: 'createMyProject',
          params: {
            'slug': _i1.ParameterDescription(
              name: 'slug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'summary': _i1.ParameterDescription(
              name: 'summary',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'visibility': _i1.ParameterDescription(
              name: 'visibility',
              type: _i1.getType<_i3.ProjectVisibility>(),
              nullable: false,
            ),
            'workspacePath': _i1.ParameterDescription(
              name: 'workspacePath',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'tags': _i1.ParameterDescription(
              name: 'tags',
              type: _i1.getType<List<String>?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).createMyProject(
                    session,
                    slug: params['slug'],
                    name: params['name'],
                    summary: params['summary'],
                    visibility: params['visibility'],
                    workspacePath: params['workspacePath'],
                    tags: params['tags'],
                    metadata: params['metadata'],
                  ),
        ),
        'createProject': _i1.MethodConnector(
          name: 'createProject',
          params: {
            'slug': _i1.ParameterDescription(
              name: 'slug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'summary': _i1.ParameterDescription(
              name: 'summary',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'visibility': _i1.ParameterDescription(
              name: 'visibility',
              type: _i1.getType<_i3.ProjectVisibility>(),
              nullable: false,
            ),
            'ownerIdentityId': _i1.ParameterDescription(
              name: 'ownerIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'workspacePath': _i1.ParameterDescription(
              name: 'workspacePath',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'tags': _i1.ParameterDescription(
              name: 'tags',
              type: _i1.getType<List<String>?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).createProject(
                    session,
                    slug: params['slug'],
                    name: params['name'],
                    summary: params['summary'],
                    visibility: params['visibility'],
                    ownerIdentityId: params['ownerIdentityId'],
                    workspacePath: params['workspacePath'],
                    tags: params['tags'],
                    metadata: params['metadata'],
                  ),
        ),
        'listProjects': _i1.MethodConnector(
          name: 'listProjects',
          params: {
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i4.ProjectStatus?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).listProjects(
                    session,
                    status: params['status'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getProject': _i1.MethodConnector(
          name: 'getProject',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).getProject(
                    session,
                    params['projectId'],
                  ),
        ),
        'getProjectBySlug': _i1.MethodConnector(
          name: 'getProjectBySlug',
          params: {
            'slug': _i1.ParameterDescription(
              name: 'slug',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .getProjectBySlug(
                    session,
                    params['slug'],
                  ),
        ),
        'updateProjectProfile': _i1.MethodConnector(
          name: 'updateProjectProfile',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'summary': _i1.ParameterDescription(
              name: 'summary',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'visibility': _i1.ParameterDescription(
              name: 'visibility',
              type: _i1.getType<_i3.ProjectVisibility?>(),
              nullable: true,
            ),
            'workspacePath': _i1.ParameterDescription(
              name: 'workspacePath',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'tags': _i1.ParameterDescription(
              name: 'tags',
              type: _i1.getType<List<String>?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .updateProjectProfile(
                    session,
                    projectId: params['projectId'],
                    name: params['name'],
                    summary: params['summary'],
                    visibility: params['visibility'],
                    workspacePath: params['workspacePath'],
                    tags: params['tags'],
                    metadata: params['metadata'],
                    actorIdentityId: params['actorIdentityId'],
                  ),
        ),
        'changeProjectStatus': _i1.MethodConnector(
          name: 'changeProjectStatus',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i4.ProjectStatus>(),
              nullable: false,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .changeProjectStatus(
                    session,
                    projectId: params['projectId'],
                    status: params['status'],
                    actorIdentityId: params['actorIdentityId'],
                    reason: params['reason'],
                  ),
        ),
        'archiveProject': _i1.MethodConnector(
          name: 'archiveProject',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'archivePath': _i1.ParameterDescription(
              name: 'archivePath',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).archiveProject(
                    session,
                    projectId: params['projectId'],
                    archivePath: params['archivePath'],
                    reason: params['reason'],
                    actorIdentityId: params['actorIdentityId'],
                    metadata: params['metadata'],
                  ),
        ),
        'restoreProject': _i1.MethodConnector(
          name: 'restoreProject',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).restoreProject(
                    session,
                    projectId: params['projectId'],
                    actorIdentityId: params['actorIdentityId'],
                    reason: params['reason'],
                  ),
        ),
        'assignProjectMember': _i1.MethodConnector(
          name: 'assignProjectMember',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i5.ProjectParticipantRole>(),
              nullable: false,
            ),
            'identityId': _i1.ParameterDescription(
              name: 'identityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'displayName': _i1.ParameterDescription(
              name: 'displayName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'isPrimary': _i1.ParameterDescription(
              name: 'isPrimary',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .assignProjectMember(
                    session,
                    projectId: params['projectId'],
                    role: params['role'],
                    identityId: params['identityId'],
                    displayName: params['displayName'],
                    email: params['email'],
                    isPrimary: params['isPrimary'],
                    actorIdentityId: params['actorIdentityId'],
                    metadata: params['metadata'],
                  ),
        ),
        'setProjectClient': _i1.MethodConnector(
          name: 'setProjectClient',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'organizationName': _i1.ParameterDescription(
              name: 'organizationName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'externalId': _i1.ParameterDescription(
              name: 'externalId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'displayName': _i1.ParameterDescription(
              name: 'displayName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'notes': _i1.ParameterDescription(
              name: 'notes',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .setProjectClient(
                    session,
                    projectId: params['projectId'],
                    organizationName: params['organizationName'],
                    externalId: params['externalId'],
                    displayName: params['displayName'],
                    email: params['email'],
                    phone: params['phone'],
                    notes: params['notes'],
                    actorIdentityId: params['actorIdentityId'],
                    metadata: params['metadata'],
                  ),
        ),
        'setClientReferent': _i1.MethodConnector(
          name: 'setClientReferent',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'displayName': _i1.ParameterDescription(
              name: 'displayName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'externalId': _i1.ParameterDescription(
              name: 'externalId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'organizationName': _i1.ParameterDescription(
              name: 'organizationName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'notes': _i1.ParameterDescription(
              name: 'notes',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .setClientReferent(
                    session,
                    projectId: params['projectId'],
                    displayName: params['displayName'],
                    externalId: params['externalId'],
                    organizationName: params['organizationName'],
                    email: params['email'],
                    phone: params['phone'],
                    notes: params['notes'],
                    actorIdentityId: params['actorIdentityId'],
                    metadata: params['metadata'],
                  ),
        ),
        'listParticipants': _i1.MethodConnector(
          name: 'listParticipants',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<_i5.ProjectParticipantRole?>(),
              nullable: true,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i6.ProjectParticipantStatus?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .listParticipants(
                    session,
                    projectId: params['projectId'],
                    role: params['role'],
                    status: params['status'],
                  ),
        ),
        'removeParticipant': _i1.MethodConnector(
          name: 'removeParticipant',
          params: {
            'participantId': _i1.ParameterDescription(
              name: 'participantId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['project'] as _i2.ProjectEndpoint)
                  .removeParticipant(
                    session,
                    participantId: params['participantId'],
                    actorIdentityId: params['actorIdentityId'],
                  ),
        ),
        'linkResource': _i1.MethodConnector(
          name: 'linkResource',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'kind': _i1.ParameterDescription(
              name: 'kind',
              type: _i1.getType<_i7.ProjectLinkKind>(),
              nullable: false,
            ),
            'externalId': _i1.ParameterDescription(
              name: 'externalId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'service': _i1.ParameterDescription(
              name: 'service',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'uri': _i1.ParameterDescription(
              name: 'uri',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'metadata': _i1.ParameterDescription(
              name: 'metadata',
              type: _i1.getType<Map<String, String>?>(),
              nullable: true,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).linkResource(
                    session,
                    projectId: params['projectId'],
                    kind: params['kind'],
                    externalId: params['externalId'],
                    service: params['service'],
                    label: params['label'],
                    uri: params['uri'],
                    metadata: params['metadata'],
                    actorIdentityId: params['actorIdentityId'],
                  ),
        ),
        'detachLink': _i1.MethodConnector(
          name: 'detachLink',
          params: {
            'linkId': _i1.ParameterDescription(
              name: 'linkId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'actorIdentityId': _i1.ParameterDescription(
              name: 'actorIdentityId',
              type: _i1.getType<_i1.UuidValue?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).detachLink(
                    session,
                    linkId: params['linkId'],
                    actorIdentityId: params['actorIdentityId'],
                  ),
        ),
        'listLinks': _i1.MethodConnector(
          name: 'listLinks',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'kind': _i1.ParameterDescription(
              name: 'kind',
              type: _i1.getType<_i7.ProjectLinkKind?>(),
              nullable: true,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i8.ProjectLinkStatus?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).listLinks(
                    session,
                    projectId: params['projectId'],
                    kind: params['kind'],
                    status: params['status'],
                  ),
        ),
        'listEvents': _i1.MethodConnector(
          name: 'listEvents',
          params: {
            'projectId': _i1.ParameterDescription(
              name: 'projectId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['project'] as _i2.ProjectEndpoint).listEvents(
                    session,
                    projectId: params['projectId'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
      },
    );
  }
}
