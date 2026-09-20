import 'dart:convert';

import '../../application/ai_provider.dart';
import '../../application/orchestration/reasoning_roles.dart';
import '../../domain/reasoning_models.dart';

const _structuredResponseError = 'invalid_structured_response';

final class OllamaPlanner implements Planner {
  const OllamaPlanner(this._provider);

  final AiProvider _provider;

  @override
  Future<ReasoningPlan> plan(ReasoningRequest request) async {
    final json = await _JsonRoleClient(_provider, request.telemetry).call(
      capability: 'reasoning_planner',
      systemPrompt: '''
You are the Nexus planning role. Return one JSON object only, with exactly:
{"goal":"string","hypotheses":["string"],"requiredEvidence":["string"],"missingInformation":["string"]}
Plan which Nexus sources are necessary. Keep hypotheses testable and concise.
Do not answer the user, claim facts, reveal chain-of-thought, or add markdown.
''',
      payload: {'question': request.question},
    );
    _expectOnlyKeys(json, const {
      'goal',
      'hypotheses',
      'requiredEvidence',
      'missingInformation',
    });
    return ReasoningPlan(
      goal: _requiredString(json, 'goal'),
      hypotheses: _stringList(json, 'hypotheses', maxItems: 12),
      requiredEvidence: _stringList(json, 'requiredEvidence', maxItems: 12),
      missingInformation: _stringList(json, 'missingInformation', maxItems: 12),
    );
  }
}

final class OllamaDrafter implements Drafter {
  const OllamaDrafter(this._provider);

  final AiProvider _provider;

  @override
  Future<List<ClaimCandidate>> draft(
    ReasoningRequest request,
    ReasoningPlan plan,
    List<EvidenceItem> evidence,
    int iteration,
  ) async {
    final json = await _JsonRoleClient(_provider, request.telemetry).call(
      capability: 'reasoning_drafter',
      systemPrompt: '''
You are the Nexus drafting role. Return one JSON object only:
{"claims":[{"id":"string","statement":"string","type":"fact|inference|hypothesis|unknown","evidenceRelations":{"evidence-id":"supports|contradicts|contextual|inconclusive"}}]}
Use only evidence IDs present in the input. A fact must be directly stated by evidence.
No evidence means hypothesis or unknown, never fact. Do not reveal chain-of-thought,
write a final answer, invent evidence, or add markdown.
''',
      payload: {
        'question': request.question,
        'iteration': iteration,
        'plan': _planJson(plan),
        'evidence': evidence.map(_evidenceJson).toList(growable: false),
      },
    );
    final knownEvidence = evidence.map((item) => item.id).toSet();
    _expectOnlyKeys(json, const {'claims'});
    final rawClaims = _objectList(json, 'claims', maxItems: 20);
    final ids = <String>{};
    return rawClaims
        .map((raw) {
          _expectOnlyKeys(raw, const {
            'id',
            'statement',
            'type',
            'evidenceRelations',
          });
          final id = _requiredString(raw, 'id');
          if (!ids.add(id)) _invalid();
          final relationsRaw = raw['evidenceRelations'];
          if (relationsRaw is! Map<String, dynamic>) _invalid();
          final relations = <String, EvidenceRelation>{};
          for (final entry in relationsRaw.entries) {
            if (!knownEvidence.contains(entry.key) || entry.value is! String) {
              _invalid();
            }
            relations[entry.key] = _evidenceRelation(entry.value as String);
          }
          final type = _claimType(_requiredString(raw, 'type'));
          if (type == ClaimType.fact &&
              !relations.values.contains(EvidenceRelation.supports)) {
            _invalid();
          }
          return ClaimCandidate(
            id: id,
            statement: _requiredString(raw, 'statement'),
            type: type,
            evidenceRelations: Map.unmodifiable(relations),
          );
        })
        .toList(growable: false);
  }
}

final class OllamaCritic implements Critic {
  const OllamaCritic(this._provider);

  final AiProvider _provider;

  @override
  Future<CritiqueResult> critique(
    ReasoningRequest request,
    List<ClaimVerification> claims,
    int iteration,
  ) async {
    final json = await _JsonRoleClient(_provider, request.telemetry).call(
      capability: 'reasoning_critic',
      systemPrompt: '''
You are the Nexus critic role. Return one JSON object only:
{"decision":"accept|revise|reject|needsInformation|needsHumanApproval","issues":["string"]}
Reject unsupported certainty and contradictions. Request revision only when another
iteration can correct the claims using the supplied verification results. Do not
re-evaluate source data, reveal chain-of-thought, or add markdown.
''',
      payload: {
        'question': request.question,
        'iteration': iteration,
        'claims': claims.map(_verificationJson).toList(growable: false),
      },
    );
    _expectOnlyKeys(json, const {'decision', 'issues'});
    return CritiqueResult(
      decision: _critiqueDecision(_requiredString(json, 'decision')),
      issues: _stringList(json, 'issues', maxItems: 20),
    );
  }
}

final class OllamaFinalizer implements Finalizer {
  const OllamaFinalizer(this._provider);

  final AiProvider _provider;

