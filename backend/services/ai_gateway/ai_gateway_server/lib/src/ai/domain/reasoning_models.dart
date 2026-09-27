import 'package:serverpod/serverpod.dart';

enum ReasoningLevel { direct, standard, deep, highRisk }

enum ReasoningStage {
  planning,
  collectingEvidence,
  drafting,
  verifying,
  criticizing,
  revising,
  validating,
}

enum ClaimType { fact, inference, hypothesis, unknown }

enum EvidenceConfidence { low, medium, high, verified }

enum EvidenceRelation { supports, contradicts, contextual, inconclusive }

enum EvidenceFreshness { current, recent, stale, unknown }

enum VerificationDecision { supported, contradicted, insufficientEvidence }

enum CritiqueDecision {
  accept,
  revise,
  reject,
  needsInformation,
  needsHumanApproval,
}

final class ReasoningRequest {
  const ReasoningRequest({
    required this.question,
    required this.projectId,
    required this.tenantPartyId,
    required this.bearerToken,
    this.requestedLevel,
    this.telemetry,
  });

  final String question;
  final UuidValue projectId;
  final UuidValue tenantPartyId;
  final String bearerToken;
  final ReasoningLevel? requestedLevel;
  final AiRunTelemetry? telemetry;
}

final class ReasoningPlan {
  const ReasoningPlan({
    required this.goal,
    required this.hypotheses,
    required this.requiredEvidence,
    this.missingInformation = const [],
  });

  final String goal;
  final List<String> hypotheses;
  final List<String> requiredEvidence;
  final List<String> missingInformation;
}

final class EvidenceItem {
  const EvidenceItem({
    required this.id,
    required this.sourceService,
    required this.resourceType,
    required this.resourceId,
    required this.summary,
    required this.collectedAt,
    required this.projectId,
    required this.tenantPartyId,
    this.observedAt,
    this.reliability = 70,
    this.freshness = EvidenceFreshness.unknown,
    this.data = const {},
  });

  final String id;
  final String sourceService;
  final String resourceType;
  final String resourceId;
  final String summary;
  final DateTime collectedAt;
  final UuidValue projectId;
  final UuidValue tenantPartyId;
  final DateTime? observedAt;
  final int reliability;
  final EvidenceFreshness freshness;
  final Map<String, dynamic> data;
}

final class ModelCallMetrics {
  const ModelCallMetrics({
    this.inputTokens,
    this.outputTokens,
    this.totalDurationMs,
    this.timeToFirstTokenMs,
  });

  final int? inputTokens;
  final int? outputTokens;
  final int? totalDurationMs;
  final int? timeToFirstTokenMs;
}

/// Per-run, in-memory telemetry. It contains counters and timings only.
final class AiRunTelemetry {
  final Map<ReasoningStage, int> stageDurationMs = {};
  int ollamaCallCount = 0;
  int inputTokenCount = 0;
  int outputTokenCount = 0;
  int? timeToFirstTokenMs;

  void recordStage(ReasoningStage stage, Duration duration) {
    stageDurationMs.update(
      stage,
      (value) => value + duration.inMilliseconds,
      ifAbsent: () => duration.inMilliseconds,
    );
  }

  void recordModelCall(ModelCallMetrics metrics) {
    ollamaCallCount++;
    inputTokenCount += metrics.inputTokens ?? 0;
    outputTokenCount += metrics.outputTokens ?? 0;
    timeToFirstTokenMs ??= metrics.timeToFirstTokenMs;
  }
}

final class ClaimCandidate {
  const ClaimCandidate({
    required this.id,
    required this.statement,
    required this.type,
    this.evidenceRelations = const {},
  });

  final String id;
  final String statement;
  final ClaimType type;
  final Map<String, EvidenceRelation> evidenceRelations;
}

final class ClaimVerification {
  const ClaimVerification({
    required this.claim,
    required this.decision,
    required this.confidence,
    required this.score,
    required this.supportingEvidenceIds,
    required this.contradictingEvidenceIds,
  });

  final ClaimCandidate claim;
  final VerificationDecision decision;
  final EvidenceConfidence confidence;
  final int score;
  final List<String> supportingEvidenceIds;
  final List<String> contradictingEvidenceIds;
}

final class CritiqueResult {
  const CritiqueResult({required this.decision, this.issues = const []});

  final CritiqueDecision decision;
  final List<String> issues;
}

final class ReasoningOutcome {
  const ReasoningOutcome({
    required this.answer,
    required this.level,
    required this.iterations,
    required this.claims,
    required this.evidence,
    required this.validated,
    required this.finalDecision,
    this.requiresHumanApproval = false,
  });

  final String answer;
  final ReasoningLevel level;
  final int iterations;
  final List<ClaimVerification> claims;
  final List<EvidenceItem> evidence;
  final bool validated;
  final CritiqueDecision finalDecision;
  final bool requiresHumanApproval;
}
