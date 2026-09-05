import '../../generated/protocol.dart';

class ProjectRegistryPolicy {
  const ProjectRegistryPolicy();

  static const mutableStatuses = <ProjectStatus>{
    ProjectStatus.draft,
    ProjectStatus.active,
    ProjectStatus.paused,
  };

  static const terminalStatuses = <ProjectStatus>{
    ProjectStatus.archived,
    ProjectStatus.deleted,
  };

  static const statusTransitions = <ProjectStatus, Set<ProjectStatus>>{
    ProjectStatus.draft: {
      ProjectStatus.active,
      ProjectStatus.archived,
      ProjectStatus.deleted,
    },
    ProjectStatus.active: {
      ProjectStatus.paused,
      ProjectStatus.archived,
      ProjectStatus.deleted,
    },
    ProjectStatus.paused: {
      ProjectStatus.active,
      ProjectStatus.archived,
      ProjectStatus.deleted,
    },
    ProjectStatus.archived: {
      ProjectStatus.active,
      ProjectStatus.deleted,
    },
    ProjectStatus.deleted: {},
  };

  static const defaultServiceByLinkKind = <ProjectLinkKind, String>{
    ProjectLinkKind.mission: 'missions',
    ProjectLinkKind.lab: 'labs',
    ProjectLinkKind.dataset: 'data',
    ProjectLinkKind.document: 'documents',
    ProjectLinkKind.history: 'history',
    ProjectLinkKind.externalResource: 'external',
  };

  static const linkKindByService = <String, ProjectLinkKind>{
    'missions': ProjectLinkKind.mission,
    'labs': ProjectLinkKind.lab,
    'data': ProjectLinkKind.dataset,
    'documents': ProjectLinkKind.document,
    'history': ProjectLinkKind.history,
    'external': ProjectLinkKind.externalResource,
  };

  static const archiveEventKinds = <ProjectEventKind>{
    ProjectEventKind.archived,
    ProjectEventKind.restored,
  };

  static const nexusParticipantRoles = <ProjectParticipantRole>{
    ProjectParticipantRole.nexusOwner,
    ProjectParticipantRole.nexusManager,
    ProjectParticipantRole.nexusContributor,
    ProjectParticipantRole.nexusReviewer,
  };

  static const clientParticipantRoles = <ProjectParticipantRole>{
    ProjectParticipantRole.clientOrganization,
    ProjectParticipantRole.clientReferent,
  };

  static const primaryParticipantRoles = <ProjectParticipantRole>{
    ProjectParticipantRole.nexusOwner,
    ProjectParticipantRole.clientOrganization,
    ProjectParticipantRole.clientReferent,
  };

  static const participantRequiredFields =
      <ProjectParticipantRole, Set<String>>{
        ProjectParticipantRole.nexusOwner: {'identityOrName'},
        ProjectParticipantRole.nexusManager: {'identityOrName'},
        ProjectParticipantRole.nexusContributor: {'identityOrName'},
        ProjectParticipantRole.nexusReviewer: {'identityOrName'},
        ProjectParticipantRole.clientOrganization: {'organizationOrName'},
        ProjectParticipantRole.clientReferent: {'displayName'},
      };

  bool isMutable(ProjectStatus status) => mutableStatuses.contains(status);

  bool isTerminal(ProjectStatus status) => terminalStatuses.contains(status);

  bool canTransition(ProjectStatus from, ProjectStatus to) {
    return statusTransitions[from]?.contains(to) ?? false;
  }

  String defaultServiceFor(ProjectLinkKind kind) {
    return defaultServiceByLinkKind[kind]!;
  }

  ProjectLinkKind? linkKindForService(String service) {
    return linkKindByService[service.trim().toLowerCase()];
  }

  bool isSupportedService(String service) {
    return linkKindForService(service) != null;
  }

  bool isArchiveEvent(ProjectEventKind kind) =>
      archiveEventKinds.contains(kind);

  bool isNexusParticipantRole(ProjectParticipantRole role) {
    return nexusParticipantRoles.contains(role);
  }

  bool isClientParticipantRole(ProjectParticipantRole role) {
    return clientParticipantRoles.contains(role);
  }

  bool canBePrimaryParticipant(ProjectParticipantRole role) {
    return primaryParticipantRoles.contains(role);
  }

  Set<String> requiredFieldsFor(ProjectParticipantRole role) {
    return participantRequiredFields[role] ?? const {};
  }
}
