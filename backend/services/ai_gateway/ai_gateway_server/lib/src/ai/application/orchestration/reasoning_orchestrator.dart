import '../../domain/reasoning_models.dart';
import '../tools/evidence_collector.dart';
import '../verification/evidence_scorer.dart';
import 'orchestration_policy.dart';
import 'reasoning_level_selector.dart';
import 'reasoning_roles.dart';
import 'revision_controller.dart';

final class ReasoningOrchestrator {
  const ReasoningOrchestrator({
    required this.planner,
    required this.drafter,
    required this.critic,
    required this.finalizer,
    required this.evidenceCollector,
    this.levelSelector = const ReasoningLevelSelector(),
    this.scorer = const EvidenceScorer(),
    this.revisionController = const RevisionController(),
  });

  final Planner planner;
  final Drafter drafter;
  final Critic critic;
  final Finalizer finalizer;
  final EvidenceCollector evidenceCollector;
  final ReasoningLevelSelector levelSelector;
  final EvidenceScorer scorer;
  final RevisionController revisionController;

  Future<ReasoningOutcome> execute(
    ReasoningRequest request, {
    Future<void> Function(ReasoningStage stage, int iteration)? onProgress,
  }) async {
    final level = levelSelector.select(request);
    final policy = OrchestrationPolicy.forLevel(level);
    await onProgress?.call(ReasoningStage.planning, 0);
    final plan = await _timed(
      request,
      ReasoningStage.planning,
      () => planner.plan(request),
    );
    await onProgress?.call(ReasoningStage.collectingEvidence, 0);
    final evidence = await _timed(
      request,
      ReasoningStage.collectingEvidence,
      () => evidenceCollector.collect(request, plan, policy),
    );
    var verified = <ClaimVerification>[];
    var iterations = 0;
    var finalCritique = const CritiqueResult(
      decision: CritiqueDecision.needsInformation,
    );

    for (var iteration = 1; iteration <= policy.maxIterations; iteration++) {
      iterations = iteration;
      await onProgress?.call(ReasoningStage.drafting, iteration);
      final claims = await _timed(
        request,
        ReasoningStage.drafting,
        () => drafter.draft(request, plan, evidence, iteration),
      );
      await onProgress?.call(ReasoningStage.verifying, iteration);
      verified = await _timed(request, ReasoningStage.verifying, () async {
        return claims.map((claim) => scorer.score(claim, evidence)).toList();
      });
      if (policy.requireCritic) {
        await onProgress?.call(ReasoningStage.criticizing, iteration);
      }
      final critique = policy.requireCritic
          ? await _timed(
              request,
              ReasoningStage.criticizing,
              () => critic.critique(request, verified, iteration),
            )
          : const CritiqueResult(decision: CritiqueDecision.accept);
      finalCritique = critique;
      if (!revisionController.shouldRevise(
        critique,
        iteration,
        policy.maxIterations,
      )) {
        break;
      }
      await onProgress?.call(ReasoningStage.revising, iteration);
    }

    final criticAccepted =
        finalCritique.decision == CritiqueDecision.accept ||
        finalCritique.decision == CritiqueDecision.needsHumanApproval;
    final accepted = criticAccepted
        ? verified
              .where(
                (claim) => claim.decision == VerificationDecision.supported,
              )
              .toList(growable: false)
        : <ClaimVerification>[];
    final requiresHumanApproval =
        policy.requireHumanApproval ||
        finalCritique.decision == CritiqueDecision.needsHumanApproval;
    await onProgress?.call(ReasoningStage.validating, iterations);
    final answer = accepted.isEmpty
        ? 'Nexus ne peut pas confirmer cette conclusion avec les preuves disponibles.'
        : requiresHumanApproval
        ? 'Les éléments sont vérifiés, mais une validation humaine est requise avant toute action.'
        : await _timed(
            request,
            ReasoningStage.validating,
            () => finalizer.finalize(request, accepted, evidence),
          );
    return ReasoningOutcome(
      answer: answer,
      level: level,
      iterations: iterations,
      claims: verified,
      evidence: evidence,
      validated: accepted.isNotEmpty && !requiresHumanApproval,
      finalDecision: finalCritique.decision,
      requiresHumanApproval: requiresHumanApproval,
    );
  }

  Future<T> _timed<T>(
    ReasoningRequest request,
    ReasoningStage stage,
    Future<T> Function() action,
  ) async {
    final watch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      request.telemetry?.recordStage(stage, watch.elapsed);
    }
  }
}
