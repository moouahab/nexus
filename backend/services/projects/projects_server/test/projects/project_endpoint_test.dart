import 'package:projects_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Project endpoint', (sessionBuilder, endpoints) {
    test('creates, reads and lists projects', () async {
      final project = await endpoints.project.createProject(
        sessionBuilder,
        slug: 'nexus-core',
        name: 'Nexus Core',
        summary: 'Central backend registry',
        visibility: ProjectVisibility.internal,
        tags: ['Backend', ' nexus ', 'backend'],
        metadata: {' stack ': ' serverpod ', 'empty': ' '},
      );

      expect(project.id, isNotNull);
      expect(project.slug, 'nexus-core');
      expect(project.status, ProjectStatus.active);
      expect(project.visibility, ProjectVisibility.internal);
      expect(project.tags, ['backend', 'nexus']);
      expect(project.metadata, {'stack': 'serverpod'});

      final byId = await endpoints.project.getProject(
        sessionBuilder,
        project.id!,
      );
      final bySlug = await endpoints.project.getProjectBySlug(
        sessionBuilder,
        ' NEXUS-CORE ',
      );
      final listed = await endpoints.project.listProjects(
        sessionBuilder,
        limit: 10,
        offset: 0,
      );

      expect(byId.id, project.id);
      expect(bySlug.id, project.id);
      expect(listed.map((item) => item.id), contains(project.id));
    });

    test('updates profile and writes timeline event', () async {
      final project = await endpoints.project.createProject(
        sessionBuilder,
        slug: 'profile-update',
        name: 'Profile Update',
        visibility: ProjectVisibility.private,
      );

      final updated = await endpoints.project.updateProjectProfile(
        sessionBuilder,
        projectId: project.id!,
        name: 'Updated Profile',
        summary: 'Updated summary',
        visibility: ProjectVisibility.shared,
        workspacePath: '/workspace/nexus/profile',
        tags: ['ops'],
      );
      final events = await endpoints.project.listEvents(
        sessionBuilder,
        projectId: project.id!,
        limit: 20,
        offset: 0,
      );

      expect(updated.name, 'Updated Profile');
      expect(updated.summary, 'Updated summary');
      expect(updated.visibility, ProjectVisibility.shared);
      expect(updated.workspacePath, '/workspace/nexus/profile');
      expect(updated.updatedAt, isNotNull);
      expect(
        events.map((event) => event.kind),
        contains(ProjectEventKind.updated),
      );
    });

    test('links and detaches external resources', () async {
      final project = await endpoints.project.createProject(
        sessionBuilder,
        slug: 'link-flow',
        name: 'Link Flow',
        visibility: ProjectVisibility.private,
      );

      final link = await endpoints.project.linkResource(
        sessionBuilder,
        projectId: project.id!,
        kind: ProjectLinkKind.lab,
        externalId: 'lab-001',
        label: 'First Lab',
      );
      final activeLinks = await endpoints.project.listLinks(
        sessionBuilder,
        projectId: project.id!,
        kind: ProjectLinkKind.lab,
        status: ProjectLinkStatus.active,
      );
      final detached = await endpoints.project.detachLink(
        sessionBuilder,
        linkId: link.id!,
      );
      final events = await endpoints.project.listEvents(
        sessionBuilder,
        projectId: project.id!,
        limit: 20,
        offset: 0,
      );

      expect(link.service, 'labs');
      expect(activeLinks.map((item) => item.id), contains(link.id));
      expect(detached.status, ProjectLinkStatus.detached);
      expect(
        events.map((event) => event.kind),
        contains(ProjectEventKind.linked),
      );
      expect(
        events.map((event) => event.kind),
        contains(ProjectEventKind.unlinked),
      );
    });

    test('tracks project member client and client referent', () async {
      final project = await endpoints.project.createProject(
        sessionBuilder,
        slug: 'participants-flow',
        name: 'Participants Flow',
        visibility: ProjectVisibility.private,
      );

      final member = await endpoints.project.assignProjectMember(
        sessionBuilder,
        projectId: project.id!,
        role: ProjectParticipantRole.nexusContributor,
        displayName: 'Nexus Builder',
        email: 'BUILDER@NEXUS.LOCAL',
        isPrimary: false,
      );
      final client = await endpoints.project.setProjectClient(
        sessionBuilder,
        projectId: project.id!,
        organizationName: 'Acme Corp',
        externalId: 'crm-acme',
      );
      final referent = await endpoints.project.setClientReferent(
        sessionBuilder,
        projectId: project.id!,
        displayName: 'Alice Client',
        organizationName: 'Acme Corp',
        email: 'ALICE@ACME.TEST',
        phone: '+33000000000',
      );

      final participants = await endpoints.project.listParticipants(
        sessionBuilder,
        projectId: project.id!,
        status: ProjectParticipantStatus.active,
      );
      final clientReferents = await endpoints.project.listParticipants(
        sessionBuilder,
        projectId: project.id!,
        role: ProjectParticipantRole.clientReferent,
        status: ProjectParticipantStatus.active,
      );
      final removed = await endpoints.project.removeParticipant(
        sessionBuilder,
        participantId: member.id!,
      );
      final events = await endpoints.project.listEvents(
        sessionBuilder,
        projectId: project.id!,
        limit: 30,
        offset: 0,
      );

      expect(member.role, ProjectParticipantRole.nexusContributor);
      expect(member.email, 'builder@nexus.local');
      expect(client.role, ProjectParticipantRole.clientOrganization);
      expect(client.isPrimary, true);
      expect(referent.role, ProjectParticipantRole.clientReferent);
      expect(referent.email, 'alice@acme.test');
      expect(clientReferents.single.id, referent.id);
      expect(
        participants.map((item) => item.id),
        containsAll([
          member.id,
          client.id,
          referent.id,
        ]),
      );
      expect(removed.status, ProjectParticipantStatus.removed);
      expect(removed.isPrimary, false);
      expect(
        events.map((event) => event.kind),
        containsAll([
          ProjectEventKind.participantAdded,
          ProjectEventKind.participantRemoved,
        ]),
      );
    });

    test('archives and restores projects', () async {
      final project = await endpoints.project.createProject(
        sessionBuilder,
        slug: 'archive-flow',
        name: 'Archive Flow',
        visibility: ProjectVisibility.private,
      );

      final archived = await endpoints.project.archiveProject(
        sessionBuilder,
        projectId: project.id!,
        archivePath: '/archive/nexus/archive-flow',
        reason: 'Done',
      );
      final restored = await endpoints.project.restoreProject(
        sessionBuilder,
        projectId: project.id!,
        reason: 'Needed again',
      );
      final events = await endpoints.project.listEvents(
        sessionBuilder,
        projectId: project.id!,
        limit: 20,
        offset: 0,
      );

      expect(archived.status, ProjectStatus.archived);
      expect(archived.archivePath, '/archive/nexus/archive-flow');
      expect(archived.archivedAt, isNotNull);
      expect(restored.status, ProjectStatus.active);
      expect(restored.archivePath, isNull);
      expect(restored.archivedAt, isNull);
      expect(
        events.map((event) => event.kind),
        containsAll([ProjectEventKind.archived, ProjectEventKind.restored]),
      );
    });
  });
}
