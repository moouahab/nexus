import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../infrastructure/ai_provider_factory.dart';
import '../infrastructure/projects/project_authorization_factory.dart';
import '../infrastructure/reasoning_orchestrator_factory.dart';
import 'ai_run_service.dart';
import 'reasoning_artifact_repository.dart';

/// Single application boundary shared by Serverpod RPC and public HTTP routes.
final class AiGatewayApplication {
  AiGatewayApplication({AiRunService? runs})
    : runs = runs ?? _buildRunService();

  final AiRunService runs;
  static const _userAuth = AuthContextResolver();
  static const _serviceAuth = AuthContextResolver(audience: 'ai-gateway');

  static AiRunService _buildRunService() {
    final provider = AiProviderFactory.fromEnvironment();
    return AiRunService(
      provider: provider,
      authorization: ProjectAuthorizationFactory.fromEnvironment(),
      orchestrator: provider.isConfigured
          ? ReasoningOrchestratorFactory.fromEnvironment(provider)
          : null,
      artifacts: const ServerpodReasoningArtifactStore(),
    );
  }

  AiGatewayHealth health() =>
      AiGatewayHealth(service: 'ai-gateway', status: 'ok');

  Future<List<AiCapability>> capabilities(Session session) async {
    requireCaller(session, 'ai.run.read');
    final available =
        runs.provider.isConfigured && await runs.provider.isAvailable();
    return [
      AiCapability(
        name: 'run.create',
        status: available ? 'available' : 'unavailable',
        reason: available ? null : 'The configured AI provider is unavailable.',
      ),
    ];
  }

  Future<ContextPreview> previewContext(
    Session session, {
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    required List<String> requestedContext,
    required String purpose,
    UuidValue? missionId,
  }) async {
    final caller = requireCaller(session, 'ai.run.read');
    caller.requireProjectAccess(projectId, tenantPartyId: tenantPartyId);
    final grant = await runs.authorization.authorizeProject(
      projectId: projectId,
      tenantPartyId: tenantPartyId,
      identityId: caller.identityId,
      serviceName: caller.serviceName,
      bearerToken: caller.bearerToken,
    );
    final allowed = grant != null;
    return ContextPreview(
      requestId: const Uuid().v7obj(),
      allowed: allowed,
      resolvedSources: allowed ? List.unmodifiable(requestedContext) : const [],
      missingSources: allowed ? const [] : List.unmodifiable(requestedContext),
      warnings: allowed ? const [] : const ['Project access denied.'],
    );
  }

  Future<AiRun> createRun(
    Session session, {
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    required String capability,
    required Map<String, dynamic> input,
    UuidValue? missionId,
    String? idempotencyKey,
  }) {
    final caller = requireCaller(session, 'ai.run.create');
    caller.requireProjectAccess(projectId, tenantPartyId: tenantPartyId);
    return runs.create(
      session,
      projectId: projectId,
      tenantPartyId: tenantPartyId,
      capability: capability,
      input: input,
      missionId: missionId,
      requesterIdentityId: caller.identityId,
      requesterService: caller.serviceName,
      bearerToken: caller.bearerToken,
      idempotencyKey: idempotencyKey,
      serviceContext: caller.serviceContext,
    );
  }

  Future<AiRun> getRun(Session session, UuidValue runId) {
    final caller = requireCaller(session, 'ai.run.read');
    return runs.get(
      session,
      runId,
      requesterIdentityId: caller.identityId,
      requesterService: caller.serviceName,
      bearerToken: caller.bearerToken,
      serviceContext: caller.serviceContext,
    );
  }

  Future<AiRun> cancelRun(Session session, UuidValue runId) {
    final caller = requireCaller(session, 'ai.run.cancel');
    return runs.cancel(
      session,
      runId,
      requesterIdentityId: caller.identityId,
      requesterService: caller.serviceName,
      bearerToken: caller.bearerToken,
      serviceContext: caller.serviceContext,
    );
  }

  AiCaller requireCaller(Session session, String scope) {
    final bearerToken = _bearerToken(session);
    try {
      return AiCaller.user(
        _userAuth.requireContext(session),
        bearerToken: bearerToken,
      );
    } on NexusAuthException catch (error) {
      if (error.code != NexusAuthExceptionCode.invalidAccessToken) rethrow;
      return AiCaller.service(
        _serviceAuth.requireServiceContext(session, requiredScopes: [scope]),
        bearerToken: bearerToken,
      );
    }
  }

  String? _bearerToken(Session session) {
    final request = session.request;
    if (request == null) return null;
    return const BearerAccessTokenReader().read({
      for (final entry in request.headers.entries)
        entry.key.toLowerCase(): entry.value.toList(growable: false),
    });
  }
}

final class AiCaller {
  const AiCaller({
    this.identityId,
    this.serviceName,
    this.bearerToken,
    this.serviceContext,
  });
  factory AiCaller.user(AuthContext context, {required String? bearerToken}) =>
      AiCaller(identityId: context.identityId, bearerToken: bearerToken);
  factory AiCaller.service(
    ServiceAuthContext context, {
    required String? bearerToken,
  }) => AiCaller(
    serviceName: context.serviceName,
    bearerToken: bearerToken,
    serviceContext: context,
  );

  final UuidValue? identityId;
  final String? serviceName;
  final String? bearerToken;
  final ServiceAuthContext? serviceContext;

  void requireProjectAccess(
    UuidValue projectId, {
    required UuidValue tenantPartyId,
  }) {
    final context = serviceContext;
    if (context != null &&
        !context.allowsProject(projectId, tenantId: tenantPartyId)) {
      throw StateError('Service token resource boundary denied.');
    }
  }
}

final class ContextPreview {
  const ContextPreview({
    required this.requestId,
    required this.allowed,
    this.resolvedSources = const [],
    this.missingSources = const [],
    this.warnings = const [],
  });

  final UuidValue requestId;
  final bool allowed;
  final List<String> resolvedSources;
  final List<String> missingSources;
  final List<String> warnings;
}
