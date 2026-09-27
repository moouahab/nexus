part of 'project_registry_service.dart';

abstract class _ProjectCatalogService extends _ProjectRegistrySupport {
  const _ProjectCatalogService({super.policy});

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
    final normalizedSlug = _normalizeSlug(slug);
    final normalizedName = _requiredText(name, 'name');

    return session.db.transaction((transaction) async {
      await _ensureSlugAvailable(
        session,
        normalizedSlug,
        transaction: transaction,
      );

      final project = await Project.db.insertRow(
        session,
        Project(
          slug: normalizedSlug,
          name: normalizedName,
          summary: _optionalText(summary),
          visibility: visibility,
          tenantPartyId: tenantPartyId,
          ownerIdentityId: ownerIdentityId,
          workspacePath: _optionalText(workspacePath),
          tags: _normalizeTags(tags),
          metadata: _normalizeMetadata(metadata),
        ),
        transaction: transaction,
      );

      await _recordEvent(
        session,
        projectId: project.id!,
        kind: ProjectEventKind.created,
        actorIdentityId: ownerIdentityId,
        message: 'Project created',
        transaction: transaction,
      );

      return project;
    });
  }

  Future<List<Project>> listProjects(
    Session session, {
    UuidValue? tenantPartyId,
    ProjectStatus? status,
    int limit = 50,
    int offset = 0,
  }) {
    _validatePagination(limit: limit, offset: offset);
    return Project.db.find(
      session,
      where: tenantPartyId == null && status == null
          ? null
          : (t) {
              Expression<dynamic>? expression;
              if (tenantPartyId != null) {
                expression = t.tenantPartyId.equals(tenantPartyId);
              }
              if (status != null) {
                final statusExpression = t.status.equals(status);
                expression = expression == null
                    ? statusExpression
                    : expression & statusExpression;
              }
              return expression!;
            },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Project>> listProjectsVisibleToIdentity(
    Session session, {
    required UuidValue identityId,
    required UuidValue tenantPartyId,
    ProjectStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    _validatePagination(limit: limit, offset: offset);
    final participantProjectIds = await _activeParticipantProjectIds(
      session,
      identityId,
    );

    return Project.db.find(
      session,
      where: (t) {
        final tenant = t.tenantPartyId.equals(tenantPartyId);
        final ownership = t.ownerIdentityId.equals(identityId);
        final membership = participantProjectIds.isEmpty
            ? ownership
            : ownership | t.id.inSet(participantProjectIds);
        final access = tenant & membership;
        if (status == null) return access;
        return access & t.status.equals(status);
      },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }

  Future<Project> getProject(Session session, UuidValue projectId) async {
    return _requiredProject(session, projectId);
  }

  Future<Project> getProjectBySlug(Session session, String slug) async {
    final normalizedSlug = _normalizeSlug(slug);
    final project = await Project.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(normalizedSlug),
    );
    if (project == null) {
      throw StateError('Project not found.');
    }
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
    final project = await _requiredProject(session, projectId);
    _ensureMutable(project);

    return session.db.transaction((transaction) async {
      final updated = await Project.db.updateRow(
        session,
        project.copyWith(
          name: name == null ? project.name : _requiredText(name, 'name'),
          summary: summary == null ? project.summary : _optionalText(summary),
          visibility: visibility,
          workspacePath: workspacePath == null
              ? project.workspacePath
              : _optionalText(workspacePath),
          tags: tags == null ? project.tags : _normalizeTags(tags),
          metadata: metadata == null
              ? project.metadata
              : _normalizeMetadata(metadata),
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );

      await _recordEvent(
        session,
        projectId: updated.id!,
        kind: ProjectEventKind.updated,
        actorIdentityId: actorIdentityId,
        message: 'Project profile updated',
        transaction: transaction,
      );

      return updated;
    });
  }
}
