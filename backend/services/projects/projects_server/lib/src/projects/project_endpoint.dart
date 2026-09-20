import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/project_registry_service.dart';

class ProjectEndpoint extends Endpoint {
  static const _registry = ProjectRegistryService();
  static const _userAuth = AuthContextResolver();
  static const _serviceAuth = AuthContextResolver(audience: 'projects-service');
  static const _readScope = 'projects.read';
  static const _writeScope = 'projects.write';

  Future<Project> createMyProject(
    Session session, {
    required String slug,
    required String name,
    required UuidValue tenantPartyId,
    String? summary,
    ProjectVisibility visibility = ProjectVisibility.private,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
  }) {
    final auth = _requireUserContext(session);
    return _registry.createProject(
      session,
      slug: slug,
      name: name,
      tenantPartyId: tenantPartyId,
      summary: summary,
      visibility: visibility,
      ownerIdentityId: auth.identityId,
      workspacePath: workspacePath,
      tags: tags,
      metadata: metadata,
    );
  }

  Future<Project> createProject(
    Session session, {
    required String slug,
    required String name,
    required UuidValue tenantPartyId,
    String? summary,
    ProjectVisibility visibility = ProjectVisibility.private,
    UuidValue? ownerIdentityId,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
  }) {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    return _registry.createProject(
      session,
      slug: slug,
      name: name,
      tenantPartyId: tenantPartyId,
      summary: summary,
      visibility: visibility,
      ownerIdentityId: caller.identityId ?? ownerIdentityId,
      workspacePath: workspacePath,
      tags: tags,
      metadata: metadata,
    );
  }

