part of 'project_registry_service.dart';

abstract class _ProjectLinkService extends _ProjectParticipantService {
  const _ProjectLinkService({super.policy});

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
    final project = await _requiredProject(session, projectId);
    _ensureMutable(project);

    final normalizedService = _normalizeService(service, kind);
    final normalizedExternalId = _requiredText(externalId, 'externalId');
    await _ensureLinkAvailable(
      session,
      projectId: project.id!,
      kind: kind,
      service: normalizedService,
      externalId: normalizedExternalId,
    );

    return session.db.transaction((transaction) async {
      final link = await ProjectLink.db.insertRow(
        session,
        ProjectLink(
          projectId: project.id!,
          kind: kind,
          service: normalizedService,
          externalId: normalizedExternalId,
          label: _optionalText(label),
          uri: _optionalText(uri),
          metadata: _normalizeMetadata(metadata),
        ),
        transaction: transaction,
      );

      await _recordEvent(
        session,
        projectId: project.id!,
        kind: ProjectEventKind.linked,
        actorIdentityId: actorIdentityId,
        resourceKind: link.kind,
        resourceService: link.service,
        resourceExternalId: link.externalId,
        message: link.label,
        transaction: transaction,
      );

      return link;
    });
  }

  Future<ProjectLink> detachLink(
    Session session, {
    required UuidValue linkId,
    UuidValue? actorIdentityId,
  }) async {
    final link = await _requiredLink(session, linkId);
    return session.db.transaction((transaction) async {
      final updated = await ProjectLink.db.updateRow(
        session,
        link.copyWith(
          status: ProjectLinkStatus.detached,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );

      await _recordEvent(
        session,
        projectId: updated.projectId,
        kind: ProjectEventKind.unlinked,
        actorIdentityId: actorIdentityId,
        resourceKind: updated.kind,
        resourceService: updated.service,
        resourceExternalId: updated.externalId,
        message: updated.label,
        transaction: transaction,
      );

      return updated;
    });
  }

  Future<List<ProjectLink>> listLinks(
    Session session, {
    required UuidValue projectId,
    ProjectLinkKind? kind,
    ProjectLinkStatus? status,
  }) async {
    await _requiredProject(session, projectId);
    final filters = _linkFilters(
      projectId: projectId,
      kind: kind,
      status: status,
    );
    return ProjectLink.db.find(
      session,
      where: filters,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }
}
