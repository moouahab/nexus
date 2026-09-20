import '../application/ai_provider.dart';
import '../application/orchestration/reasoning_orchestrator.dart';
import '../application/tools/evidence_collector.dart';
import '../application/tools/nexus_tool.dart';
import 'ollama/ollama_reasoning_roles.dart';
import 'tools/projects/project_evidence_tool_factory.dart';
import 'tools/work/work_evidence_tool.dart';

abstract final class ReasoningOrchestratorFactory {
  static ReasoningOrchestrator fromEnvironment(AiProvider provider) {
    final projectTool = ProjectEvidenceToolFactory.fromEnvironment();
    return ReasoningOrchestrator(
      planner: OllamaPlanner(provider),
      drafter: OllamaDrafter(provider),
      critic: OllamaCritic(provider),
      finalizer: OllamaFinalizer(provider),
      evidenceCollector: EvidenceCollector(
        NexusToolRegistry([?projectTool, const WorkEvidenceTool()]),
      ),
    );
  }
}
