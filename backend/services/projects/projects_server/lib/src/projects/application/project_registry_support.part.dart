part of 'project_registry_service.dart';

abstract class _ProjectRegistrySupport {
  const _ProjectRegistrySupport({
    ProjectRegistryPolicy policy = const ProjectRegistryPolicy(),
  }) : _policy = policy;

  final ProjectRegistryPolicy _policy;

  static final _slugPattern = RegExp(r'^[a-z0-9][a-z0-9-]{1,78}[a-z0-9]$');

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

  Future<Set<UuidValue?>> _activeParticipantProjectIds(
    Session session,
    UuidValue identityId,
  ) async {
    final participants = await ProjectParticipant.db.find(
      session,
      where: (t) =>
          t.identityId.equals(identityId) &
          t.status.equals(ProjectParticipantStatus.active),
    );
    return participants.map((participant) => participant.projectId).toSet();
  }

  Future<ProjectParticipant?> _activeParticipantForIdentity(
    Session session, {
    required UuidValue projectId,
    required UuidValue identityId,
  }) {
    return ProjectParticipant.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.identityId.equals(identityId) &
          t.status.equals(ProjectParticipantStatus.active),
    );
  }

  Future<void> _ensureSlugAvailable(
    Session session,
    String slug, {
    Transaction? transaction,
  }) async {
    final existing = await Project.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
      transaction: transaction,
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
    Transaction? transaction,
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
      transaction: transaction,
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
    Transaction? transaction,
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
      transaction: transaction,
    );
  }

  Future<void> _closeLatestArchiveEntry(
    Session session, {
    required UuidValue projectId,
    required DateTime restoredAt,
    UuidValue? restoredByIdentityId,
    Transaction? transaction,
  }) async {
    final entries = await ProjectArchiveEntry.db.find(
      session,
      where: (t) => t.projectId.equals(projectId) & t.restoredAt.equals(null),
      orderBy: (t) => t.archivedAt,
      orderDescending: true,
      limit: 1,
      transaction: transaction,
    );
    if (entries.isEmpty) return;

    await ProjectArchiveEntry.db.updateRow(
      session,
      entries.first.copyWith(
        restoredAt: restoredAt,
        restoredByIdentityId: restoredByIdentityId,
      ),
      transaction: transaction,
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
