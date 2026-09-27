import 'dart:async';
import 'dart:convert';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

abstract class UserHttpJsonRoute extends Route {
  UserHttpJsonRoute({
    AuthContextResolver userAuth = const AuthContextResolver(),
    AuthContextResolver serviceAuth = const AuthContextResolver(
      audience: 'users-service',
    ),
    super.methods,
  }) : _userAuth = userAuth,
       _serviceAuth = serviceAuth;

  static const maxBodyBytes = 256 * 1024;
  final AuthContextResolver _userAuth;
  final AuthContextResolver _serviceAuth;

  Future<Map<String, dynamic>> execute(Session session, Request request);

  int get successStatusCode => 200;

  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      NexusObservability.observeHttp(
        session,
        request,
        () => handleJsonCall(session, request),
        service: 'users',
      );

  /// Executes the JSON transport mapping without starting observability.
  ///
  /// Kept public so authorization parity tests can exercise the exact REST
  /// status mapping while reusing an endpoint with deterministic test auth.
  Future<Result> handleJsonCall(Session session, Request request) async {
    try {
      _requireAuthenticatedCaller(session);
      return jsonResponse(
        await execute(session, request),
        statusCode: successStatusCode,
      );
    } on NexusAuthException catch (error) {
      final unavailable =
          error.code == NexusAuthExceptionCode.missingAuthSecret;
      return errorResponse(
        unavailable ? 503 : 401,
        unavailable ? 'AUTH_UNAVAILABLE' : 'AUTH_REQUIRED',
      );
    } on NotAuthorizedException catch (error) {
      final unauthenticated =
          error.reason == AuthenticationFailureReason.unauthenticated;
      return errorResponse(
        unauthenticated ? 401 : 403,
        unauthenticated ? 'AUTH_REQUIRED' : 'ACCESS_DENIED',
      );
    } on FormatException catch (error) {
      return errorResponse(400, 'INVALID_REQUEST', message: error.message);
    } on ArgumentError {
      return errorResponse(400, 'VALIDATION_FAILED');
    } on StateError catch (error) {
      final message = error.message.toString();
      if (message == 'User profile not found.') {
        return errorResponse(404, 'RESOURCE_NOT_FOUND');
      }
      if (message == 'User profile already exists.') {
        return errorResponse(409, 'RESOURCE_CONFLICT');
      }
      return errorResponse(409, 'INVALID_STATE');
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
      throw const FormatException('JSON body exceeds 256 KiB.');
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

  String? optionalString(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field "$key" must be a string.');
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

  Map<String, String>? optionalMetadata(
    Map<String, dynamic> body,
    String key,
  ) {
    final value = body[key];
    if (value == null) return null;
    if (value is! Map<String, dynamic> ||
        value.values.any((entry) => entry is! String)) {
      throw FormatException('Field "$key" must be an object of strings.');
    }
    return value.cast<String, String>();
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
