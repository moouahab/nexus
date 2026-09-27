part of 'project_registry_service.dart';

abstract class _ProjectParticipantService extends _ProjectLifecycleService {
  const _ProjectParticipantService({super.policy});

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

    return session.db.transaction((transaction) async {
      if (isPrimary) {
        _ensureCanBePrimary(role);
        await _clearPrimaryParticipants(
          session,
          projectId: project.id!,
          role: role,
          transaction: transaction,
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
        transaction: transaction,
      );

      await _recordEvent(
        session,
        projectId: project.id!,
        kind: ProjectEventKind.participantAdded,
        actorIdentityId: actorIdentityId,
        message: participant.displayName ?? participant.organizationName,
        payload: {'role': participant.role.name},
        transaction: transaction,
      );

      return participant;
    });
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
    return session.db.transaction((transaction) async {
      final updated = await ProjectParticipant.db.updateRow(
        session,
        participant.copyWith(
          status: ProjectParticipantStatus.removed,
          isPrimary: false,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );

      await _recordEvent(
        session,
        projectId: updated.projectId,
        kind: ProjectEventKind.participantRemoved,
        actorIdentityId: actorIdentityId,
        message: updated.displayName ?? updated.organizationName,
        payload: {'role': updated.role.name},
        transaction: transaction,
      );

      return updated;
    });
  }
}
