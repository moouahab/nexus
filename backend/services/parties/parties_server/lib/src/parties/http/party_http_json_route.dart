import 'dart:async';
import 'dart:convert';

import 'package:nexus_auth/nexus_auth.dart';
import 'package:serverpod/serverpod.dart';

import '../application/party_authorization.dart';
import '../application/party_service.dart';

abstract class PartyHttpJsonRoute extends Route {
  PartyHttpJsonRoute({
    PartyService? parties,
    PartyAuthorization? authorization,
    super.methods,
  }) : parties = parties ?? const PartyService(),
       authorization = authorization ?? const PartyAuthorization();

  static const maxBodyBytes = 1024 * 1024;
  final PartyService parties;
  final PartyAuthorization authorization;

  Future<Map<String, dynamic>> execute(Session session, Request request);
  int get successStatusCode => 200;

  @override
  FutureOr<Result> handleCall(Session session, Request request) =>
      NexusObservability.observeHttp(
        session,
        request,
        () => _handleCall(session, request),
        service: 'parties',
      );

  Future<Result> _handleCall(Session session, Request request) async {
    try {
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
    } on FormatException catch (error) {
      return errorResponse(400, 'INVALID_REQUEST', message: error.message);
    } on ArgumentError {
      return errorResponse(400, 'VALIDATION_FAILED');
    } on StateError catch (error) {
      return errorResponse(
        error.message == 'Party not found.' ? 404 : 409,
        error.message == 'Party not found.'
            ? 'RESOURCE_NOT_FOUND'
            : 'RESOURCE_CONFLICT',
      );
    } on Object {
      return errorResponse(500, 'INTERNAL_ERROR');
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

  String requiredString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Field "$field" must be a non-empty string.');
    }
    return value;
  }

  String? optionalString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field "$field" must be a string.');
    }
    return value;
  }

  UuidValue requiredUuid(Map<String, dynamic> json, String field) =>
      parseUuid(requiredString(json, field), field);

  UuidValue? optionalUuid(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Field "$field" must be a UUID.');
    }
    return parseUuid(value, field);
  }

  UuidValue parseUuid(String value, String field) {
    try {
      return UuidValue.withValidation(value);
    } on Object {
      throw FormatException('Field "$field" must be a UUID.');
    }
  }

  T parseEnum<T extends Enum>(String value, List<T> values, String field) {
    return values.cast<T?>().firstWhere(
          (item) => item?.name == value,
          orElse: () => null,
        ) ??
        (throw FormatException('Field "$field" has an invalid value.'));
  }

  Map<String, String>? optionalMetadata(Map<String, dynamic> json) {
    final value = json['metadata'];
    if (value == null) return null;
    if (value is! Map ||
        value.keys.any((key) => key is! String) ||
        value.values.any((item) => item is! String)) {
      throw const FormatException('Field "metadata" must be a string map.');
    }
    return Map<String, String>.from(value);
  }

  bool optionalBool(Map<String, dynamic> json, String field, bool fallback) {
    final value = json[field];
    if (value == null) return fallback;
    if (value is! bool) {
      throw FormatException('Field "$field" must be a boolean.');
    }
    return value;
  }

  Response errorResponse(int status, String code, {String? message}) =>
      jsonResponse({
        'error': {'code': code, 'message': ?message},
      }, statusCode: status);

  Response jsonResponse(Map<String, dynamic> json, {int statusCode = 200}) =>
      Response(
        statusCode,
        body: Body.fromString(jsonEncode(json), mimeType: MimeType.json),
        headers: Headers.fromMap({
          'cache-control': ['no-store'],
          ...NexusObservability.responseHeaders(),
        }),
      );
}
