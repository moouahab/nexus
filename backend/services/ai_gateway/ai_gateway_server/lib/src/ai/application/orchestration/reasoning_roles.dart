import '../../domain/reasoning_models.dart';

abstract interface class Planner {
  Future<ReasoningPlan> plan(ReasoningRequest request);
}

abstract interface class Drafter {
  Future<List<ClaimCandidate>> draft(
    ReasoningRequest request,
    ReasoningPlan plan,
    List<EvidenceItem> evidence,
    int iteration,
  );
}

abstract interface class Critic {
  Future<CritiqueResult> critique(
    ReasoningRequest request,
    List<ClaimVerification> claims,
    int iteration,
  );
}

abstract interface class Finalizer {
  Future<String> finalize(
    ReasoningRequest request,
    List<ClaimVerification> claims,
    List<EvidenceItem> evidence,
  );
}
