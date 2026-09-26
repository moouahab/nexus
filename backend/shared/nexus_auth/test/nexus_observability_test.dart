import 'package:nexus_auth/nexus_auth.dart';
import 'package:test/test.dart';

void main() {
  test('keeps a valid upstream request id', () {
    expect(
      NexusObservability.normalizeRequestId('gateway-12345678'),
      'gateway-12345678',
    );
  });

  test('replaces unsafe request ids', () {
    const unsafe = 'Bearer secret-token-value\nuser@example.test';
    final generated = NexusObservability.normalizeRequestId(unsafe);
    expect(generated, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(generated, isNot(contains('\n')));
    expect(generated, isNot(contains('secret-token-value')));
    expect(generated, isNot(contains('user@example.test')));
  });

  test('redacts sensitive fields recursively before logging', () {
    final fields = NexusObservability.sanitizeLogFields({
      'outcome': 'failed',
      'prompt': 'PROMPT_CANARY',
      'nested': {'authorization': 'TOKEN_CANARY', 'duration_ms': 12},
    });

    expect(fields['outcome'], 'failed');
    expect(fields['prompt'], '[REDACTED]');
    expect(fields['nested'], {
      'authorization': '[REDACTED]',
      'duration_ms': 12,
    });
    expect(fields.toString(), isNot(contains('PROMPT_CANARY')));
    expect(fields.toString(), isNot(contains('TOKEN_CANARY')));
  });
}
