import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'application/ai_gateway_application.dart';

class AiGatewayEndpoint extends Endpoint {
  AiGatewayEndpoint({AiGatewayApplication? application})
    : _application = application ?? AiGatewayApplication();

  final AiGatewayApplication _application;

  Future<AiGatewayHealth> health(Session session) async =>
      _application.health();

  Future<List<AiCapability>> capabilities(Session session) {
    return _application.capabilities(session);
  }

  Future<AiRun> createRun(
    Session session, {
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    required String capability,
    Map<String, String>? input,
    UuidValue? missionId,
    String? idempotencyKey,
  }) {
    return _application.createRun(
      session,
      projectId: projectId,
      tenantPartyId: tenantPartyId,
      capability: capability,
      input: input ?? const {},
      missionId: missionId,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<AiRun> getRun(Session session, UuidValue runId) {
    return _application.getRun(session, runId);
  }

  Future<AiRun> cancelRun(Session session, UuidValue runId) {
    return _application.cancelRun(session, runId);
  }
}
