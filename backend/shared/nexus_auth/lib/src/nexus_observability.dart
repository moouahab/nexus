import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

/// Dependency-free correlation and structured logging for NEXUS HTTP edges.
/// Request bodies, credentials and user identifiers are never logged here.
abstract final class NexusObservability {
  static const requestIdHeader = 'x-request-id';
  static final _validRequestId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{7,127}$');
  static final Object _requestIdZoneKey = Object();
  static final Random _random = Random.secure();

  static String? get currentRequestId =>
      Zone.current[_requestIdZoneKey] as String?;

  static String requestIdFrom(Request request) {
    String? candidate;
    for (final entry in request.headers.entries) {
      if (entry.key.toLowerCase() == requestIdHeader &&
          entry.value.isNotEmpty) {
        candidate = entry.value.first.trim();
        break;
      }
    }
    return normalizeRequestId(candidate);
  }

  static String normalizeRequestId(String? candidate) {
    if (candidate != null && _validRequestId.hasMatch(candidate))
      return candidate;
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static Future<T> runWithRequestId<T>(
    String requestId,
    Future<T> Function() operation,
  ) => runZoned(
    operation,
    zoneValues: {_requestIdZoneKey: normalizeRequestId(requestId)},
  );

  static Future<Result> observeHttp(
    Session session,
    Request request,
    FutureOr<Result> Function() operation, {
    required String service,
  }) async {
    final requestId = requestIdFrom(request);
    final watch = Stopwatch()..start();
    return runZoned(() async {
      try {
        final result = await operation();
        watch.stop();
        log(
          session,
          service: service,
          event: 'http_request',
          fields: {
            'request_id': requestId,
            'method': request.method.name,
            'status_code': result is Response ? result.statusCode : null,
            'duration_ms': watch.elapsedMilliseconds,
          },
        );
        return result;
      } catch (_) {
        watch.stop();
        log(
          session,
          service: service,
          event: 'http_request',
          level: LogLevel.error,
          fields: {
            'request_id': requestId,
            'method': request.method.name,
            'status_code': 500,
            'duration_ms': watch.elapsedMilliseconds,
            'outcome': 'unhandled_error',
          },
        );
        rethrow;
      }
    }, zoneValues: {_requestIdZoneKey: requestId});
  }

  static Map<String, List<String>> responseHeaders([
    Map<String, List<String>> headers = const {},
  ]) => {
    ...headers,
    if (currentRequestId case final id?) requestIdHeader: [id],
  };

  static void addOutboundHeaders(HttpHeaders headers) {
    if (currentRequestId case final id?) headers.set(requestIdHeader, id);
  }

  static void log(
    Session session, {
    required String service,
    required String event,
    Map<String, Object?> fields = const {},
    LogLevel level = LogLevel.info,
  }) {
    final data = <String, Object?>{
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'service': service,
      'event': event,
      if (currentRequestId case final id?) 'request_id': id,
      ...fields,
    }..removeWhere((_, value) => value == null);
    // Do not attach exceptions or stack traces here: exception messages may
    // contain request payloads, credentials or user identifiers.
    session.log(jsonEncode(data), level: level);
  }
}
