import '../../domain/reasoning_models.dart';

final class RevisionController {
  const RevisionController();

  bool shouldRevise(CritiqueResult critique, int iteration, int maxIterations) {
    return critique.decision == CritiqueDecision.revise &&
        iteration < maxIterations;
  }
}
