import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../../generated/protocol.dart';
import 'ai_provider.dart';
import 'orchestration/orchestration_policy.dart';
import 'orchestration/reasoning_level_selector.dart';
import 'orchestration/reasoning_orchestrator.dart';
import 'ai_run_repository.dart';
import 'ai_run_queue.dart';
import 'project_authorization.dart';
import 'reasoning_artifact_repository.dart';
import '../domain/reasoning_models.dart';

final class AiRunService {
  const AiRunService({
    this.authorization = const UnavailableProjectAuthorization(),
    this.repository = const ServerpodAiRunStore(),
    this.provider = const UnavailableAiProvider(),
    this.orchestrator,
    this.artifacts = const NoopReasoningArtifactStore(),
    this.queue = const ServerpodAiRunQueue(),
  });

  final ProjectAuthorization authorization;
  final AiRunStore repository;
  final AiProvider provider;
  final ReasoningOrchestrator? orchestrator;
  final ReasoningArtifactStore artifacts;
  final AiRunQueue queue;

  Future<AiRun> create(
    Session session, {
    required UuidValue projectId,
    required UuidValue tenantPartyId,
    required String capability,
    required Map<String, dynamic> input,
    UuidValue? missionId,
    UuidValue? requesterIdentityId,
    String? requesterService,
    String? bearerToken,
    String? idempotencyKey,
  }) async {
    final normalizedCapability = capability.trim().toLowerCase();
    if (normalizedCapability.isEmpty || normalizedCapability.length > 80) {
      throw ArgumentError.value(
        capability,
        'capability',
        'Must contain 1 to 80 characters.',
      );
    }
    final authorized = await authorization.canUseProject(
      projectId: projectId,
      tenantPartyId: tenantPartyId,
      identityId: requesterIdentityId,
      serviceName: requesterService,
      bearerToken: bearerToken,
    );
    if (!authorized) {
      throw StateError('Project authorization unavailable or denied.');
    }

    final prompt = input['prompt'];
    if (prompt is! String || prompt.trim().isEmpty || prompt.length > 16000) {
      throw ArgumentError.value(prompt, 'input.prompt');
    }
    if (!provider.isConfigured) {
      throw const AiProviderException('provider_not_configured');
    }
    final normalizedIdempotencyKey = _idempotencyKey(idempotencyKey);
    final requesterScope = requesterIdentityId != null
        ? 'identity:$requesterIdentityId'
        : requesterService != null
        ? 'service:$requesterService'
        : throw StateError('Authenticated requester is required.');
    final requestedLevel = _requestedLevel(input['reasoningLevel']);
    final level = const ReasoningLevelSelector().select(
      ReasoningRequest(
        question: prompt.trim(),
        projectId: projectId,
        tenantPartyId: tenantPartyId,
        bearerToken: bearerToken ?? '',
        requestedLevel: requestedLevel,
      ),
    );
    final policy = OrchestrationPolicy.forLevel(level);
    final queued = await queue.enqueue(
      session,
      run: AiRun(
        requestId: _correlationId(),
        projectId: projectId,
        tenantPartyId: tenantPartyId,
        missionId: missionId,
        capability: normalizedCapability,
        status: AiRunStatus.queued,
        requesterIdentityId: requesterIdentityId,
        requesterService: requesterService,
        provider: provider.name,
        model: provider.model,
        reasoningLevel: level.name,
        currentIteration: 0,
        maxIterations: policy.maxIterations,
        validated: false,
        createdAt: DateTime.now().toUtc(),
      ),
      input: {...input, 'prompt': prompt.trim()},
      requesterScope: requesterScope,
      bearerToken: bearerToken,
      idempotencyKey: normalizedIdempotencyKey,
    );
    return queued;
  }

  UuidValue _correlationId() {
    final requestId = NexusObservability.currentRequestId;
    if (requestId != null) {
      try {
        return UuidValue.withValidation(requestId);
      } on Object {
        // Non-UUID correlation ids remain valid HTTP ids; persistence uses v7.
      }
    }
    return const Uuid().v7obj();
  }

  ReasoningLevel? _requestedLevel(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw ArgumentError.value(value, 'input.reasoningLevel');
    }
    for (final level in ReasoningLevel.values) {
      if (level.name == value) return level;
    }
    throw ArgumentError.value(value, 'input.reasoningLevel');
  }

  String? _idempotencyKey(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > 128) {
      throw ArgumentError.value(value, 'idempotencyKey');
    }
    return normalized;
  }

  Future<AiRun> get(
    Session session,
    UuidValue id, {
    UuidValue? requesterIdentityId,
    String? requesterService,
    String? bearerToken,
  }) async {
    final run = await repository.findById(session, id);
    if (run == null) throw StateError('AI run not found.');
    await _requireCanUseRun(
      run,
      requesterIdentityId: requesterIdentityId,
      requesterService: requesterService,
      bearerToken: bearerToken,
    );
    return run;
  }

  Future<AiRun> cancel(
    Session session,
    UuidValue id, {
    UuidValue? requesterIdentityId,
    String? requesterService,
    String? bearerToken,
  }) async {
    final run = await get(
      session,
      id,
      requesterIdentityId: requesterIdentityId,
      requesterService: requesterService,
      bearerToken: bearerToken,
    );
    if (!_cancellableStatuses.contains(run.status)) {
      throw StateError('AI run cannot be cancelled from ${run.status.name}.');
    }
    await queue.cancel(session, id);
    return repository.update(
      session,
      run.copyWith(
        status: AiRunStatus.cancelled,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static const _cancellableStatuses = {
    AiRunStatus.queued,
    AiRunStatus.running,
    AiRunStatus.planning,
    AiRunStatus.collectingEvidence,
    AiRunStatus.drafting,
    AiRunStatus.verifying,
    AiRunStatus.criticizing,
    AiRunStatus.revising,
    AiRunStatus.validating,
  };

  Future<void> _requireCanUseRun(
    AiRun run, {
    UuidValue? requesterIdentityId,
    String? requesterService,
    String? bearerToken,
  }) async {
    final authorized = await authorization.canUseProject(
      projectId: run.projectId,
      tenantPartyId: run.tenantPartyId,
      identityId: requesterIdentityId,
      serviceName: requesterService,
      bearerToken: bearerToken,
    );
    if (!authorized) {
      throw StateError('Project authorization unavailable or denied.');
    }
  }
}