  @override
  Future<String> finalize(
    ReasoningRequest request,
    List<ClaimVerification> claims,
    List<EvidenceItem> evidence,
  ) async {
    final verified = claims
        .where((claim) => claim.decision == VerificationDecision.supported)
        .toList(growable: false);
    if (verified.isEmpty) {
      throw const AiProviderException(_structuredResponseError);
    }
    final allowedEvidenceIds = verified
        .expand((claim) => claim.supportingEvidenceIds)
        .toSet();
    final allowedEvidence = evidence
        .where((item) => allowedEvidenceIds.contains(item.id))
        .toList(growable: false);
    final json = await _JsonRoleClient(_provider, request.telemetry).call(
      capability: 'reasoning_finalizer',
      systemPrompt: '''
You are the Nexus finalizer role. Return one JSON object only: {"answer":"string"}.
Answer using only the supplied verified claims and supporting evidence. Express
limits explicitly. Do not add new claims, speculate, reveal chain-of-thought, cite
an unknown evidence ID, or add markdown outside the answer string.
''',
      payload: {
        'question': request.question,
        'verifiedClaims': verified
            .map(_verificationJson)
            .toList(growable: false),
        'supportingEvidence': allowedEvidence
            .map(_evidenceJson)
            .toList(growable: false),
      },
    );
    _expectOnlyKeys(json, const {'answer'});
    return _requiredString(json, 'answer');
  }
}

final class _JsonRoleClient {
  const _JsonRoleClient(this.provider, this.telemetry);

  final AiProvider provider;
  final AiRunTelemetry? telemetry;

  Future<Map<String, dynamic>> call({
    required String capability,
    required String systemPrompt,
    required Map<String, dynamic> payload,
  }) async {
    final result = await provider.generate(
      AiGenerationRequest(
        capability: capability,
        systemPrompt: systemPrompt.trim(),
        prompt: jsonEncode(payload),
      ),
    );
    telemetry?.recordModelCall(result.metrics);
    try {
      final decoded = jsonDecode(_extractJsonObject(result.output));
      if (decoded is! Map<String, dynamic>) _invalid();
      return decoded;
    } on AiProviderException {
      rethrow;
    } on Object {
      _invalid();
    }
  }
}

String _extractJsonObject(String output) {
  var value = output.trim();
  if (value.startsWith('```')) {
    final firstLine = value.indexOf('\n');
    final closingFence = value.lastIndexOf('```');
    if (firstLine < 0 || closingFence <= firstLine) _invalid();
    value = value.substring(firstLine + 1, closingFence).trim();
  }
  final start = value.indexOf('{');
  final end = value.lastIndexOf('}');
  if (start < 0 || end < start) _invalid();
  if (value.substring(0, start).trim().isNotEmpty ||
      value.substring(end + 1).trim().isNotEmpty) {
    _invalid();
  }
  return value.substring(start, end + 1);
}

Map<String, dynamic> _planJson(ReasoningPlan plan) => {
  'goal': plan.goal,
  'hypotheses': plan.hypotheses,
  'requiredEvidence': plan.requiredEvidence,
  'missingInformation': plan.missingInformation,
};

Map<String, dynamic> _evidenceJson(EvidenceItem item) => {
  'id': item.id,
  'sourceService': item.sourceService,
  'resourceType': item.resourceType,
  'resourceId': item.resourceId,
  'summary': item.summary,
  'observedAt': item.observedAt?.toUtc().toIso8601String(),
  'collectedAt': item.collectedAt.toUtc().toIso8601String(),
  'reliability': item.reliability,
  'projectId': item.projectId.toString(),
  'tenantPartyId': item.tenantPartyId.toString(),
  'freshness': item.freshness.name,
  'data': item.data,
};

Map<String, dynamic> _verificationJson(ClaimVerification item) => {
  'id': item.claim.id,
  'statement': item.claim.statement,
  'type': item.claim.type.name,
  'decision': item.decision.name,
  'confidence': item.confidence.name,
  'score': item.score,
  'supportingEvidenceIds': item.supportingEvidenceIds,
  'contradictingEvidenceIds': item.contradictingEvidenceIds,
};

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty || value.length > 8000) {
    _invalid();
  }
  return value.trim();
}

List<String> _stringList(
  Map<String, dynamic> json,
  String key, {
  required int maxItems,
}) {
  final value = json[key];
  if (value is! List || value.length > maxItems) _invalid();
  return value
      .map((item) {
        if (item is! String || item.trim().isEmpty || item.length > 2000) {
          _invalid();
        }
        return item.trim();
      })
      .toList(growable: false);
}

List<Map<String, dynamic>> _objectList(
  Map<String, dynamic> json,
  String key, {
  required int maxItems,
}) {
  final value = json[key];
  if (value is! List || value.length > maxItems) _invalid();
  return value
      .map((item) {
        if (item is! Map<String, dynamic>) _invalid();
        return item;
      })
      .toList(growable: false);
}

ClaimType _claimType(String value) => switch (value) {
  'fact' => ClaimType.fact,
  'inference' => ClaimType.inference,
  'hypothesis' => ClaimType.hypothesis,
  'unknown' => ClaimType.unknown,
  _ => _invalid(),
};

EvidenceRelation _evidenceRelation(String value) => switch (value) {
  'supports' => EvidenceRelation.supports,
  'contradicts' => EvidenceRelation.contradicts,
  'contextual' => EvidenceRelation.contextual,
  'inconclusive' => EvidenceRelation.inconclusive,
  _ => _invalid(),
};

CritiqueDecision _critiqueDecision(String value) => switch (value) {
  'accept' => CritiqueDecision.accept,
  'revise' => CritiqueDecision.revise,
  'reject' => CritiqueDecision.reject,
  'needsInformation' => CritiqueDecision.needsInformation,
  'needsHumanApproval' => CritiqueDecision.needsHumanApproval,
  _ => _invalid(),
};

Never _invalid() => throw const AiProviderException(_structuredResponseError);

void _expectOnlyKeys(Map<String, dynamic> json, Set<String> keys) {
  if (json.keys.any((key) => !keys.contains(key))) _invalid();
}
