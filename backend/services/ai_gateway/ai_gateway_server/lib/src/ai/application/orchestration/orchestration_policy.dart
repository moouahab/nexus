import '../../domain/reasoning_models.dart';

final class OrchestrationPolicy {
  const OrchestrationPolicy({
    required this.maxIterations,
    required this.maxToolCalls,
    required this.requireCritic,
    required this.requireHumanApproval,
  });

  final int maxIterations;
  final int maxToolCalls;
  final bool requireCritic;
  final bool requireHumanApproval;

  factory OrchestrationPolicy.forLevel(ReasoningLevel level) => switch (level) {
    ReasoningLevel.direct => const OrchestrationPolicy(
      maxIterations: 1,
      maxToolCalls: 2,
      requireCritic: false,
      requireHumanApproval: false,
    ),
    ReasoningLevel.standard => const OrchestrationPolicy(
      maxIterations: 1,
      maxToolCalls: 5,
      requireCritic: true,
      requireHumanApproval: false,
    ),
    ReasoningLevel.deep => const OrchestrationPolicy(
      maxIterations: 2,
      maxToolCalls: 10,
      requireCritic: true,
      requireHumanApproval: false,
    ),
    ReasoningLevel.highRisk => const OrchestrationPolicy(
      maxIterations: 3,
      maxToolCalls: 15,
      requireCritic: true,
      requireHumanApproval: true,
    ),
  };
}
