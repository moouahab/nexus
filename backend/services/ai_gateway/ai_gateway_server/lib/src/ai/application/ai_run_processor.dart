import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:nexus_auth/nexus_auth.dart';

import '../../generated/protocol.dart';
import '../domain/reasoning_models.dart';
import 'ai_provider.dart';
import 'ai_run_queue.dart';
import 'ai_run_repository.dart';
import 'orchestration/orchestration_policy.dart';
import 'orchestration/reasoning_level_selector.dart';
import 'orchestration/reasoning_orchestrator.dart';
import 'reasoning_artifact_repository.dart';
import 'project_service_token.dart';

final class AiRunProcessor {
  const AiRunProcessor({
    required this.provider,
    this.orchestrator,
    this.jobs = const AiRunClaimStore(),
    this.runs = const ServerpodAiRunStore(),
    this.artifacts = const ServerpodReasoningArtifactStore(),
    this.projectTokens = const UnavailableProjectServiceTokenIssuer(),
  });

  final AiProvider provider;
  final ReasoningOrchestrator? orchestrator;
  final AiRunClaimStore jobs;
  final AiRunStore runs;
  final ReasoningArtifactStore artifacts;
  final ProjectServiceTokenIssuer projectTokens;

  Future<void> process(Session session, UuidValue runId) async {
    final claimed = await jobs.claim(session, runId);
    if (claimed == null) return;
    final run = claimed.run;
    final job = claimed.job;
    return NexusObservability.runWithRequestId(
      run.requestId.toString(),
      () => _processClaimed(session, run, job),
    );
  }

  Future<void> _processClaimed(Session session, AiRun run, AiRunJob job) async {
    final watch = Stopwatch()..start();
    final queueWaitMs = DateTime.now()
        .toUtc()
        .difference(job.createdAt)
        .inMilliseconds;
    try {
      final input = jsonDecode(job.inputJson) as Map<String, dynamic>;
      final prompt = input['prompt'] as String;
      final authorizationGrant = input['_projectAuthorizationGrant'];
      final reasoning = orchestrator;
      final projectsToken = reasoning == null
          ? ''
          : await projectTokens.issueReadToken(
              session,
              tenantPartyId: run.tenantPartyId,
              projectId: run.projectId,
              authorizationGrant: authorizationGrant is String
                  ? authorizationGrant
                  : '',
              delegatedIdentityId: run.requesterIdentityId,
            );
      final request = ReasoningRequest(
        question: prompt,
        projectId: run.projectId,
        tenantPartyId: run.tenantPartyId,
        // Never propagate the inbound ai-gateway bearer to Projects. This
        // token has the projects-service audience and an exact project bound.
        bearerToken: projectsToken,
        requestedLevel: _requestedLevel(input['reasoningLevel']),
      );
      final level = const ReasoningLevelSelector().select(request);
      final policy = OrchestrationPolicy.forLevel(level);
      if (reasoning != null) {
        final outcome = await reasoning.execute(
          request,
          onProgress: (stage, iteration) async {
            await _throwIfCancelled(session, run.id!);
            await runs.update(
              session,
              run.copyWith(
                status: _statusForStage(stage),
                currentIteration: iteration,
                updatedAt: DateTime.now().toUtc(),
              ),
            );
          },
        );
        await _throwIfCancelled(session, run.id!);
        await artifacts.save(session, run.id!, outcome);
        await runs.update(
          session,
          run.copyWith(
            status: _statusFor(outcome),
            outputText: outcome.answer,
            reasoningLevel: outcome.level.name,
            currentIteration: outcome.iterations,
            maxIterations: policy.maxIterations,
            validated: outcome.validated,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      } else {
        final generated = await provider.generate(
          AiGenerationRequest(capability: run.capability, prompt: prompt),
        );
        await _throwIfCancelled(session, run.id!);
        await runs.update(
          session,
          run.copyWith(
            status: AiRunStatus.completed,
            provider: generated.provider,
            model: generated.model,
            outputText: generated.output,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
      await jobs.finish(session, job, status: AiRunJobStatus.completed);
      NexusObservability.log(
        session,
        service: 'ai-gateway',
        event: 'ai_run_processed',
        fields: {
          'outcome': 'completed',
          'duration_ms': watch.elapsedMilliseconds,
          'queue_wait_ms': queueWaitMs,
          'reasoning_level': run.reasoningLevel,
        },
      );
    } on _AiRunCancelled {
      await jobs.finish(session, job, status: AiRunJobStatus.cancelled);
      NexusObservability.log(
        session,
        service: 'ai-gateway',
        event: 'ai_run_processed',
        fields: {
          'outcome': 'cancelled',
          'duration_ms': watch.elapsedMilliseconds,
          'queue_wait_ms': queueWaitMs,
        },
      );
    } on Object {
      await runs.update(
        session,
        run.copyWith(
          status: AiRunStatus.failed,
          failureCode: 'provider_request_failed',
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      await jobs.finish(
        session,
        job,
        status: AiRunJobStatus.failed,
        errorCode: 'provider_request_failed',
      );
      NexusObservability.log(
        session,
        service: 'ai-gateway',
        event: 'ai_run_processed',
        level: LogLevel.error,
        fields: {
          'outcome': 'failed',
          'duration_ms': watch.elapsedMilliseconds,
          'queue_wait_ms': queueWaitMs,
        },
      );
      rethrow;
    }
  }

  Future<void> _throwIfCancelled(Session session, UuidValue runId) async {
    final current = await runs.findById(session, runId);
    if (current?.status == AiRunStatus.cancelled) throw const _AiRunCancelled();
  }

  AiRunStatus _statusFor(ReasoningOutcome outcome) {
    if (outcome.requiresHumanApproval) return AiRunStatus.needsHumanApproval;
    if (outcome.validated) return AiRunStatus.completed;
    if (outcome.finalDecision == CritiqueDecision.reject) {
      return AiRunStatus.rejected;
    }
    return AiRunStatus.needsInformation;
  }

  AiRunStatus _statusForStage(ReasoningStage stage) => switch (stage) {
    ReasoningStage.planning => AiRunStatus.planning,
    ReasoningStage.collectingEvidence => AiRunStatus.collectingEvidence,
    ReasoningStage.drafting => AiRunStatus.drafting,
    ReasoningStage.verifying => AiRunStatus.verifying,
    ReasoningStage.criticizing => AiRunStatus.criticizing,
    ReasoningStage.revising => AiRunStatus.revising,
    ReasoningStage.validating => AiRunStatus.validating,
  };

  ReasoningLevel? _requestedLevel(Object? value) {
    if (value == null) return null;
    for (final level in ReasoningLevel.values) {
      if (level.name == value) return level;
    }
    return null;
  }
}

final class _AiRunCancelled implements Exception {
  const _AiRunCancelled();
}
