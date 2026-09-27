import '../../domain/reasoning_models.dart';

final class ReasoningLevelSelector {
  const ReasoningLevelSelector();

  ReasoningLevel select(ReasoningRequest request) {
    final text = request.question.toLowerCase();
    final minimum = _minimum(text);
    final requested = request.requestedLevel;
    if (requested == null || requested.index < minimum.index) return minimum;
    return requested;
  }

  ReasoningLevel _minimum(String text) {
    const highRisk = [
      'exploit',
      'attaque',
      'cyber',
      'supprimer',
      'production',
      'secret',
    ];
    if (highRisk.any(text.contains)) return ReasoningLevel.highRisk;
    const deep = [
      'pourquoi',
      'cause',
      'risque',
      'retard',
      'recommande',
      'dépendance',
    ];
    if (deep.any(text.contains)) return ReasoningLevel.deep;
    const direct = [
      'quel est',
      'quelle est',
      'nom du projet',
      'statut du projet',
    ];
    if (direct.any(text.contains)) return ReasoningLevel.direct;
    return ReasoningLevel.standard;
  }
}
