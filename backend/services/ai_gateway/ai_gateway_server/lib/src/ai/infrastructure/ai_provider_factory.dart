import 'dart:io';

import '../application/ai_provider.dart';
import 'ollama/ollama_provider.dart';

abstract final class AiProviderFactory {
  static AiProvider fromEnvironment([Map<String, String>? environment]) {
    final env = environment ?? Platform.environment;
    if ((env['AI_PROVIDER'] ?? '').toLowerCase() != 'ollama') {
      return const UnavailableAiProvider();
    }
    final rawUrl = env['OLLAMA_BASE_URL'];
    final model = env['OLLAMA_MODEL'];
    if (rawUrl == null || model == null || model.trim().isEmpty) {
      return const UnavailableAiProvider();
    }
    final seconds = int.tryParse(env['OLLAMA_TIMEOUT_SECONDS'] ?? '') ?? 120;
    final maxTokens = int.tryParse(env['OLLAMA_MAX_TOKENS'] ?? '') ?? 512;
    return OllamaProvider(
      baseUri: Uri.parse(rawUrl),
      model: model.trim(),
      timeout: Duration(seconds: seconds.clamp(5, 600)),
      maxOutputTokens: maxTokens.clamp(16, 4096),
    );
  }
}
