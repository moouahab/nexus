import '../../../application/tools/nexus_tool.dart';

/// Declares the future Work evidence vocabulary without fabricating data.
///
/// It deliberately returns `unavailable` until a real Work service adapter is
/// configured.
final class WorkEvidenceTool implements NexusTool {
  const WorkEvidenceTool();

  @override
  String get name => 'work';

  @override
  Set<String> get supportedEvidenceTypes => const {
    'work.blockedTasks',
    'work.lateTasks',
    'work.nextMilestone',
    'work.taskDependencies',
    'work.recentEvents',
    'work.projectProgress',
  };

  @override
  Future<ToolResult> execute(ToolRequest request, ToolContext context) async =>
      const ToolResult.unavailable(code: 'work_service_unavailable');
}
