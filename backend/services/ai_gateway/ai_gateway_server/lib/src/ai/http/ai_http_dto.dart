import '../../generated/protocol.dart';
import '../application/ai_gateway_application.dart';

Map<String, dynamic> aiRunJson(AiRun run) => {
  if (run.id != null) 'id': run.id.toString(),
  'requestId': run.requestId.toString(),
  'projectId': run.projectId.toString(),
  'tenantPartyId': run.tenantPartyId.toString(),
  if (run.missionId != null) 'missionId': run.missionId.toString(),
  'capability': run.capability,
  'status': run.status.name,
  if (run.failureCode != null) 'failureCode': run.failureCode,
  if (run.provider != null) 'provider': run.provider,
  if (run.model != null) 'model': run.model,
  if (run.outputText != null) 'output': run.outputText,
  if (run.reasoningLevel != null) 'reasoningLevel': run.reasoningLevel,
  if (run.currentIteration != null) 'currentIteration': run.currentIteration,
  if (run.maxIterations != null) 'maxIterations': run.maxIterations,
  if (run.validated != null) 'validated': run.validated,
  'createdAt': run.createdAt.toUtc().toIso8601String(),
  if (run.updatedAt != null)
    'updatedAt': run.updatedAt!.toUtc().toIso8601String(),
};

Map<String, dynamic> contextPreviewJson(ContextPreview preview) => {
  'requestId': preview.requestId.toString(),
  'allowed': preview.allowed,
  'resolvedSources': preview.resolvedSources,
  'missingSources': preview.missingSources,
  'warnings': preview.warnings,
};