  Future<List<Project>> listProjects(
    Session session, {
    required UuidValue tenantPartyId,
    ProjectStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final caller = _requireCaller(session, serviceScopes: const [_readScope]);
    if (caller.identityId != null) {
      return _registry.listProjectsVisibleToIdentity(
        session,
        identityId: caller.identityId!,
        tenantPartyId: tenantPartyId,
        status: status,
        limit: limit,
        offset: offset,
      );
    }
    return _registry.listProjects(
      session,
      tenantPartyId: tenantPartyId,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  Future<Project> getProject(Session session, UuidValue projectId) async {
    await _requireProjectRead(session, projectId);
    return _registry.getProject(session, projectId);
  }

  Future<bool> canUseAiForProject(
    Session session, {
    required UuidValue projectId,
    required UuidValue tenantPartyId,
  }) async {
    await _requireProjectRead(session, projectId);
    final project = await _registry.getProject(session, projectId);
    return project.tenantPartyId == tenantPartyId;
  }

  Future<Project> getProjectBySlug(Session session, String slug) async {
    final project = await _registry.getProjectBySlug(session, slug);
    await _requireProjectRead(session, project.id!);
    return project;
  }

  Future<Project> updateProjectProfile(
    Session session, {
    required UuidValue projectId,
    String? name,
    String? summary,
    ProjectVisibility? visibility,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
    UuidValue? actorIdentityId,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.updateProjectProfile(
      session,
      projectId: projectId,
      name: name,
      summary: summary,
      visibility: visibility,
      workspacePath: workspacePath,
      tags: tags,
      metadata: metadata,
      actorIdentityId: actor,
    );
  }

  Future<Project> changeProjectStatus(
    Session session, {
    required UuidValue projectId,
    required ProjectStatus status,
    UuidValue? actorIdentityId,
    String? reason,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.changeStatus(
      session,
      projectId: projectId,
      status: status,
      actorIdentityId: actor,
      reason: reason,
    );
  }

  Future<Project> archiveProject(
    Session session, {
    required UuidValue projectId,
    String? archivePath,
    String? reason,
    UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.archiveProject(
      session,
      projectId: projectId,
      archivePath: archivePath,
      reason: reason,
      actorIdentityId: actor,
      metadata: metadata,
    );
  }

  Future<Project> restoreProject(
    Session session, {
    required UuidValue projectId,
    UuidValue? actorIdentityId,
    String? reason,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.restoreProject(
      session,
      projectId: projectId,
      actorIdentityId: actor,
      reason: reason,
    );
  }

  Future<ProjectParticipant> assignProjectMember(
    Session session, {
    required UuidValue projectId,
    required ProjectParticipantRole role,
    UuidValue? identityId,
    String? displayName,
    String? email,
    bool isPrimary = false,
    UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.assignProjectMember(
      session,
      projectId: projectId,
      role: role,
      identityId: identityId,
      displayName: displayName,
      email: email,
      isPrimary: isPrimary,
      actorIdentityId: actor,
      metadata: metadata,
    );
  }

  Future<ProjectParticipant> setProjectClient(
    Session session, {
    required UuidValue projectId,
    required String organizationName,
    String? externalId,
    String? displayName,
    String? email,
    String? phone,
    String? notes,
    UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.setProjectClient(
      session,
      projectId: projectId,
      organizationName: organizationName,
      externalId: externalId,
      displayName: displayName,
      email: email,
      phone: phone,
      notes: notes,
      actorIdentityId: actor,
      metadata: metadata,
    );
  }

  Future<ProjectParticipant> setClientReferent(
    Session session, {
    required UuidValue projectId,
    required String displayName,
    String? externalId,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.setClientReferent(
      session,
      projectId: projectId,
      displayName: displayName,
      externalId: externalId,
      organizationName: organizationName,
      email: email,
      phone: phone,
      notes: notes,
      actorIdentityId: actor,
      metadata: metadata,
    );
  }

  Future<List<ProjectParticipant>> listParticipants(
    Session session, {
    required UuidValue projectId,
    ProjectParticipantRole? role,
    ProjectParticipantStatus? status,
  }) async {
    await _requireProjectRead(session, projectId);
    return _registry.listParticipants(
      session,
      projectId: projectId,
      role: role,
      status: status,
    );
  }

  Future<ProjectParticipant> removeParticipant(
    Session session, {
    required UuidValue participantId,
    UuidValue? actorIdentityId,
  }) async {
    final caller = await _requireParticipantManagement(session, participantId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.removeParticipant(
      session,
      participantId: participantId,
      actorIdentityId: actor,
    );
  }

  Future<ProjectLink> linkResource(
    Session session, {
    required UuidValue projectId,
    required ProjectLinkKind kind,
    required String externalId,
    String? service,
    String? label,
    String? uri,
    Map<String, String>? metadata,
    UuidValue? actorIdentityId,
  }) async {
    final caller = await _requireProjectManagement(session, projectId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.linkResource(
      session,
      projectId: projectId,
      kind: kind,
      externalId: externalId,
      service: service,
      label: label,
      uri: uri,
      metadata: metadata,
      actorIdentityId: actor,
    );
  }

  Future<ProjectLink> detachLink(
    Session session, {
    required UuidValue linkId,
    UuidValue? actorIdentityId,
  }) async {
    final caller = await _requireLinkManagement(session, linkId);
    final actor = _actorIdentityId(caller, actorIdentityId);
    return _registry.detachLink(
      session,
      linkId: linkId,
      actorIdentityId: actor,
    );
  }

  Future<List<ProjectLink>> listLinks(
    Session session, {
    required UuidValue projectId,
    ProjectLinkKind? kind,
    ProjectLinkStatus? status,
  }) async {
    await _requireProjectRead(session, projectId);
    return _registry.listLinks(
      session,
      projectId: projectId,
      kind: kind,
      status: status,
    );
  }

  Future<List<ProjectEvent>> listEvents(
    Session session, {
    required UuidValue projectId,
    int limit = 100,
    int offset = 0,
  }) async {
    await _requireProjectRead(session, projectId);
    return _registry.listEvents(
      session,
      projectId: projectId,
      limit: limit,
      offset: offset,
    );
  }

  _ProjectCaller _requireCaller(
    Session session, {
    required Iterable<String> serviceScopes,
  }) {
    try {
      return _ProjectCaller.user(_userAuth.requireContext(session));
    } on NexusAuthException catch (error) {
      if (error.code != NexusAuthExceptionCode.invalidAccessToken) {
        throw _notAuthorized(error);
      }
      try {
        return _ProjectCaller.service(
          _serviceAuth.requireServiceContext(
            session,
            requiredScopes: serviceScopes,
          ),
        );
      } on NexusAuthException catch (serviceError) {
        throw _notAuthorized(serviceError);
      }
    }
  }

  AuthContext _requireUserContext(Session session) {
    try {
      return _userAuth.requireContext(session);
    } on NexusAuthException catch (error) {
      throw _notAuthorized(error);
    }
  }

  NotAuthorizedException _notAuthorized(NexusAuthException error) {
    return NotAuthorizedException(
      reason: _authFailureReason(error),
      message: 'Authentication failed.',
    );
  }

  AuthenticationFailureReason _authFailureReason(NexusAuthException error) {
    return switch (error.code) {
      NexusAuthExceptionCode.missingAccessToken ||
      NexusAuthExceptionCode.invalidAccessToken =>
        AuthenticationFailureReason.unauthenticated,
      NexusAuthExceptionCode.missingAuthSecret ||
      NexusAuthExceptionCode.missingRequest =>
        AuthenticationFailureReason.insufficientAccess,
    };
  }

  UuidValue? _actorIdentityId(
    _ProjectCaller caller,
    UuidValue? internalActorIdentityId,
  ) {
    return caller.identityId ?? internalActorIdentityId;
  }

  Future<_ProjectCaller> _requireProjectRead(
    Session session,
    UuidValue projectId,
  ) async {
    final caller = _requireCaller(session, serviceScopes: const [_readScope]);
    if (caller.identityId != null) {
      await _registry.requireIdentityCanReadProject(
        session,
        projectId: projectId,
        identityId: caller.identityId!,
      );
    }
    return caller;
  }

  Future<_ProjectCaller> _requireProjectManagement(
    Session session,
    UuidValue projectId,
  ) async {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    if (caller.identityId != null) {
      await _registry.requireIdentityCanManageProject(
        session,
        projectId: projectId,
        identityId: caller.identityId!,
      );
    }
    return caller;
  }

  Future<_ProjectCaller> _requireParticipantManagement(
    Session session,
    UuidValue participantId,
  ) async {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    if (caller.identityId != null) {
      await _registry.requireIdentityCanManageParticipant(
        session,
        participantId: participantId,
        identityId: caller.identityId!,
      );
    }
    return caller;
  }

  Future<_ProjectCaller> _requireLinkManagement(
    Session session,
    UuidValue linkId,
  ) async {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    if (caller.identityId != null) {
      await _registry.requireIdentityCanManageLink(
        session,
        linkId: linkId,
        identityId: caller.identityId!,
      );
    }
    return caller;
  }
}

class _ProjectCaller {
  _ProjectCaller.user(AuthContext context) : identityId = context.identityId;

  _ProjectCaller.service(ServiceAuthContext _) : identityId = null;

  final UuidValue? identityId;
}
