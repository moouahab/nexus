import 'package:projects_server/src/generated/protocol.dart';
import 'package:projects_server/src/projects/application/project_registry_service.dart';
import 'package:projects_server/src/projects/application/tenant_authorization.dart';
import 'package:projects_server/src/projects/project_endpoint.dart';
import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Project registry', (sessionBuilder, _) {
    const registry = ProjectRegistryService();
    final tenantA = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000001',
    );
    final tenantB = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000002',
    );
    final ownerIdentityId = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000101',
    );
    final managerIdentityId = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000102',
    );
    final contributorIdentityId = UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000103',
    );

    test('creates, reads and lists projects', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final project = await registry.createProject(
        session,
        slug: 'nexus-core',
        name: 'Nexus Core',
        tenantPartyId: tenantA,
        summary: 'Central backend registry',
        visibility: ProjectVisibility.internal,
        tags: ['Backend', ' nexus ', 'backend'],
        metadata: {' stack ': ' serverpod ', 'empty': ' '},
      );

      expect(project.id, isNotNull);
      expect(project.slug, 'nexus-core');
      expect(project.tenantPartyId, tenantA);
      expect(project.status, ProjectStatus.active);
      expect(project.visibility, ProjectVisibility.internal);
      expect(project.tags, ['backend', 'nexus']);
      expect(project.metadata, {'stack': 'serverpod'});

      final byId = await registry.getProject(
        session,
        project.id!,
      );
      final bySlug = await registry.getProjectBySlug(
        session,
        ' NEXUS-CORE ',
      );
      final listed = await registry.listProjects(
        session,
        tenantPartyId: tenantA,
        limit: 10,
        offset: 0,
      );

      expect(byId.id, project.id);
      expect(bySlug.id, project.id);
      expect(listed.map((item) => item.id), contains(project.id));
    });

    test('rejects endpoint calls without request auth context', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);

      expect(
        () => ProjectEndpoint().listProjects(
          session,
          tenantPartyId: tenantA,
        ),
        throwsA(
          isA<NotAuthorizedException>()
              .having(
                (error) => error.reason,
                'reason',
                AuthenticationFailureReason.insufficientAccess,
              )
              .having(
                (error) => error.message,
                'safe message',
                'Authentication failed.',
              ),
        ),
      );
    });

    test('lists projects only inside the requested tenant', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final first = await registry.createProject(
        session,
        slug: 'tenant-a-project',
        name: 'Tenant A Project',
        tenantPartyId: tenantA,
        visibility: ProjectVisibility.private,
      );
      final second = await registry.createProject(
        session,
        slug: 'tenant-b-project',
        name: 'Tenant B Project',
        tenantPartyId: tenantB,
        visibility: ProjectVisibility.private,
      );

      final tenantAProjects = await registry.listProjects(
        session,
        tenantPartyId: tenantA,
        limit: 10,
        offset: 0,
      );

      expect(tenantAProjects.map((project) => project.id), contains(first.id));
      expect(
        tenantAProjects.map((project) => project.id),
        isNot(contains(second.id)),
      );
    });

    test('enforces owner manager and tenant visibility rules', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final project = await registry.createProject(
        session,
        slug: 'rbac-tenant-a',
        name: 'RBAC Tenant A',
        tenantPartyId: tenantA,
        ownerIdentityId: ownerIdentityId,
      );
      await registry.assignProjectMember(
        session,
        projectId: project.id!,
        role: ProjectParticipantRole.nexusManager,
        identityId: managerIdentityId,
      );
      await registry.assignProjectMember(
        session,
        projectId: project.id!,
        role: ProjectParticipantRole.nexusContributor,
        identityId: contributorIdentityId,
      );

      await registry.requireIdentityCanReadProject(
        session,
        projectId: project.id!,
        identityId: ownerIdentityId,
      );
      await registry.requireIdentityCanManageProject(
        session,
        projectId: project.id!,
        identityId: ownerIdentityId,
      );
      await registry.requireIdentityCanManageProject(
        session,
        projectId: project.id!,
        identityId: managerIdentityId,
      );
      await registry.requireIdentityCanReadProject(
        session,
        projectId: project.id!,
        identityId: contributorIdentityId,
      );

      expect(
        () => registry.requireIdentityCanManageProject(
          session,
          projectId: project.id!,
          identityId: contributorIdentityId,
        ),
        throwsA(
          isA<NotAuthorizedException>().having(
            (error) => error.reason,
            'reason',
            AuthenticationFailureReason.insufficientAccess,
          ),
        ),
      );

      final visibleInTenantA = await registry.listProjectsVisibleToIdentity(
        session,
        identityId: managerIdentityId,
        tenantPartyId: tenantA,
      );
      final visibleInTenantB = await registry.listProjectsVisibleToIdentity(
        session,
        identityId: managerIdentityId,
        tenantPartyId: tenantB,
      );

      expect(visibleInTenantA.map((item) => item.id), contains(project.id));
      expect(
        visibleInTenantB.map((item) => item.id),
        isNot(contains(project.id)),
      );
    });

    test('denies creating a project under another tenantPartyId', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final endpoint = ProjectEndpoint(
        userAuth: _TestAuthContextResolver.user(ownerIdentityId),
        tenantAuthorization: _TenantAuthorization(tenantA),
      );
      final created = await endpoint.createMyProject(
        session,
        slug: 'authorized-tenant-a-project',
        name: 'Authorized Tenant A Project',
        tenantPartyId: tenantA,
      );
      expect(created.tenantPartyId, tenantA);
      await expectLater(
        endpoint.createMyProject(
          session,
          slug: 'forged-tenant-b-project',
          name: 'Forged Tenant B Project',
          tenantPartyId: tenantB,
        ),
        throwsA(isA<NotAuthorizedException>()),
      );
      expect(
        await Project.db.findFirstRow(
          session,
          where: (table) => table.slug.equals('forged-tenant-b-project'),
        ),
        isNull,
      );
    });

    test('denies horizontal access to projects and child resources', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final tenantAOwner = ownerIdentityId;
      final tenantBManager = managerIdentityId;
      final projectA = await registry.createProject(
        session,
        slug: 'horizontal-tenant-a',
        name: 'Horizontal Tenant A',
        tenantPartyId: tenantA,
        ownerIdentityId: tenantAOwner,
      );
      final projectB = await registry.createProject(
        session,
        slug: 'horizontal-tenant-b',
        name: 'Horizontal Tenant B',
        tenantPartyId: tenantB,
      );
      await registry.assignProjectMember(
        session,
        projectId: projectB.id!,
        role: ProjectParticipantRole.nexusManager,
        identityId: tenantBManager,
      );
      final participantB = await registry.assignProjectMember(
        session,
        projectId: projectB.id!,
        role: ProjectParticipantRole.nexusContributor,
        displayName: 'Tenant B Contributor',
      );
      final linkB = await registry.linkResource(
        session,
        projectId: projectB.id!,
        kind: ProjectLinkKind.document,
        externalId: 'tenant-b-document',
      );

      for (final authorization in <Future<void> Function()>[
        () => registry.requireIdentityCanReadProject(
          session,
          projectId: projectB.id!,
          identityId: tenantAOwner,
        ),
        () => registry.requireIdentityCanManageProject(
          session,
          projectId: projectB.id!,
          identityId: tenantAOwner,
        ),
        () => registry.requireIdentityCanManageParticipant(
          session,
          participantId: participantB.id!,
          identityId: tenantAOwner,
        ),
        () => registry.requireIdentityCanManageLink(
          session,
          linkId: linkB.id!,
          identityId: tenantAOwner,
        ),
      ]) {
        await expectLater(
          authorization(),
          throwsA(
            isA<NotAuthorizedException>().having(
              (error) => error.reason,
              'reason',
              AuthenticationFailureReason.insufficientAccess,
            ),
          ),
        );
      }

      final endpoint = ProjectEndpoint(
        userAuth: _TestAuthContextResolver.user(tenantAOwner),
      );
      for (final operation in <Future<Object?> Function()>[
        () => endpoint.getProject(session, projectB.id!),
        () => endpoint.getProjectBySlug(session, projectB.slug),
        () => endpoint.canUseAiForProject(
          session,
          projectId: projectB.id!,
          tenantPartyId: tenantB,
        ),
        () => endpoint.updateProjectProfile(
          session,
          projectId: projectB.id!,
          name: 'Cross-tenant update',
        ),
        () => endpoint.changeProjectStatus(
          session,
          projectId: projectB.id!,
          status: ProjectStatus.paused,
        ),
        () => endpoint.archiveProject(session, projectId: projectB.id!),
        () => endpoint.restoreProject(session, projectId: projectB.id!),
        () => endpoint.listParticipants(session, projectId: projectB.id!),
        () => endpoint.assignProjectMember(
          session,
          projectId: projectB.id!,
          role: ProjectParticipantRole.nexusContributor,
          identityId: tenantAOwner,
        ),
        () => endpoint.removeParticipant(
          session,
          participantId: participantB.id!,
        ),
        () => endpoint.listLinks(session, projectId: projectB.id!),
        () => endpoint.linkResource(
          session,
          projectId: projectB.id!,
          kind: ProjectLinkKind.document,
          externalId: 'cross-tenant-document',
        ),
        () => endpoint.detachLink(session, linkId: linkB.id!),
        () => endpoint.listEvents(session, projectId: projectB.id!),
      ]) {
        await expectLater(
          operation(),
          throwsA(_concealedResourceNotFound),
        );
      }

      final tenantAVisible = await registry.listProjectsVisibleToIdentity(
        session,
        identityId: tenantAOwner,
        tenantPartyId: tenantA,
      );
      final tenantBVisible = await registry.listProjectsVisibleToIdentity(
        session,
        identityId: tenantAOwner,
        tenantPartyId: tenantB,
      );
      expect(tenantAVisible.map((item) => item.id), contains(projectA.id));
      expect(
        tenantBVisible.map((item) => item.id),
        isNot(contains(projectB.id)),
      );
    });

    test(
      'unauthenticated callers cannot read or mutate existing resources',
      () async {
        final session = sessionBuilder.build();
        addTearDown(session.close);
        final project = await registry.createProject(
          session,
          slug: 'endpoint-auth-matrix',
          name: 'Endpoint Auth Matrix',
          tenantPartyId: tenantA,
        );
        final participant = await registry.assignProjectMember(
          session,
          projectId: project.id!,
          role: ProjectParticipantRole.nexusContributor,
          displayName: 'Contributor',
        );
        final link = await registry.linkResource(
          session,
          projectId: project.id!,
          kind: ProjectLinkKind.document,
          externalId: 'auth-matrix-document',
        );
        final endpoint = ProjectEndpoint();

        for (final call in <Future<Object> Function()>[
          () => endpoint.getProject(session, project.id!),
          () => endpoint.canUseAiForProject(
            session,
            projectId: project.id!,
            tenantPartyId: tenantA,
          ),
          () => endpoint.listParticipants(session, projectId: project.id!),
          () => endpoint.listLinks(session, projectId: project.id!),
          () => endpoint.listEvents(session, projectId: project.id!),
          () => endpoint.updateProjectProfile(
            session,
            projectId: project.id!,
            name: 'Forbidden Update',
          ),
          () => endpoint.archiveProject(session, projectId: project.id!),
          () => endpoint.assignProjectMember(
            session,
            projectId: project.id!,
            role: ProjectParticipantRole.nexusManager,
            identityId: managerIdentityId,
          ),
          () => endpoint.removeParticipant(
            session,
            participantId: participant.id!,
          ),
          () => endpoint.detachLink(session, linkId: link.id!),
        ]) {
          await expectLater(
            call(),
            throwsA(isA<NotAuthorizedException>()),
          );
        }

        expect(
          (await registry.getProject(session, project.id!)).name,
          'Endpoint Auth Matrix',
        );
        expect(
          (await registry.listParticipants(
            session,
            projectId: project.id!,
          )).singleWhere((item) => item.id == participant.id).status,
          ProjectParticipantStatus.active,
        );
        expect(
          (await registry.listLinks(
            session,
            projectId: project.id!,
          )).single.status,
          ProjectLinkStatus.active,
        );
      },
    );

    test('enforces projects.read and projects.write service scopes', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);
      final project = await registry.createProject(
        session,
        slug: 'service-scope-matrix',
        name: 'Service Scope Matrix',
        tenantPartyId: tenantB,
      );
      final rejectingUser = _TestAuthContextResolver.rejectUser();
      final readEndpoint = ProjectEndpoint(
        userAuth: rejectingUser,
        serviceAuth: _TestAuthContextResolver.service({'projects.read'}),
      );
      final writeEndpoint = ProjectEndpoint(
        userAuth: rejectingUser,
        serviceAuth: _TestAuthContextResolver.service({'projects.write'}),
      );

      expect(
        (await readEndpoint.getProject(session, project.id!)).id,
        project.id,
      );
      await expectLater(
        readEndpoint.updateProjectProfile(
          session,
          projectId: project.id!,
          name: 'Forbidden service write',
        ),
        throwsA(isA<NotAuthorizedException>()),
      );
      expect(
        (await registry.getProject(session, project.id!)).name,
        'Service Scope Matrix',
      );

      expect(
        (await writeEndpoint.updateProjectProfile(
          session,
          projectId: project.id!,
          name: 'Authorized service write',
        )).name,
        'Authorized service write',
      );
      await expectLater(
        writeEndpoint.getProject(session, project.id!),
        throwsA(isA<NotAuthorizedException>()),
      );

      final wrongProjectEndpoint = ProjectEndpoint(
        userAuth: rejectingUser,
        serviceAuth: _TestAuthContextResolver.service(
          {'projects.read'},
          projectId: tenantA.toString(),
        ),
      );
      await expectLater(
        wrongProjectEndpoint.getProject(session, project.id!),
        throwsA(isA<NotAuthorizedException>()),
      );
    });

    test('updates profile and writes timeline event', () async {
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final project = await registry.createProject(
        session,
        slug: 'profile-update',
        name: 'Profile Update',
        tenantPartyId: tenantA,
        visibility: ProjectVisibility.private,
      );

      final updated = await registry.updateProjectProfile(
        session,
        projectId: project.id!,
        name: 'Updated Profile',
        summary: 'Updated summary',
        visibility: ProjectVisibility.shared,
        workspacePath: '/workspace/nexus/profile',
        tags: ['ops'],
      );
      final events = await registry.listEvents(
        session,
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
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final project = await registry.createProject(
        session,
        slug: 'link-flow',
        name: 'Link Flow',
        tenantPartyId: tenantA,
        visibility: ProjectVisibility.private,
      );

      final link = await registry.linkResource(
        session,
        projectId: project.id!,
        kind: ProjectLinkKind.lab,
        externalId: 'lab-001',
        label: 'First Lab',
      );
      final activeLinks = await registry.listLinks(
        session,
        projectId: project.id!,
        kind: ProjectLinkKind.lab,
        status: ProjectLinkStatus.active,
      );
      final detached = await registry.detachLink(
        session,
        linkId: link.id!,
      );
      final events = await registry.listEvents(
        session,
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
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final project = await registry.createProject(
        session,
        slug: 'participants-flow',
        name: 'Participants Flow',
        tenantPartyId: tenantA,
        visibility: ProjectVisibility.private,
      );

      final member = await registry.assignProjectMember(
        session,
        projectId: project.id!,
        role: ProjectParticipantRole.nexusContributor,
        displayName: 'Nexus Builder',
        email: 'BUILDER@NEXUS.LOCAL',
        isPrimary: false,
      );
      final client = await registry.setProjectClient(
        session,
        projectId: project.id!,
        organizationName: 'Acme Corp',
        externalId: 'crm-acme',
      );
      final referent = await registry.setClientReferent(
        session,
        projectId: project.id!,
        displayName: 'Alice Client',
        organizationName: 'Acme Corp',
        email: 'ALICE@ACME.TEST',
        phone: '+33000000000',
      );

      final participants = await registry.listParticipants(
        session,
        projectId: project.id!,
        status: ProjectParticipantStatus.active,
      );
      final clientReferents = await registry.listParticipants(
        session,
        projectId: project.id!,
        role: ProjectParticipantRole.clientReferent,
        status: ProjectParticipantStatus.active,
      );
      final removed = await registry.removeParticipant(
        session,
        participantId: member.id!,
      );
      final events = await registry.listEvents(
        session,
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
      final session = sessionBuilder.build();
      addTearDown(session.close);

      final project = await registry.createProject(
        session,
        slug: 'archive-flow',
        name: 'Archive Flow',
        tenantPartyId: tenantA,
        visibility: ProjectVisibility.private,
      );

      final archived = await registry.archiveProject(
        session,
        projectId: project.id!,
        archivePath: '/archive/nexus/archive-flow',
        reason: 'Done',
      );
      final restored = await registry.restoreProject(
        session,
        projectId: project.id!,
        reason: 'Needed again',
      );
      final events = await registry.listEvents(
        session,
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

class _TestAuthContextResolver extends AuthContextResolver {
  _TestAuthContextResolver.user(this.identityId)
    : serviceScopes = null,
      projectId = null;

  _TestAuthContextResolver.rejectUser()
    : identityId = null,
      serviceScopes = null,
      projectId = null;

  _TestAuthContextResolver.service(
    Set<String> scopes, {
    this.projectId,
  }) : identityId = null,
       serviceScopes = scopes;

  final UuidValue? identityId;
  final Set<String>? serviceScopes;
  final String? projectId;

  @override
  AuthContext requireContext(Session session) {
    final authenticatedIdentity = identityId;
    if (authenticatedIdentity == null) {
      throw const NexusAuthException.invalidAccessToken('Not a user token.');
    }
    return AuthContext(
      identityId: authenticatedIdentity,
      authSessionId: UuidValue.withValidation(
        '018f0000-0000-7000-8000-000000000901',
      ),
      issuer: AuthTokenDefaults.issuer,
      audience: AuthTokenDefaults.audience,
      emailVerified: true,
      authenticationMethods: const ['pwd'],
      issuedAt: DateTime.utc(2026),
      expiresAt: DateTime.utc(2099),
    );
  }

  @override
  ServiceAuthContext requireServiceContext(
    Session session, {
    Iterable<String> requiredScopes = const [],
  }) {
    final tokenScopes = serviceScopes;
    if (tokenScopes == null ||
        requiredScopes.any((scope) => !tokenScopes.contains(scope))) {
      throw const NexusAuthException.invalidAccessToken(
        'Service token scope denied.',
      );
    }
    return ServiceAuthContext(
      serviceName: 'security-test',
      issuer: AuthTokenDefaults.issuer,
      audiences: const ['projects-service'],
      scopes: tokenScopes.toList(growable: false),
      issuedAt: DateTime.utc(2026),
      expiresAt: DateTime.utc(2099),
      globalAccess: projectId == null,
      projectId: projectId,
    );
  }
}

final _concealedResourceNotFound = isA<StateError>().having(
  (error) => error.message,
  'message',
  'Resource not found.',
);

final class _TenantAuthorization implements TenantAuthorization {
  const _TenantAuthorization(this.allowedTenant);
  final UuidValue allowedTenant;

  @override
  Future<bool> canManageTenant({
    required UuidValue tenantPartyId,
    required String? bearerToken,
  }) async => tenantPartyId == allowedTenant;
}
