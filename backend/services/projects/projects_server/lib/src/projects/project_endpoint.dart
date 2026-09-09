import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../generated/protocol.dart';
import 'application/project_registry_service.dart';

class ProjectEndpoint extends Endpoint {
  static const _registry = ProjectRegistryService();
  static const _auth = AuthContextResolver();

  Future<Project> createMyProject(
    Session session, {
    required String slug,
    required String name,
    String? summary,
    ProjectVisibility visibility = ProjectVisibility.private,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
  }) {
    final auth = _auth.requireContext(session);
    return _registry.createProject(
      session,
      slug: slug,
      name: name,
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
    String? summary,
    ProjectVisibility visibility = ProjectVisibility.private,
    UuidValue? ownerIdentityId,
    String? workspacePath,
    List<String>? tags,
    Map<String, String>? metadata,
  }) {
    final auth = _authContextForHttp(session);
    return _registry.createProject(
      session,
      slug: slug,
      name: name,
      summary: summary,
      visibility: visibility,
      ownerIdentityId: auth?.identityId ?? ownerIdentityId,
      workspacePath: workspacePath,
      tags: tags,
      metadata: metadata,
    );
  }

  Future<List<Project>> listProjects(
    Session session, {
    ProjectStatus? status,
    int limit = 50,
    int offset = 0,
  }) {
    _ensureAuthenticatedHttp(session);
    return _registry.listProjects(
      session,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  Future<Project> getProject(Session session, UuidValue projectId) {
    _ensureAuthenticatedHttp(session);
    return _registry.getProject(session, projectId);
  }

  Future<Project> getProjectBySlug(Session session, String slug) {
    _ensureAuthenticatedHttp(session);
    return _registry.getProjectBySlug(session, slug);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    _ensureAuthenticatedHttp(session);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    final actor = _actorIdentityId(session, actorIdentityId);
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
  }) {
    _ensureAuthenticatedHttp(session);
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
  }) {
    _ensureAuthenticatedHttp(session);
    return _registry.listEvents(
      session,
      projectId: projectId,
      limit: limit,
      offset: offset,
    );
  }

  AuthContext? _authContextForHttp(Session session) {
    if (session.request == null) return null;
    return _auth.requireContext(session);
  }

  UuidValue? _actorIdentityId(
    Session session,
    UuidValue? internalActorIdentityId,
  ) {
    return _authContextForHttp(session)?.identityId ?? internalActorIdentityId;
  }

  void _ensureAuthenticatedHttp(Session session) {
    _authContextForHttp(session);
  }
}
