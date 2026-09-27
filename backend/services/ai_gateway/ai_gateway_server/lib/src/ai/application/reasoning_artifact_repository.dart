import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../domain/reasoning_models.dart';

abstract interface class ReasoningArtifactStore {
  Future<void> save(Session session, UuidValue runId, ReasoningOutcome outcome);
}

final class ServerpodReasoningArtifactStore implements ReasoningArtifactStore {
  const ServerpodReasoningArtifactStore();

  @override
  Future<void> save(
    Session session,
    UuidValue runId,
    ReasoningOutcome outcome,
  ) => session.db.transaction(
    (transaction) => _saveInTransaction(session, transaction, runId, outcome),
  );

  Future<void> _saveInTransaction(
    Session session,
    Transaction transaction,
    UuidValue runId,
    ReasoningOutcome outcome,
  ) async {
    final evidenceIds = <String, UuidValue>{};
    for (final evidence in outcome.evidence) {
      final inserted = await AiEvidence.db.insertRow(
        session,
        AiEvidence(
          runId: runId,
          sourceService: evidence.sourceService,
          resourceType: evidence.resourceType,
          resourceId: evidence.resourceId,
          summary: _bounded(evidence.summary, 4000),
          reliability: evidence.reliability.clamp(0, 100) / 100,
          freshness: _freshness(evidence),
          observedAt: evidence.observedAt,
          collectedAt: evidence.collectedAt,
        ),
        transaction: transaction,
      );
      evidenceIds[evidence.id] = inserted.id!;
    }

    for (final verification in outcome.claims) {
      final claim = verification.claim;
      final inserted = await AiClaim.db.insertRow(
        session,
        AiClaim(
          runId: runId,
          statement: _bounded(claim.statement, 4000),
          claimType: claim.type.name,
          confidence: verification.confidence.name,
          verificationDecision: verification.decision.name,
          iteration: outcome.iterations,
        ),
        transaction: transaction,
      );
      for (final relation in claim.evidenceRelations.entries) {
        final evidenceId = evidenceIds[relation.key];
        if (evidenceId == null) continue;
        await AiClaimEvidence.db.insertRow(
          session,
          AiClaimEvidence(
            runId: runId,
            claimId: inserted.id!,
            evidenceId: evidenceId,
            relation: relation.value.name,
          ),
          transaction: transaction,
        );
      }
    }
  }

  double _freshness(EvidenceItem evidence) {
    final age = evidence.collectedAt.difference(
      evidence.observedAt ?? evidence.collectedAt,
    );
    if (age.inDays <= 1) return 1;
    if (age.inDays <= 30) return 0.7;
    return 0.4;
  }

  String _bounded(String value, int maxLength) =>
      value.length <= maxLength ? value : value.substring(0, maxLength);
}

final class NoopReasoningArtifactStore implements ReasoningArtifactStore {
  const NoopReasoningArtifactStore();
  @override
  Future<void> save(
    Session session,
    UuidValue runId,
    ReasoningOutcome outcome,
  ) async {}
}
