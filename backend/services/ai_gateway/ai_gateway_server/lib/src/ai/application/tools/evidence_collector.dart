import '../../domain/reasoning_models.dart';
import '../orchestration/orchestration_policy.dart';
import 'nexus_tool.dart';

final class EvidenceCollector {
  const EvidenceCollector(this.registry);
  final NexusToolRegistry registry;

  Future<List<EvidenceItem>> collect(
    ReasoningRequest request,
    ReasoningPlan plan,
    OrchestrationPolicy policy,
  ) async {
    final collected = <EvidenceItem>[];
    var calls = 0;
    final context = ToolContext.fromReasoningRequest(request);
    for (final evidenceType in plan.requiredEvidence.toSet()) {
      for (final tool in registry.resolve(evidenceType)) {
        if (calls >= policy.maxToolCalls) return collected;
        calls++;
        final result = await tool.execute(
          ToolRequest(evidenceType: evidenceType),
          context,
        );
        if (result.status != ToolResultStatus.success) continue;
        for (final evidence in result.evidence) {
          if (evidence.projectId != request.projectId ||
              evidence.tenantPartyId != request.tenantPartyId) {
            throw StateError(
              'A NexusTool returned evidence outside run scope.',
            );
          }
          collected.add(evidence);
        }
      }
    }
    return collected;
  }
}
