part of 'project_registry_service.dart';

abstract class _ProjectLifecycleService extends _ProjectCatalogService {
  const _ProjectLifecycleService({super.policy});

  Future<Project> changeStatus(
    Session session, {
    required UuidValue projectId,
    required ProjectStatus status,
    UuidValue? actorIdentityId,
    String? reason,
  }) async {
    final project = await _requiredProject(session, projectId);
    _ensureTransition(project.status, status);

    return session.db.transaction((transaction) async {
      final now = DateTime.now().toUtc();
      final updated = await Project.db.updateRow(
        session,
        project.copyWith(
          status: status,
          updatedAt: now,
          archivedAt: status == ProjectStatus.archived
              ? now
              : project.archivedAt,
        ),
        transaction: transaction,
      );

      await _recordEvent(
        session,
        projectId: updated.id!,
        kind: ProjectEventKind.statusChanged,
        actorIdentityId: actorIdentityId,
        message: reason,
        payload: {'from': project.status.name, 'to': status.name},
        transaction: transaction,
      );

      return updated;
    });
  }

  Future<Project> archiveProject(
    Session session, {
    required UuidValue projectId,
    String? archivePath,
    String? reason,
    UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) async {
    final project = await _requiredProject(session, projectId);
    _ensureTransition(project.status, ProjectStatus.archived);

    return session.db.transaction((transaction) async {
      final now = DateTime.now().toUtc();
      final normalizedArchivePath = _optionalText(archivePath);
      final updated = await Project.db.updateRow(
        session,
        project.copyWith(
          status: ProjectStatus.archived,
          archivePath: normalizedArchivePath,
          archivedAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );

      await ProjectArchiveEntry.db.insertRow(
        session,
        ProjectArchiveEntry(
          projectId: updated.id!,
          archivePath: normalizedArchivePath,
          reason: _optionalText(reason),
          archivedByIdentityId: actorIdentityId,
          archivedAt: now,
          metadata: _normalizeMetadata(metadata),
        ),
        transaction: transaction,
      );
      await _recordEvent(
        session,
        projectId: updated.id!,
        kind: ProjectEventKind.archived,
        actorIdentityId: actorIdentityId,
        message: reason,
        payload: {'archivePath': ?normalizedArchivePath},
        transaction: transaction,
      );

      return updated;
    });
  }

  Future<Project> restoreProject(
    Session session, {
    required UuidValue projectId,
    UuidValue? actorIdentityId,
    String? reason,
  }) async {
    final project = await _requiredProject(session, projectId);
    _ensureTransition(project.status, ProjectStatus.active);

    return session.db.transaction((transaction) async {
      final now = DateTime.now().toUtc();
      final updated = await Project.db.updateRow(
        session,
        project.copyWith(
          status: ProjectStatus.active,
          archivePath: null,
          archivedAt: null,
          updatedAt: now,
        ),
        transaction: transaction,
      );

      await _closeLatestArchiveEntry(
        session,
        projectId: updated.id!,
        restoredAt: now,
        restoredByIdentityId: actorIdentityId,
        transaction: transaction,
      );
      await _recordEvent(
        session,
        projectId: updated.id!,
        kind: ProjectEventKind.restored,
        actorIdentityId: actorIdentityId,
        message: reason,
        transaction: transaction,
      );

      return updated;
    });
  }
}
