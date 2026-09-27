import 'package:ai_gateway_server/src/ai/application/ai_gateway_application.dart';
import 'package:ai_gateway_server/src/ai/http/ai_http_dto.dart';
import 'package:ai_gateway_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test('public run DTO omits requester identity and Serverpod metadata', () {
    final run = AiRun(
      id: _uuid('018f0000-0000-7000-8000-000000000001'),
      requestId: _uuid('018f0000-0000-7000-8000-000000000002'),
      projectId: _uuid('018f0000-0000-7000-8000-000000000003'),
      tenantPartyId: _uuid('018f0000-0000-7000-8000-000000000004'),
      capability: 'summary',
      requesterIdentityId: _uuid('018f0000-0000-7000-8000-000000000005'),
      provider: 'ollama',
      model: 'qwen3.5:9b',
      outputText: 'Safe generated output',
      createdAt: DateTime.utc(2026),
    );

    final json = aiRunJson(run);

    expect(json['status'], 'queued');
    expect(json, isNot(contains('requesterIdentityId')));
    expect(json, isNot(contains('requesterService')));
    expect(json, isNot(contains('__className__')));
    expect(json['provider'], 'ollama');
    expect(json['model'], 'qwen3.5:9b');
    expect(json['output'], 'Safe generated output');
  });

  test('context preview DTO has the documented stable shape', () {
    final json = contextPreviewJson(
      ContextPreview(
        requestId: _uuid('018f0000-0000-7000-8000-000000000001'),
        allowed: false,
        missingSources: const ['documents'],
        warnings: const ['authorization unavailable'],
      ),
    );

    expect(json.keys, {
      'requestId',
      'allowed',
      'resolvedSources',
      'missingSources',
      'warnings',
    });
  });
}

UuidValue _uuid(String value) => UuidValue.withValidation(value);
