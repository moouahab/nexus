import '../domain/reasoning_models.dart';

final class AiGenerationRequest {
  const AiGenerationRequest({
    required this.capability,
    required this.prompt,
    this.systemPrompt,
  });

  final String capability;
  final String prompt;
  final String? systemPrompt;
}

final class AiGenerationResult {
  const AiGenerationResult({
    required this.provider,
    required this.model,
    required this.output,
    this.metrics = const ModelCallMetrics(),
  });

  final String provider;
  final String model;
  final String output;
  final ModelCallMetrics metrics;
}

abstract interface class AiProvider {
  String get name;
  String get model;
  bool get isConfigured;

  Future<bool> isAvailable();
  Future<AiGenerationResult> generate(AiGenerationRequest request);
}

final class AiProviderException implements Exception {
  const AiProviderException(this.code);
  final String code;
}

final class UnavailableAiProvider implements AiProvider {
  const UnavailableAiProvider();

  @override
  String get name => 'unavailable';

  @override
  String get model => '';

  @override
  bool get isConfigured => false;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<AiGenerationResult> generate(AiGenerationRequest request) {
    throw const AiProviderException('provider_not_configured');
  }
}
