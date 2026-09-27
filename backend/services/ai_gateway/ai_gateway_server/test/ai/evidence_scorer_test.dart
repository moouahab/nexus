import 'package:ai_gateway_server/src/ai/application/verification/evidence_scorer.dart';
import 'package:ai_gateway_server/src/ai/domain/reasoning_models.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  const scorer = EvidenceScorer();

  test('no evidence means insufficient evidence and low confidence', () {
    final result = scorer.score(
      const ClaimCandidate(
        id: 'c1',
        statement: 'Unsupported statement',
        type: ClaimType.hypothesis,
      ),
      const [],
    );
    expect(result.decision, VerificationDecision.insufficientEvidence);
    expect(result.confidence, EvidenceConfidence.low);
  });

  test('a contradiction prevents verification', () {
    final evidence = EvidenceItem(
      id: 'e1',
      sourceService: 'projects',
      resourceType: 'deployment',
      resourceId: 'D-1',
      summary: 'Deployment succeeded',
      collectedAt: DateTime.now().toUtc(),
      reliability: 100,
      projectId: UuidValue.withValidation(
        '018f0000-0000-7000-8000-000000000001',
      ),
      tenantPartyId: UuidValue.withValidation(
        '018f0000-0000-7000-8000-000000000002',
      ),
    );
    final result = scorer.score(
      const ClaimCandidate(
        id: 'c1',
        statement: 'Deployment failed',
        type: ClaimType.hypothesis,
        evidenceRelations: {'e1': EvidenceRelation.contradicts},
      ),
      [evidence],
    );
    expect(result.decision, VerificationDecision.contradicted);
    expect(result.confidence, EvidenceConfidence.low);
  });
}
