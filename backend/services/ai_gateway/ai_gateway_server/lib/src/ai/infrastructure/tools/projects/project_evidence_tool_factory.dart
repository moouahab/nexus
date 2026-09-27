import 'dart:io';

import 'project_evidence_tool.dart';

abstract final class ProjectEvidenceToolFactory {
  /// Returns no tool when Projects is not configured, so evidence collection
  /// fails closed instead of silently trusting fabricated project context.
  static ProjectEvidenceTool? fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;
    final rawUrl = env['PROJECTS_BASE_URL'];
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;

    final timeoutSeconds =
        int.tryParse(env['PROJECTS_TIMEOUT_SECONDS'] ?? '') ?? 10;
    final maxEvents =
        int.tryParse(env['PROJECTS_EVIDENCE_MAX_EVENTS'] ?? '') ?? 25;
    final maxBytes =
        int.tryParse(env['PROJECTS_EVIDENCE_MAX_BYTES'] ?? '') ?? 1024 * 1024;
    return ProjectEvidenceTool(
      baseUri: Uri.parse(rawUrl),
      timeout: Duration(seconds: timeoutSeconds.clamp(2, 60)),
      maxRecentEvents: maxEvents.clamp(1, 100),
      maxResponseBytes: maxBytes.clamp(1024, 4 * 1024 * 1024),
    );
  }
}
