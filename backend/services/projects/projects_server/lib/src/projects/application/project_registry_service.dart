import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../domain/project_registry_policy.dart';

class ProjectRegistryService {
  const ProjectRegistryService({
    ProjectRegistryPolicy policy = const ProjectRegistryPolicy(),
  }) : _policy = policy;

  final ProjectRegistryPolicy _policy;

  static final _slugPattern = RegExp(r'^[a-z0-9][a-z0-9-]{1,78}[a-z0-9]$');

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
  }) async {
    final normalizedSlug = _normalizeSlug(slug);
    final normalizedName = _requiredText(name, 'name');
    await _ensureSlugAvailable(session, normalizedSlug);

    final project = await Project.db.insertRow(
      session,
      Project(
        slug: normalizedSlug,
        name: normalizedName,
        summary: _optionalText(summary),
        visibility: visibility,
        ownerIdentityId: ownerIdentityId,
        workspacePath: _optionalText(workspacePath),
        tags: _normalizeTags(tags),
        metadata: _normalizeMetadata(metadata),
      ),
    );

    await _recordEvent(
      session,
      projectId: project.id!,
      kind: ProjectEventKind.created,
      actorIdentityId: ownerIdentityId,
      message: 'Project created',
    );

    return project;
  }

  Future<List<Project>> listProjects(
    Session session, {
    ProjectStatus? status,
    int limit = 50,
    int offset = 0,
  }) {
    _validatePagination(limit: limit, offset: offset);
    return Project.db.find(
      session,
      where: status == null ? null : (t) => t.status.equals(status),
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
    );

    await _recordEvent(
      session,
      projectId: updated.id!,
      kind: ProjectEventKind.updated,
      actorIdentityId: actorIdentityId,
      message: 'Project profile updated',
    );

    return updated;
  }

  Future<Project> changeStatus(
    Session session, {
    required UuidValue projectId,
    required ProjectStatus status,
    UuidValue? actorIdentityId,
    String? reason,
  }) async {
    final project = await _requiredProject(session, projectId);
    _ensureTransition(project.status, status);

    final now = DateTime.now().toUtc();
    final updated = await Project.db.updateRow(
      session,
      project.copyWith(
        status: status,
        updatedAt: now,
        archivedAt: status == ProjectStatus.archived ? now : project.archivedAt,
      ),
    );

    await _recordEvent(
      session,
      projectId: updated.id!,
      kind: ProjectEventKind.statusChanged,
      actorIdentityId: actorIdentityId,
      message: reason,
      payload: {'from': project.status.name, 'to': status.name},
    );

    return updated;
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
    );
    await _recordEvent(
      session,
      projectId: updated.id!,
      kind: ProjectEventKind.archived,
      actorIdentityId: actorIdentityId,
      message: reason,
      payload: {'archivePath': ?normalizedArchivePath},
    );

    return updated;
  }

  Future<Project> restoreProject(
    Session session, {
    required UuidValue projectId,
    UuidValue? actorIdentityId,
    String? reason,
  }) async {
    final project = await _requiredProject(session, projectId);
    _ensureTransition(project.status, ProjectStatus.active);

    final now = DateTime.now().toUtc();
    final updated = await Project.db.updateRow(
      session,
      project.copyWith(
        status: ProjectStatus.active,
        archivePath: null,
        archivedAt: null,
        updatedAt: now,
      ),
    );

    await _closeLatestArchiveEntry(
      session,
      projectId: updated.id!,
      restoredAt: now,
      restoredByIdentityId: actorIdentityId,
    );
    await _recordEvent(
      session,
      projectId: updated.id!,
      kind: ProjectEventKind.restored,
      actorIdentityId: actorIdentityId,
      message: reason,
    );

    return updated;
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
    if (!_policy.isNexusParticipantRole(role)) {
      throw ArgumentError.value(role, 'role', 'Expected a Nexus project role.');
    }
    return addParticipant(
      session,
      projectId: projectId,
      role: role,
      identityId: identityId,
      displayName: displayName,
      email: email,
      isPrimary: isPrimary,
      actorIdentityId: actorIdentityId,
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
    return addParticipant(
      session,
      projectId: projectId,
      role: ProjectParticipantRole.clientOrganization,
      externalId: externalId,
      displayName: displayName,
      organizationName: organizationName,
      email: email,
      phone: phone,
      notes: notes,
      isPrimary: true,
      actorIdentityId: actorIdentityId,
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
    return addParticipant(
      session,
      projectId: projectId,
      role: ProjectParticipantRole.clientReferent,
      externalId: externalId,
      displayName: displayName,
      organizationName: organizationName,
      email: email,
      phone: phone,
      notes: notes,
      isPrimary: true,
      actorIdentityId: actorIdentityId,
      metadata: metadata,
    );
  }

  Future<ProjectParticipant> addParticipant(
    Session session, {
    required UuidValue projectId,
    required ProjectParticipantRole role,
    UuidValue? identityId,
    String? externalId,
    String? displayName,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    bool isPrimary = false,
    UuidValue? actorIdentityId,
    Map<String, String>? metadata,
  }) async {
    final project = await _requiredProject(session, projectId);
    _ensureMutable(project);
    _validateParticipant(
      role: role,
      identityId: identityId,
      displayName: displayName,
      organizationName: organizationName,
    );

    if (isPrimary) {
      _ensureCanBePrimary(role);
      await _clearPrimaryParticipants(
        session,
        projectId: project.id!,
        role: role,
      );
    }

    final participant = await ProjectParticipant.db.insertRow(
      session,
      ProjectParticipant(
        projectId: project.id!,
        role: role,
        identityId: identityId,
        externalId: _optionalText(externalId),
        displayName: _optionalText(displayName),
        organizationName: _optionalText(organizationName),
        email: _normalizeEmail(email),
        phone: _optionalText(phone),
        notes: _optionalText(notes),
        isPrimary: isPrimary,
        metadata: _normalizeMetadata(metadata),
      ),
    );

    await _recordEvent(
      session,
      projectId: project.id!,
      kind: ProjectEventKind.participantAdded,
      actorIdentityId: actorIdentityId,
      message: participant.displayName ?? participant.organizationName,
      payload: {'role': participant.role.name},
    );

    return participant;
  }

  Future<List<ProjectParticipant>> listParticipants(
    Session session, {
    required UuidValue projectId,
    ProjectParticipantRole? role,
    ProjectParticipantStatus? status,
  }) async {
    await _requiredProject(session, projectId);
    return ProjectParticipant.db.find(
      session,
      where: _participantFilters(
        projectId: projectId,
        role: role,
        status: status,
      ),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<ProjectParticipant> removeParticipant(
    Session session, {
    required UuidValue participantId,
    UuidValue? actorIdentityId,
  }) async {
    final participant = await _requiredParticipant(session, participantId);
    final updated = await ProjectParticipant.db.updateRow(
      session,
      participant.copyWith(
        status: ProjectParticipantStatus.removed,
        isPrimary: false,
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    await _recordEvent(
      session,
      projectId: updated.projectId,
      kind: ProjectEventKind.participantRemoved,
      actorIdentityId: actorIdentityId,
      message: updated.displayName ?? updated.organizationName,
      payload: {'role': updated.role.name},
    );

    return updated;
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
    );

    return link;
  }

  Future<ProjectLink> detachLink(
    Session session, {
    required UuidValue linkId,
    UuidValue? actorIdentityId,
  }) async {
    final link = await _requiredLink(session, linkId);
    final updated = await ProjectLink.db.updateRow(
      session,
      link.copyWith(
        status: ProjectLinkStatus.detached,
        updatedAt: DateTime.now().toUtc(),
      ),
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
    );

    return updated;
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

  Future<Project> _requiredProject(Session session, UuidValue projectId) async {
    final project = await Project.db.findById(session, projectId);
    if (project == null) throw StateError('Project not found.');
    return project;
  }

  Future<ProjectLink> _requiredLink(Session session, UuidValue linkId) async {
    final link = await ProjectLink.db.findById(session, linkId);
    if (link == null) throw StateError('Project link not found.');
    return link;
  }

  Future<ProjectParticipant> _requiredParticipant(
    Session session,
    UuidValue participantId,
  ) async {
    final participant = await ProjectParticipant.db.findById(
      session,
      participantId,
    );
    if (participant == null) throw StateError('Project participant not found.');
    return participant;
  }

  Future<void> _ensureSlugAvailable(Session session, String slug) async {
    final existing = await Project.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
    if (existing != null) throw StateError('Project slug already exists.');
  }

  Future<void> _ensureLinkAvailable(
    Session session, {
    required UuidValue projectId,
    required ProjectLinkKind kind,
    required String service,
    required String externalId,
  }) async {
    final existing = await ProjectLink.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.kind.equals(kind) &
          t.service.equals(service) &
          t.externalId.equals(externalId),
    );
    if (existing != null) throw StateError('Project link already exists.');
  }

  void _ensureMutable(Project project) {
    if (!_policy.isMutable(project.status)) {
      throw StateError('Project is not mutable.');
    }
  }

  void _ensureTransition(ProjectStatus from, ProjectStatus to) {
    if (!_policy.canTransition(from, to)) {
      throw StateError('Project status transition is not allowed.');
    }
  }

  void _ensureCanBePrimary(ProjectParticipantRole role) {
    if (!_policy.canBePrimaryParticipant(role)) {
      throw ArgumentError.value(role, 'role', 'Role cannot be primary.');
    }
  }

  void _validateParticipant({
    required ProjectParticipantRole role,
    UuidValue? identityId,
    String? displayName,
    String? organizationName,
  }) {
    final values = <String, bool>{
      'identityOrName':
          identityId != null || _optionalText(displayName) != null,
      'organizationOrName':
          _optionalText(organizationName) != null ||
          _optionalText(displayName) != null,
      'displayName': _optionalText(displayName) != null,
    };
    for (final field in _policy.requiredFieldsFor(role)) {
      if (values[field] != true) {
        throw ArgumentError.value(role, 'role', 'Missing participant $field.');
      }
    }
  }

  Future<void> _clearPrimaryParticipants(
    Session session, {
    required UuidValue projectId,
    required ProjectParticipantRole role,
  }) async {
    await ProjectParticipant.db.updateWhere(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.role.equals(role) &
          t.status.equals(ProjectParticipantStatus.active),
      columnValues: (t) => [
        t.isPrimary(false),
        t.updatedAt(DateTime.now().toUtc()),
      ],
    );
  }

  Future<void> _recordEvent(
    Session session, {
    required UuidValue projectId,
    required ProjectEventKind kind,
    UuidValue? actorIdentityId,
    ProjectLinkKind? resourceKind,
    String? resourceService,
    String? resourceExternalId,
    String? message,
    Map<String, String>? payload,
  }) async {
    await ProjectEvent.db.insertRow(
      session,
      ProjectEvent(
        projectId: projectId,
        kind: kind,
        actorIdentityId: actorIdentityId,
        resourceKind: resourceKind,
        resourceService: resourceService,
        resourceExternalId: resourceExternalId,
        message: _optionalText(message),
        payload: _normalizeMetadata(payload),
      ),
    );
  }

  Future<void> _closeLatestArchiveEntry(
    Session session, {
    required UuidValue projectId,
    required DateTime restoredAt,
    UuidValue? restoredByIdentityId,
  }) async {
    final entries = await ProjectArchiveEntry.db.find(
      session,
      where: (t) => t.projectId.equals(projectId) & t.restoredAt.equals(null),
      orderBy: (t) => t.archivedAt,
      orderDescending: true,
      limit: 1,
    );
    if (entries.isEmpty) return;

    await ProjectArchiveEntry.db.updateRow(
      session,
      entries.first.copyWith(
        restoredAt: restoredAt,
        restoredByIdentityId: restoredByIdentityId,
      ),
    );
  }

  String _normalizeSlug(String value) {
    final normalized = value.trim().toLowerCase();
    if (!_slugPattern.hasMatch(normalized)) {
      throw ArgumentError.value(value, 'slug', 'Invalid project slug.');
    }
    return normalized;
  }

  String _requiredText(String value, String field) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, field, 'Value is required.');
    }
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _normalizeEmail(String? value) {
    return _optionalText(value)?.toLowerCase();
  }

  String _normalizeService(String? service, ProjectLinkKind kind) {
    final normalized = _optionalText(service)?.toLowerCase();
    if (normalized == null) return _policy.defaultServiceFor(kind);
    if (!_policy.isSupportedService(normalized)) {
      throw ArgumentError.value(service, 'service', 'Unsupported service.');
    }
    final expectedKind = _policy.linkKindForService(normalized);
    if (expectedKind != kind) {
      throw ArgumentError.value(
        service,
        'service',
        'Service does not match kind.',
      );
    }
    return normalized;
  }

  List<String>? _normalizeTags(List<String>? tags) {
    final normalized =
        tags
            ?.map((tag) => tag.trim().toLowerCase())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList()
          ?..sort();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Map<String, String>? _normalizeMetadata(Map<String, String>? metadata) {
    final normalized = metadata?.map(
      (key, value) => MapEntry(key.trim(), value.trim()),
    );
    normalized?.removeWhere((key, value) => key.isEmpty || value.isEmpty);
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  void _validatePagination({
    required int limit,
    required int offset,
    int maxLimit = 100,
  }) {
    if (limit < 1 || limit > maxLimit) {
      throw ArgumentError.value(limit, 'limit', 'Invalid page size.');
    }
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'Invalid offset.');
    }
  }

  WhereExpressionBuilder<ProjectLinkTable> _linkFilters({
    required UuidValue projectId,
    ProjectLinkKind? kind,
    ProjectLinkStatus? status,
  }) {
    return (t) {
      var expression = t.projectId.equals(projectId);
      if (kind != null) expression = expression & t.kind.equals(kind);
      if (status != null) expression = expression & t.status.equals(status);
      return expression;
    };
  }

  WhereExpressionBuilder<ProjectParticipantTable> _participantFilters({
    required UuidValue projectId,
    ProjectParticipantRole? role,
    ProjectParticipantStatus? status,
  }) {
    return (t) {
      var expression = t.projectId.equals(projectId);
      if (role != null) expression = expression & t.role.equals(role);
      if (status != null) expression = expression & t.status.equals(status);
      return expression;
    };
  }
}
