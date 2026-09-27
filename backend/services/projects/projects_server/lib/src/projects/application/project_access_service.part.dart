part of 'project_registry_service.dart';

abstract class _ProjectAccessService extends _ProjectLinkService {
  const _ProjectAccessService({super.policy});

  Future<List<ProjectEvent>> listEvents(
    Session session, {
    required UuidValue projectId,
    int limit = 100,
    int offset = 0,
  }) async {
    await _requiredProject(session, projectId);
    _validatePagination(limit: limit, offset: offset, maxLimit: 200);
    return ProjectEvent.db.find(
      session,
      where: (t) => t.projectId.equals(projectId),
      orderBy: (t) => t.occurredAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }

  Future<void> requireIdentityCanReadProject(
    Session session, {
    required UuidValue projectId,
    required UuidValue identityId,
  }) async {
    final project = await _requiredProject(session, projectId);
    if (project.ownerIdentityId == identityId) return;

    final participant = await _activeParticipantForIdentity(
      session,
      projectId: project.id!,
      identityId: identityId,
    );
    if (participant != null) return;

    throw NotAuthorizedException(
      reason: AuthenticationFailureReason.insufficientAccess,
      message: 'Project access denied.',
    );
  }

  Future<void> requireIdentityCanManageProject(
    Session session, {
    required UuidValue projectId,
    required UuidValue identityId,
  }) async {
    final project = await _requiredProject(session, projectId);
    if (project.ownerIdentityId == identityId) return;

    final participant = await _activeParticipantForIdentity(
      session,
      projectId: project.id!,
      identityId: identityId,
    );
    if (participant != null && _policy.canManageProject(participant.role)) {
      return;
    }

    throw NotAuthorizedException(
      reason: AuthenticationFailureReason.insufficientAccess,
      message: 'Project management access denied.',
    );
  }

  Future<void> requireIdentityCanManageParticipant(
    Session session, {
    required UuidValue participantId,
    required UuidValue identityId,
  }) async {
    final participant = await _requiredParticipant(session, participantId);
    await requireIdentityCanManageProject(
      session,
      projectId: participant.projectId,
      identityId: identityId,
    );
  }

  Future<void> requireIdentityCanManageLink(
    Session session, {
    required UuidValue linkId,
    required UuidValue identityId,
  }) async {
    final link = await _requiredLink(session, linkId);
    await requireIdentityCanManageProject(
      session,
      projectId: link.projectId,
      identityId: identityId,
    );
  }
}
