import 'dart:convert';

import 'package:ai_gateway_server/src/ai/application/ai_provider.dart';
import 'package:ai_gateway_server/src/ai/domain/reasoning_models.dart';
import 'package:ai_gateway_server/src/ai/infrastructure/ollama/ollama_reasoning_roles.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  final request = ReasoningRequest(
    question: 'Pourquoi le projet est-il bloqué ?',
    projectId: UuidValue.fromString('018f0000-0000-7000-8000-000000000001'),
    tenantPartyId: UuidValue.fromString('018f0000-0000-7000-8000-000000000002'),
    bearerToken: 'secret',
  );
  final evidence = EvidenceItem(
    id: 'work:T-42',
    sourceService: 'work',
    resourceType: 'task',
    resourceId: 'T-42',
    summary: 'OAuth task is blocked',
    collectedAt: DateTime.utc(2026, 9, 19),
    projectId: request.projectId,
    tenantPartyId: request.tenantPartyId,
  );

  test(
    'planner accepts a fenced JSON object without exposing free text',
    () async {
      final provider = _FakeProvider([
        '''```json
{"goal":"Find the blocker","hypotheses":["OAuth blocks delivery"],"requiredEvidence":["tasks"],"missingInformation":[]}
```''',
      ]);

      final plan = await OllamaPlanner(provider).plan(request);

      expect(plan.goal, 'Find the blocker');
      expect(plan.requiredEvidence, ['tasks']);
      expect(provider.requests.single.capability, 'reasoning_planner');
      expect(
        provider.requests.single.systemPrompt,
        contains('chain-of-thought'),
      );
    },
  );

  test('drafter rejects invented evidence identifiers', () async {
    final provider = _FakeProvider([
      jsonEncode({
        'claims': [
          {
            'id': 'claim-1',
            'statement': 'OAuth is blocked',
            'type': 'fact',
            'evidenceRelations': {'invented:T-99': 'supports'},
          },
        ],
      }),
    ]);

    await expectLater(
      OllamaDrafter(provider).draft(
        request,
        const ReasoningPlan(
          goal: 'Find blocker',
          hypotheses: ['OAuth'],
          requiredEvidence: ['tasks'],
        ),
        [evidence],
        1,
      ),
      throwsA(
        isA<AiProviderException>().having(
          (error) => error.code,
          'code',
          'invalid_structured_response',
        ),
      ),
    );
  });

  test('drafter prevents a fact without supporting evidence', () async {
    final provider = _FakeProvider([
      jsonEncode({
        'claims': [
          {
            'id': 'claim-1',
            'statement': 'OAuth is blocked',
            'type': 'fact',
            'evidenceRelations': <String, String>{},
          },
        ],
      }),
    ]);

    await expectLater(
      OllamaDrafter(provider).draft(
        request,
        const ReasoningPlan(
          goal: 'Find blocker',
          hypotheses: ['OAuth'],
          requiredEvidence: ['tasks'],
        ),
        [evidence],
        1,
      ),
      throwsA(isA<AiProviderException>()),
    );
  });

  test(
    'finalizer sends only supported claims and their supporting evidence',
    () async {
      final provider = _FakeProvider(['{"answer":"OAuth est bloqué."}']);
      final supported = _verification(
        'supported',
        VerificationDecision.supported,
        ['work:T-42'],
      );
      final rejected = _verification(
        'rejected',
        VerificationDecision.contradicted,
        ['other:T-9'],
      );
      final unrelated = EvidenceItem(
        id: 'other:T-9',
        sourceService: 'work',
        resourceType: 'task',
        resourceId: 'T-9',
        summary: 'Unrelated',
        collectedAt: DateTime.utc(2026, 9, 19),
        projectId: request.projectId,
        tenantPartyId: request.tenantPartyId,
      );

      final answer = await OllamaFinalizer(
        provider,
      ).finalize(request, [supported, rejected], [evidence, unrelated]);

      expect(answer, 'OAuth est bloqué.');
      final payload = jsonDecode(provider.requests.single.prompt) as Map;
      expect((payload['verifiedClaims'] as List), hasLength(1));
      expect((payload['verifiedClaims'] as List).single['id'], 'supported');
      expect((payload['supportingEvidence'] as List), hasLength(1));
      expect((payload['supportingEvidence'] as List).single['id'], 'work:T-42');
    },
  );

  test('strict parsing rejects prose around JSON and unknown fields', () async {
    final provider = _FakeProvider([
      'Here is the result: {"decision":"accept","issues":[],"extra":true}',
    ]);

    await expectLater(
      OllamaCritic(provider).critique(request, [], 1),
      throwsA(isA<AiProviderException>()),
    );
  });
}

ClaimVerification _verification(
  String id,
  VerificationDecision decision,
  List<String> supportingEvidenceIds,
) => ClaimVerification(
  claim: ClaimCandidate(
    id: id,
    statement: id,
    type: ClaimType.fact,
    evidenceRelations: const {},
  ),
  decision: decision,
  confidence: EvidenceConfidence.verified,
  score: 90,
  supportingEvidenceIds: supportingEvidenceIds,
  contradictingEvidenceIds: const [],
);

final class _FakeProvider implements AiProvider {
  _FakeProvider(List<String> outputs) : _outputs = List.of(outputs);

  final List<String> _outputs;
  final List<AiGenerationRequest> requests = [];

  @override
  bool get isConfigured => true;

  @override
  String get model => 'fake';

  @override
  String get name => 'fake';

  @override
  Future<AiGenerationResult> generate(AiGenerationRequest request) async {
    requests.add(request);
    return AiGenerationResult(
      provider: name,
      model: model,
      output: _outputs.removeAt(0),
    );
  }

  @override
  Future<bool> isAvailable() async => true;
}
