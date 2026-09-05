import 'package:projects_server/src/generated/protocol.dart';
import 'package:projects_server/src/projects/domain/project_registry_policy.dart';
import 'package:test/test.dart';

void main() {
  const policy = ProjectRegistryPolicy();

  test('allows only declared project status transitions', () {
    expect(
      policy.canTransition(ProjectStatus.draft, ProjectStatus.active),
      true,
    );
    expect(
      policy.canTransition(ProjectStatus.active, ProjectStatus.archived),
      true,
    );
    expect(
      policy.canTransition(ProjectStatus.archived, ProjectStatus.active),
      true,
    );
    expect(
      policy.canTransition(ProjectStatus.deleted, ProjectStatus.active),
      false,
    );
  });

  test('maps link kinds to owning services without branching', () {
    expect(policy.defaultServiceFor(ProjectLinkKind.mission), 'missions');
    expect(policy.defaultServiceFor(ProjectLinkKind.lab), 'labs');
    expect(policy.linkKindForService('DATA'), ProjectLinkKind.dataset);
    expect(policy.isSupportedService('documents'), true);
    expect(policy.isSupportedService('unknown'), false);
  });

  test('classifies mutable terminal and archive event states', () {
    expect(policy.isMutable(ProjectStatus.active), true);
    expect(policy.isMutable(ProjectStatus.archived), false);
    expect(policy.isTerminal(ProjectStatus.deleted), true);
    expect(policy.isArchiveEvent(ProjectEventKind.restored), true);
    expect(policy.isArchiveEvent(ProjectEventKind.linked), false);
  });

  test('classifies participant roles and primary-capable roles', () {
    expect(
      policy.isNexusParticipantRole(ProjectParticipantRole.nexusContributor),
      true,
    );
    expect(
      policy.isClientParticipantRole(ProjectParticipantRole.clientReferent),
      true,
    );
    expect(
      policy.canBePrimaryParticipant(ProjectParticipantRole.clientOrganization),
      true,
    );
    expect(
      policy.canBePrimaryParticipant(ProjectParticipantRole.nexusReviewer),
      false,
    );
    expect(
      policy.requiredFieldsFor(ProjectParticipantRole.clientReferent),
      {'displayName'},
    );
  });
}
