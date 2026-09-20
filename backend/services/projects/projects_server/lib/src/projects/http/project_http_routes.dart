import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'project_http_dto.dart';
import 'project_http_json_route.dart';

void registerProjectHttpRoutes(Serverpod pod) {
  pod.webServer
    ..addRoute(_CreateProjectRoute(), '/projects')
    ..addRoute(_ListProjectsRoute(), '/tenants/:tenantId/projects')
    ..addRoute(
      _ProjectRoute(methods: const {Method.get, Method.patch}),
      '/projects/:projectId',
    )
    ..addRoute(_ProjectStatusRoute(), '/projects/:projectId/status')
    ..addRoute(_ProjectAiAccessRoute(), '/projects/:projectId/ai-access')
    ..addRoute(_ProjectArchiveRoute(), '/projects/:projectId/archive')
    ..addRoute(_ProjectRestoreRoute(), '/projects/:projectId/restore')
    ..addRoute(
      _ParticipantsRoute(methods: const {Method.get, Method.post}),
      '/projects/:projectId/participants',
    )
    ..addRoute(
      _LinksRoute(methods: const {Method.get, Method.post}),
      '/projects/:projectId/links',
    )
    ..addRoute(_EventsRoute(), '/projects/:projectId/events');
}

final class _ProjectAiAccessRoute extends ProjectHttpJsonRoute {
  _ProjectAiAccessRoute() : super(methods: const {Method.get});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final tenant = request.url.queryParameters['tenantPartyId'];
    if (tenant == null) {
      throw const FormatException('Query "tenantPartyId" is required.');
    }
    final allowed = await projects.canUseAiForProject(
      session,
      projectId: pathUuid(request, #projectId),
      tenantPartyId: parseUuid(tenant, 'tenantPartyId'),
    );
    return {'allowed': allowed};
  }
}

final class _CreateProjectRoute extends ProjectHttpJsonRoute {
  _CreateProjectRoute() : super(methods: const {Method.post});
  @override
  int get successStatusCode => 201;
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final body = await readJsonObject(request);
    final visibility = body['visibility'] == null
        ? ProjectVisibility.private
        : enumValue(ProjectVisibility.values, body['visibility'], 'visibility');
    final project = await projects.createProject(
      session,
      slug: requiredString(body, 'slug'),
      name: requiredString(body, 'name'),
      tenantPartyId: requiredUuid(body, 'tenantPartyId'),
      summary: optionalString(body, 'summary'),
      visibility: visibility,
      tags: optionalStringList(body, 'tags'),
      metadata: optionalStringMap(body, 'metadata'),
    );
    return projectJson(project);
  }
}

final class _ListProjectsRoute extends ProjectHttpJsonRoute {
  _ListProjectsRoute() : super(methods: const {Method.get});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final tenantId = pathUuid(request, #tenantId);
    final values = await projects.listProjects(
      session,
      tenantPartyId: tenantId,
    );
    return {'items': values.map(projectJson).toList(), 'count': values.length};
  }
}

final class _ProjectRoute extends ProjectHttpJsonRoute {
  _ProjectRoute({required super.methods});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final id = pathUuid(request, #projectId);
    if (request.method == Method.get) {
      return projectJson(await projects.getProject(session, id));
    }
    final body = await readJsonObject(request);
    final visibility = body['visibility'] == null
        ? null
        : enumValue(ProjectVisibility.values, body['visibility'], 'visibility');
    return projectJson(
      await projects.updateProjectProfile(
        session,
        projectId: id,
        name: optionalString(body, 'name'),
        summary: optionalString(body, 'summary'),
        visibility: visibility,
        tags: optionalStringList(body, 'tags'),
        metadata: optionalStringMap(body, 'metadata'),
      ),
    );
  }
}

final class _ProjectStatusRoute extends ProjectHttpJsonRoute {
  _ProjectStatusRoute() : super(methods: const {Method.post});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final body = await readJsonObject(request);
    return projectJson(
      await projects.changeProjectStatus(
        session,
        projectId: pathUuid(request, #projectId),
        status: enumValue(ProjectStatus.values, body['status'], 'status'),
        reason: optionalString(body, 'reason'),
      ),
    );
  }
}

final class _ProjectArchiveRoute extends ProjectHttpJsonRoute {
  _ProjectArchiveRoute() : super(methods: const {Method.post});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final body = await readJsonObject(request);
    return projectJson(
      await projects.archiveProject(
        session,
        projectId: pathUuid(request, #projectId),
        reason: optionalString(body, 'reason'),
        metadata: optionalStringMap(body, 'metadata'),
      ),
    );
  }
}

final class _ProjectRestoreRoute extends ProjectHttpJsonRoute {
  _ProjectRestoreRoute() : super(methods: const {Method.post});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final body = await readJsonObject(request);
    return projectJson(
      await projects.restoreProject(
        session,
        projectId: pathUuid(request, #projectId),
        reason: optionalString(body, 'reason'),
      ),
    );
  }
}

final class _ParticipantsRoute extends ProjectHttpJsonRoute {
  _ParticipantsRoute({required super.methods});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final projectId = pathUuid(request, #projectId);
    if (request.method == Method.get) {
      final values = await projects.listParticipants(
        session,
        projectId: projectId,
      );
      return {
        'items': values.map(participantJson).toList(),
        'count': values.length,
      };
    }
    final body = await readJsonObject(request);
    final value = await projects.assignProjectMember(
      session,
      projectId: projectId,
      role: enumValue(ProjectParticipantRole.values, body['role'], 'role'),
      identityId: requiredUuid(body, 'identityId'),
      displayName: optionalString(body, 'displayName'),
      isPrimary: body['isPrimary'] == true,
      metadata: optionalStringMap(body, 'metadata'),
    );
    return participantJson(value);
  }
}

final class _LinksRoute extends ProjectHttpJsonRoute {
  _LinksRoute({required super.methods});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final projectId = pathUuid(request, #projectId);
    if (request.method == Method.get) {
      final values = await projects.listLinks(session, projectId: projectId);
      return {'items': values.map(linkJson).toList(), 'count': values.length};
    }
    final body = await readJsonObject(request);
    return linkJson(
      await projects.linkResource(
        session,
        projectId: projectId,
        kind: enumValue(ProjectLinkKind.values, body['kind'], 'kind'),
        externalId: requiredString(body, 'externalId'),
        service: optionalString(body, 'service'),
        label: optionalString(body, 'label'),
        uri: optionalString(body, 'uri'),
        metadata: optionalStringMap(body, 'metadata'),
      ),
    );
  }
}

final class _EventsRoute extends ProjectHttpJsonRoute {
  _EventsRoute() : super(methods: const {Method.get});
  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final values = await projects.listEvents(
      session,
      projectId: pathUuid(request, #projectId),
    );
    return {'items': values.map(eventJson).toList(), 'count': values.length};
  }
}
