import '../../domain/reasoning_models.dart';

final class EvidenceScorer {
  const EvidenceScorer();

  ClaimVerification score(ClaimCandidate claim, List<EvidenceItem> evidence) {
    final supporting = <String>[];
    final contradicting = <String>[];
    var points = 0;
    for (final item in evidence) {
      final relation = claim.evidenceRelations[item.id];
      if (relation == EvidenceRelation.supports) {
        supporting.add(item.id);
        points += _weight(item);
      } else if (relation == EvidenceRelation.contradicts) {
        contradicting.add(item.id);
        points -= _weight(item);
      }
    }
    final decision = contradicting.isNotEmpty && points <= 0
        ? VerificationDecision.contradicted
        : supporting.isEmpty
        ? VerificationDecision.insufficientEvidence
        : VerificationDecision.supported;
    return ClaimVerification(
      claim: claim,
      decision: decision,
      confidence: _confidence(decision, points, supporting.length),
      score: points.clamp(-100, 100),
      supportingEvidenceIds: supporting,
      contradictingEvidenceIds: contradicting,
    );
  }

  int _weight(EvidenceItem item) {
    final age = DateTime.now().toUtc().difference(
      item.observedAt ?? item.collectedAt,
    );
    final freshness = age.inDays <= 1
        ? 30
        : age.inDays <= 30
        ? 20
        : 10;
    return ((item.reliability.clamp(0, 100) * 0.7) + freshness).round();
  }

  EvidenceConfidence _confidence(
    VerificationDecision decision,
    int score,
    int count,
  ) {
    if (decision != VerificationDecision.supported) {
      return EvidenceConfidence.low;
    }
    if (score >= 85 && count >= 2) return EvidenceConfidence.verified;
    if (score >= 70) return EvidenceConfidence.high;
    if (score >= 40) return EvidenceConfidence.medium;
    return EvidenceConfidence.low;
  }
}
