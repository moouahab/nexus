import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../application/ai_provider.dart';
import '../../domain/reasoning_models.dart';

final class OllamaProvider implements AiProvider {
  OllamaProvider({
    required Uri baseUri,
    required this.model,
    this.timeout = const Duration(seconds: 120),
    this.maxOutputTokens = 512,
    HttpClient? client,
  }) : baseUri = _validateBaseUri(baseUri),
       _client = client ?? HttpClient();

  final Uri baseUri;
  @override
  final String model;
  final Duration timeout;
  final int maxOutputTokens;
  final HttpClient _client;

  @override
  String get name => 'ollama';

  @override
  bool get isConfigured => model.trim().isNotEmpty;

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _get('/api/version');
      return response.statusCode == HttpStatus.ok;
    } on Object {
      return false;
    }
  }

  @override
  Future<AiGenerationResult> generate(AiGenerationRequest request) async {
    if (!isConfigured) {
      throw const AiProviderException('provider_not_configured');
    }
    late final _HttpResult response;
    try {
      response = await _post('/api/chat', {
        'model': model,
        'stream': false,
        'messages': [
          {
            'role': 'system',
            'content':
                request.systemPrompt ??
                'You are a project assistant. Answer only from supplied evidence.',
          },
          {'role': 'user', 'content': request.prompt},
        ],
        'options': {'temperature': 0.2, 'num_predict': maxOutputTokens},
      });
    } on Object {
      throw const AiProviderException('provider_unavailable');
    }
    if (response.statusCode != HttpStatus.ok) {
      throw const AiProviderException('provider_request_failed');
    }
    late final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const AiProviderException('provider_invalid_response');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const AiProviderException('provider_invalid_response');
    }
    final message = decoded['message'];
    final output = message is Map<String, dynamic> ? message['content'] : null;
    if (output is! String || output.trim().isEmpty) {
      throw const AiProviderException('provider_empty_response');
    }
    return AiGenerationResult(
      provider: name,
      model: model,
      output: output.trim(),
      metrics: ModelCallMetrics(
        inputTokens: _nonNegativeInt(decoded['prompt_eval_count']),
        outputTokens: _nonNegativeInt(decoded['eval_count']),
        totalDurationMs: _nanosecondsToMilliseconds(decoded['total_duration']),
        // Ollama's non-streaming response does not expose true TTFT.
        timeToFirstTokenMs: null,
      ),
    );
  }

  Future<_HttpResult> _get(String path) async {
    final request = await _client
        .getUrl(baseUri.resolve(path))
        .timeout(timeout);
    final response = await request.close().timeout(timeout);
    return _read(response);
  }

  Future<_HttpResult> _post(String path, Map<String, dynamic> body) async {
    final request = await _client
        .postUrl(baseUri.resolve(path))
        .timeout(timeout);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close().timeout(timeout);
    return _read(response);
  }

  Future<_HttpResult> _read(HttpClientResponse response) async {
    final body = await utf8.decoder.bind(response).join().timeout(timeout);
    return _HttpResult(response.statusCode, body);
  }

  static Uri _validateBaseUri(Uri uri) {
    if (!{'http', 'https'}.contains(uri.scheme) || uri.host.isEmpty) {
      throw ArgumentError.value(uri, 'baseUri', 'Expected an HTTP(S) URI.');
    }
    return uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
  }

  static int? _nonNegativeInt(Object? value) =>
      value is int && value >= 0 ? value : null;

  static int? _nanosecondsToMilliseconds(Object? value) =>
      value is int && value >= 0
      ? value ~/ Duration.microsecondsPerMillisecond ~/ 1000
      : null;
}

final class _HttpResult {
  const _HttpResult(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
