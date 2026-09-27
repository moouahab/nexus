import '../../domain/reasoning_models.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class NexusTool {
  String get name;
  Set<String> get supportedEvidenceTypes;
  Future<ToolResult> execute(ToolRequest request, ToolContext context);
}

final class ToolRequest {
  const ToolRequest({required this.evidenceType});
  final String evidenceType;
}

final class ToolContext {
  const ToolContext({
    required this.projectId,
    required this.tenantPartyId,
    required this.bearerToken,
  });
  factory ToolContext.fromReasoningRequest(ReasoningRequest request) =>
      ToolContext(
        projectId: request.projectId,
        tenantPartyId: request.tenantPartyId,
        bearerToken: request.bearerToken,
      );

  final UuidValue projectId;
  final UuidValue tenantPartyId;
  final String bearerToken;
}

enum ToolResultStatus { success, unavailable, unsupported }

final class ToolResult {
  const ToolResult({required this.status, this.evidence = const [], this.code});
  const ToolResult.success(List<EvidenceItem> evidence)
    : this(status: ToolResultStatus.success, evidence: evidence);
  const ToolResult.unavailable({String? code})
    : this(status: ToolResultStatus.unavailable, code: code);
  const ToolResult.unsupported()
    : this(status: ToolResultStatus.unsupported, code: 'unsupported_evidence');

  final ToolResultStatus status;
  final List<EvidenceItem> evidence;
  final String? code;
}

final class NexusToolRegistry {
  const NexusToolRegistry(this.tools);
  final List<NexusTool> tools;

  List<NexusTool> resolve(String evidenceType) => tools
      .where((tool) => tool.supportedEvidenceTypes.contains(evidenceType))
      .toList(growable: false);
}

@Deprecated('Use NexusToolRegistry.')
typedef ToolRegistry = NexusToolRegistry;
