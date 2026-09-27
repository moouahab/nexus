import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/project_registry_service.dart';
import 'application/tenant_authorization.dart';
import 'infrastructure/tenant_authorization_factory.dart';

class ProjectEndpoint extends Endpoint {
  ProjectEndpoint({
    AuthContextResolver userAuth = const AuthContextResolver(),
    AuthContextResolver serviceAuth = const AuthContextResolver(
      audience: 'projects-service',
    ),
    TenantAuthorization? tenantAuthorization,
  }) : _userAuth = userAuth,
       _serviceAuth = serviceAuth,
       _tenantAuthorization =
           tenantAuthorization ?? TenantAuthorizationFactory.fromEnvironment();

  static const _registry = ProjectRegistryService();
  final AuthContextResolver _userAuth;
  final AuthContextResolver _serviceAuth;
  final TenantAuthorization _tenantAuthorization;
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
  }) async {
    final auth = _requireUserContext(session);
    await _requireTenantManagement(
      session,
      tenantPartyId: tenantPartyId,
    );
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
  }) async {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    if (caller.identityId != null) {
      await _requireTenantManagement(
        session,
        tenantPartyId: tenantPartyId,
      );
    } else if (!caller.serviceContext!.allowsTenant(tenantPartyId)) {
      throw _serviceBoundaryDenied();
    }
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
    if (!caller.serviceContext!.allowsTenant(tenantPartyId)) {
      throw _serviceBoundaryDenied();
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
      await _concealObjectAuthorization(
        () => _registry.requireIdentityCanReadProject(
          session,
          projectId: projectId,
          identityId: caller.identityId!,
        ),
      );
    } else {
      await _requireServiceProjectAccess(session, caller, projectId);
    }
    return caller;
  }

  Future<_ProjectCaller> _requireProjectManagement(
    Session session,
    UuidValue projectId,
  ) async {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    if (caller.identityId != null) {
      await _concealObjectAuthorization(
        () => _registry.requireIdentityCanManageProject(
          session,
          projectId: projectId,
          identityId: caller.identityId!,
        ),
      );
    } else {
      await _requireServiceProjectAccess(session, caller, projectId);
    }
    return caller;
  }

  Future<_ProjectCaller> _requireParticipantManagement(
    Session session,
    UuidValue participantId,
  ) async {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    if (caller.identityId != null) {
      await _concealObjectAuthorization(
        () => _registry.requireIdentityCanManageParticipant(
          session,
          participantId: participantId,
          identityId: caller.identityId!,
        ),
      );
    } else {
      final participant = await ProjectParticipant.db.findById(
        session,
        participantId,
      );
      if (participant == null) {
        throw _serviceBoundaryDenied();
      }
      if (!caller.serviceContext!.allowsResource(participantId)) {
        await _requireServiceProjectAccess(
          session,
          caller,
          participant.projectId,
        );
      }
    }
    return caller;
  }

  Future<_ProjectCaller> _requireLinkManagement(
    Session session,
    UuidValue linkId,
  ) async {
    final caller = _requireCaller(session, serviceScopes: const [_writeScope]);
    if (caller.identityId != null) {
      await _concealObjectAuthorization(
        () => _registry.requireIdentityCanManageLink(
          session,
          linkId: linkId,
          identityId: caller.identityId!,
        ),
      );
    } else {
      final link = await ProjectLink.db.findById(session, linkId);
      if (link == null) {
        throw _serviceBoundaryDenied();
      }
      if (!caller.serviceContext!.allowsResource(linkId)) {
        await _requireServiceProjectAccess(session, caller, link.projectId);
      }
    }
    return caller;
  }

  Future<void> _concealObjectAuthorization(
    Future<void> Function() authorize,
  ) async {
    try {
      await authorize();
    } on NotAuthorizedException {
      throw StateError('Resource not found.');
    }
  }

  Future<void> _requireServiceProjectAccess(
    Session session,
    _ProjectCaller caller,
    UuidValue projectId,
  ) async {
    final context = caller.serviceContext!;
    if (context.globalAccess || context.projectId == projectId.toString()) {
      return;
    }
    if (context.tenantPartyId != null) {
      final project = await _registry.getProject(session, projectId);
      if (context.allowsProject(
        projectId,
        tenantId: project.tenantPartyId,
      )) {
        return;
      }
    }
    throw _serviceBoundaryDenied();
  }

  NotAuthorizedException _serviceBoundaryDenied() => NotAuthorizedException(
    reason: AuthenticationFailureReason.insufficientAccess,
    message: 'Service token resource boundary denied.',
  );

  Future<void> _requireTenantManagement(
    Session session, {
    required UuidValue tenantPartyId,
  }) async {
    final bearerToken = _bearerToken(session);
    final allowed = await _tenantAuthorization.canManageTenant(
      tenantPartyId: tenantPartyId,
      bearerToken: bearerToken,
    );
    if (!allowed) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'Tenant project creation denied.',
      );
    }
  }

  String? _bearerToken(Session session) {
    final request = session.request;
    if (request == null) return null;
    return const BearerAccessTokenReader().read({
      for (final entry in request.headers.entries)
        entry.key.toLowerCase(): entry.value.toList(growable: false),
    });
  }
}

class _ProjectCaller {
  _ProjectCaller.user(AuthContext context)
    : identityId = context.identityId,
      serviceContext = null;

  _ProjectCaller.service(this.serviceContext) : identityId = null;

  final UuidValue? identityId;
  final ServiceAuthContext? serviceContext;
}
