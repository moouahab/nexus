import 'dart:async';
import 'dart:convert';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../project_endpoint.dart';

abstract class ProjectHttpJsonRoute extends Route {
  ProjectHttpJsonRoute({
    super.methods,
    super.path,
    ProjectEndpoint? projects,
    AuthContextResolver userAuth = const AuthContextResolver(),
    AuthContextResolver serviceAuth = const AuthContextResolver(
      audience: 'projects-service',
    ),
  }) : projects = projects ?? ProjectEndpoint(),
       _userAuth = userAuth,
       _serviceAuth = serviceAuth;

  static const maxBodyBytes = 1024 * 1024;
  final AuthContextResolver _userAuth;
  final AuthContextResolver _serviceAuth;
  final ProjectEndpoint projects;

  Future<Map<String, dynamic>> execute(Session session, Request request);
  int get successStatusCode => 200;

  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      NexusObservability.observeHttp(
        session,
        request,
        () => handleJsonCall(session, request),
        service: 'projects',
      );

  /// Executes authentication, authorization and HTTP error mapping.
  ///
  /// Exposed separately so transport-parity tests do not need to initialize a
  /// global telemetry exporter merely to exercise the route contract.
  Future<Result> handleJsonCall(Session session, Request request) async {
    try {
      _requireAuthenticatedCaller(session);
      return jsonResponse(
        await execute(session, request),
        statusCode: successStatusCode,
      );
    } on NexusAuthException {
      return errorResponse(401, 'AUTH_REQUIRED');
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
      final message = error.message.toString().toLowerCase();
      if (message.contains('not found')) {
        return errorResponse(404, 'RESOURCE_NOT_FOUND');
      }
      if (message.contains('already') || message.contains('cannot')) {
        return errorResponse(409, 'CONFLICT');
      }
      return errorResponse(400, 'VALIDATION_FAILED');
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

  AuthContext requireUserContext(Session session) =>
      _userAuth.requireContext(session);

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

  UuidValue pathUuid(Request request, Symbol parameter) {
    final value = request.pathParameters.raw[parameter];
    if (value == null) throw const FormatException('Missing path identifier.');
    return parseUuid(value, parameter.toString());
  }

  UuidValue parseUuid(String value, String field) {
    try {
      return UuidValue.withValidation(value);
    } on Object {
      throw FormatException('Field "$field" must be a UUID.');
    }
  }

  T enumValue<T extends Enum>(List<T> values, Object? value, String field) {
    if (value is! String) throw FormatException('Field "$field" is required.');
    return values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => throw FormatException('Field "$field" is invalid.'),
    );
  }

  List<String>? optionalStringList(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value == null) return null;
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Field "$key" must be an array of strings.');
    }
    return value.cast<String>();
  }

  Map<String, String>? optionalStringMap(
    Map<String, dynamic> body,
    String key,
  ) {
    final value = body[key];
    if (value == null) return null;
    if (value is! Map ||
        value.entries.any(
          (entry) => entry.key is! String || entry.value is! String,
        )) {
      throw FormatException('Field "$key" must be a string map.');
    }
    return value.cast<String, String>();
  }

  Response errorResponse(int status, String code, {String? message}) =>
      jsonResponse({
        'error': {'code': code, 'message': ?message},
      }, statusCode: status);

  Response jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) =>
      Response(
        statusCode,
        body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
        headers: Headers.fromMap({
          'cache-control': ['no-store'],
          'x-content-type-options': ['nosniff'],
          ...NexusObservability.responseHeaders(),
        }),
      );
}
