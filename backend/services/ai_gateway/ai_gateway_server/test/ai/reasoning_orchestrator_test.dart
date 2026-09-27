import 'package:ai_gateway_server/src/ai/application/orchestration/reasoning_orchestrator.dart';
import 'package:ai_gateway_server/src/ai/application/orchestration/reasoning_roles.dart';
import 'package:ai_gateway_server/src/ai/application/tools/evidence_collector.dart';
import 'package:ai_gateway_server/src/ai/application/tools/nexus_tool.dart';
import 'package:ai_gateway_server/src/ai/domain/reasoning_models.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  final request = ReasoningRequest(
    question: 'Pourquoi le projet risque d’être en retard ?',
    projectId: UuidValue.withValidation('018f0000-0000-7000-8000-000000000001'),
    tenantPartyId: UuidValue.withValidation(
      '018f0000-0000-7000-8000-000000000002',
    ),
    bearerToken: 'test-token',
  );

  test('no evidence never becomes a certain answer', () async {
    final finalizer = _Finalizer();
    final outcome = await _orchestrator(
      evidence: const [],
      critic: const _StaticCritic(CritiqueDecision.accept),
      finalizer: finalizer,
    ).execute(request);

    expect(outcome.validated, isFalse);
    expect(
      outcome.claims.single.decision,
      VerificationDecision.insufficientEvidence,
    );
    expect(outcome.answer, contains('ne peut pas confirmer'));
    expect(finalizer.calls, 0);
  });

  test('deep reasoning revises once then stops at its bounded limit', () async {
    final critic = _RevisionCritic();
    final outcome = await _orchestrator(
      evidence: [_evidence()],
      critic: critic,
      finalizer: _Finalizer(),
    ).execute(request);

    expect(outcome.level, ReasoningLevel.deep);
    expect(outcome.iterations, 2);
    expect(critic.calls, 2);
    expect(outcome.validated, isFalse);
    expect(outcome.answer, contains('ne peut pas confirmer'));
  });

  test('high-risk conclusions require human approval', () async {
    final outcome =
        await _orchestrator(
          evidence: [_evidence()],
          critic: const _StaticCritic(CritiqueDecision.accept),
          finalizer: _Finalizer(),
        ).execute(
          ReasoningRequest(
            question:
                'Cette action cyber peut-elle être exécutée en production ?',
            projectId: request.projectId,
            tenantPartyId: request.tenantPartyId,
            bearerToken: request.bearerToken,
          ),
        );

    expect(outcome.level, ReasoningLevel.highRisk);
    expect(outcome.requiresHumanApproval, isTrue);
    expect(outcome.validated, isFalse);
    expect(outcome.answer, contains('validation humaine'));
  });
}

ReasoningOrchestrator _orchestrator({
  required List<EvidenceItem> evidence,
  required Critic critic,
  required _Finalizer finalizer,
}) => ReasoningOrchestrator(
  planner: const _Planner(),
  drafter: const _Drafter(),
  critic: critic,
  finalizer: finalizer,
  evidenceCollector: EvidenceCollector(ToolRegistry([_Tool(evidence)])),
);

EvidenceItem _evidence() => EvidenceItem(
  id: 'projects:project:P-1',
  sourceService: 'projects',
  resourceType: 'project',
  resourceId: 'P-1',
  summary: 'The delivery status is delayed.',
  collectedAt: DateTime.now().toUtc(),
  reliability: 100,
  projectId: UuidValue.withValidation('018f0000-0000-7000-8000-000000000001'),
  tenantPartyId: UuidValue.withValidation(
    '018f0000-0000-7000-8000-000000000002',
  ),
);

final class _Planner implements Planner {
  const _Planner();
  @override
  Future<ReasoningPlan> plan(ReasoningRequest request) async =>
      const ReasoningPlan(
        goal: 'Assess delivery risk',
        hypotheses: ['The project is delayed'],
        requiredEvidence: ['project'],
      );
}

final class _Drafter implements Drafter {
  const _Drafter();
  @override
  Future<List<ClaimCandidate>> draft(
    ReasoningRequest request,
    ReasoningPlan plan,
    List<EvidenceItem> evidence,
    int iteration,
  ) async => [
    ClaimCandidate(
      id: 'claim-1',
      statement: 'The project is delayed',
      type: ClaimType.fact,
      evidenceRelations: evidence.isEmpty
          ? const {}
          : {evidence.single.id: EvidenceRelation.supports},
    ),
  ];
}

final class _StaticCritic implements Critic {
  const _StaticCritic(this.decision);
  final CritiqueDecision decision;
  @override
  Future<CritiqueResult> critique(
    ReasoningRequest request,
    List<ClaimVerification> claims,
    int iteration,
  ) async => CritiqueResult(decision: decision);
}

final class _RevisionCritic implements Critic {
  int calls = 0;
  @override
  Future<CritiqueResult> critique(
    ReasoningRequest request,
    List<ClaimVerification> claims,
    int iteration,
  ) async {
    calls++;
    return const CritiqueResult(decision: CritiqueDecision.revise);
  }
}

final class _Finalizer implements Finalizer {
  int calls = 0;
  @override
  Future<String> finalize(
    ReasoningRequest request,
    List<ClaimVerification> claims,
    List<EvidenceItem> evidence,
  ) async {
    calls++;
    return 'Validated answer';
  }
}

final class _Tool implements NexusTool {
  const _Tool(this.evidence);
  final List<EvidenceItem> evidence;
  @override
  String get name => 'projects';
  @override
  Set<String> get supportedEvidenceTypes => const {'project'};
  @override
  Future<ToolResult> execute(ToolRequest request, ToolContext context) async =>
      ToolResult.success(evidence);
}
