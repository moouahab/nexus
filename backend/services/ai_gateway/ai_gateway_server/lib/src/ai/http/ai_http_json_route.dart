import 'dart:async';
import 'dart:convert';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../application/ai_gateway_application.dart';
import '../application/ai_provider.dart';

abstract class AiHttpJsonRoute extends Route {
  AiHttpJsonRoute({required this.application, super.methods, super.path});

  static const maxBodyBytes = 1024 * 1024;
  static const _userAuth = AuthContextResolver();
  static const _serviceAuth = AuthContextResolver(audience: 'ai-gateway');
  final AiGatewayApplication application;

  Future<Map<String, dynamic>> execute(Session session, Request request);

  int get successStatusCode => 200;

  bool get requiresAuthentication => true;

  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      NexusObservability.observeHttp(
        session,
        request,
        () => _handleCall(session, request),
        service: 'ai-gateway',
      );

  Future<Result> _handleCall(Session session, Request request) async {
    try {
      if (requiresAuthentication) _requireAuthenticatedCaller(session);
      return jsonResponse(
        await execute(session, request),
        statusCode: successStatusCode,
      );
    } on NexusAuthException catch (error) {
      final status = error.code == NexusAuthExceptionCode.missingAuthSecret
          ? 503
          : 401;
      return errorResponse(
        status,
        status == 503 ? 'AUTH_UNAVAILABLE' : 'AUTH_REQUIRED',
      );
    } on FormatException catch (error) {
      return errorResponse(400, 'INVALID_REQUEST', message: error.message);
    } on ArgumentError {
      return errorResponse(400, 'VALIDATION_FAILED');
    } on AiProviderException {
      return errorResponse(503, 'AI_PROVIDER_UNAVAILABLE');
    } on StateError catch (error) {
      final message = error.message.toString();
      if (message == 'AI run not found.') {
        return errorResponse(404, 'RESOURCE_NOT_FOUND');
      }
      if (message.startsWith('AI run cannot be cancelled')) {
        return errorResponse(409, 'INVALID_RUN_STATE');
      }
      return errorResponse(403, 'ACCESS_DENIED');
    } on Object {
      return errorResponse(500, 'INTERNAL_ERROR');
    }
  }

  void _requireAuthenticatedCaller(Session session) {
    try {
      _userAuth.requireContext(session);
    } on NexusAuthException catch (error) {
      if (error.code != NexusAuthExceptionCode.invalidAccessToken) rethrow;
      _serviceAuth.requireServiceContext(session);
    }
  }

  Future<Map<String, dynamic>> readJsonObject(Request request) async {
    final raw = await request.readAsString();
    if (utf8.encode(raw).length > maxBodyBytes) {
      throw const FormatException('JSON body exceeds 1 MiB.');
    }
    if (raw.isEmpty) throw const FormatException('JSON body is required.');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return decoded;
  }

  String requiredString(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Field "$key" must be a non-empty string.');
    }
    return value;
  }

  UuidValue requiredUuid(Map<String, dynamic> body, String key) =>
      parseUuid(requiredString(body, key), key);

  UuidValue? optionalUuid(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('Field "$key" must be a UUID.');
    return parseUuid(value, key);
  }

  UuidValue parseUuid(String value, String key) {
    try {
      return UuidValue.withValidation(value);
    } on Object {
      throw FormatException('Field "$key" must be a UUID.');
    }
  }

  List<String> stringList(
    Map<String, dynamic> body,
    String key, {
    bool required = false,
  }) {
    final value = body[key];
    if (value == null && !required) return const [];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Field "$key" must be an array of strings.');
    }
    return List<String>.unmodifiable(value.cast<String>());
  }

  Response errorResponse(int status, String code, {String? message}) =>
      jsonResponse({
        'error': {'code': code, 'message': ?message},
      }, statusCode: status);

  Response jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
      headers: Headers.fromMap({
        'cache-control': ['no-store'],
        ...NexusObservability.responseHeaders(),
      }),
    );
  }
}
