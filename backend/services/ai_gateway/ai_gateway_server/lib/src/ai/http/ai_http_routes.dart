import 'package:serverpod/serverpod.dart';

import '../application/ai_gateway_application.dart';
import 'ai_http_dto.dart';
import 'ai_http_json_route.dart';

void registerAiHttpRoutes(Serverpod pod) {
  final application = AiGatewayApplication();
  pod.webServer
    ..addRoute(_HealthRoute(application), '/health')
    ..addRoute(_CapabilitiesRoute(application), '/capabilities')
    ..addRoute(_ContextPreviewRoute(application), '/context/preview')
    ..addRoute(_CreateRunRoute(application), '/runs')
    ..addRoute(_GetRunRoute(application), '/runs/:runId')
    ..addRoute(_CancelRunRoute(application), '/runs/:runId/cancel');
}

final class _HealthRoute extends AiHttpJsonRoute {
  _HealthRoute(AiGatewayApplication application)
    : super(application: application, methods: const {Method.get});

  @override
  bool get requiresAuthentication => false;

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final health = application.health();
    return {'service': health.service, 'status': health.status};
  }
}

final class _CapabilitiesRoute extends AiHttpJsonRoute {
  _CapabilitiesRoute(AiGatewayApplication application)
    : super(application: application, methods: const {Method.get});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final capabilities = await application.capabilities(session);
    return {
      'capabilities': [
        for (final capability in capabilities)
          {
            'name': capability.name,
            'status': capability.status,
            if (capability.reason != null) 'reason': capability.reason,
          },
      ],
    };
  }
}

final class _ContextPreviewRoute extends AiHttpJsonRoute {
  _ContextPreviewRoute(AiGatewayApplication application)
    : super(application: application, methods: const {Method.post});

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final body = await readJsonObject(request);
    final preview = await application.previewContext(
      session,
      projectId: requiredUuid(body, 'projectId'),
      tenantPartyId: requiredUuid(body, 'tenantPartyId'),
      missionId: optionalUuid(body, 'missionId'),
      requestedContext: stringList(body, 'requestedContext', required: true),
      purpose: requiredString(body, 'purpose'),
    );
    return contextPreviewJson(preview);
  }
}

final class _CreateRunRoute extends AiHttpJsonRoute {
  _CreateRunRoute(AiGatewayApplication application)
    : super(application: application, methods: const {Method.post});

  @override
  int get successStatusCode => 202;

  @override
  Future<Map<String, dynamic>> execute(Session session, Request request) async {
    final body = await readJsonObject(request);
    if (body['input'] is! Map<String, dynamic>) {
      throw const FormatException('Field "input" must be a JSON object.');
    }
    stringList(body, 'toolPermissions');
    final run = await application.createRun(
      session,
      projectId: requiredUuid(body, 'projectId'),
      tenantPartyId: requiredUuid(body, 'tenantPartyId'),
      missionId: optionalUuid(body, 'missionId'),
      capability: requiredString(body, 'capability'),
      input: body['input'] as Map<String, dynamic>,
      idempotencyKey: _idempotencyKey(request),
    );
    return aiRunJson(run);
  }

  String? _idempotencyKey(Request request) {
    for (final entry in request.headers.entries) {
      if (entry.key.toLowerCase() == 'idempotency-key') {
        return entry.value.isEmpty ? null : entry.value.first;
      }
    }
    return null;
  }
}

abstract class _RunRoute extends AiHttpJsonRoute {
  _RunRoute(AiGatewayApplication application, {required super.methods})
    : super(application: application);

  UuidValue runId(Request request) {
    final value = request.pathParameters.raw[#runId];
    if (value == null) throw const FormatException('Missing runId.');
    return parseUuid(value, 'runId');
  }
}

final class _GetRunRoute extends _RunRoute {
  _GetRunRoute(super.application) : super(methods: const {Method.get});

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async => aiRunJson(await application.getRun(session, runId(request)));
}

final class _CancelRunRoute extends _RunRoute {
  _CancelRunRoute(super.application) : super(methods: const {Method.post});

  @override
  int get successStatusCode => 202;

  @override
  Future<Map<String, dynamic>> execute(
    Session session,
    Request request,
  ) async => aiRunJson(await application.cancelRun(session, runId(request)));
}
