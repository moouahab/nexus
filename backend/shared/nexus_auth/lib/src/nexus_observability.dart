import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart'
    hide LogLevel, Session;
import 'package:serverpod/serverpod.dart';

/// Request correlation, distributed tracing and structured logging for NEXUS
/// HTTP edges.
/// Request bodies, credentials and user identifiers are never logged here.
abstract final class NexusObservability {
  static const requestIdHeader = 'x-request-id';
  static final _validRequestId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]{7,127}$');
  static final Object _requestIdZoneKey = Object();
  static final Random _random = Random.secure();
  static final _propagator =
      OTelAPI.compositePropagator<Map<String, String>, String>([
        W3CTraceContextPropagator(),
        W3CBaggagePropagator(),
      ]);

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
    final incomingHeaders = <String, String>{
      for (final entry in request.headers.entries)
        if (entry.value.isNotEmpty) entry.key.toLowerCase(): entry.value.first,
    };
    final parentContext = _propagator.extract(
      OTel.context(),
      incomingHeaders,
      _MapTextMapGetter(incomingHeaders),
    );
    return runZoned(
      () => parentContext.run(() async {
        final span = OTel.tracer().startSpan(
          'HTTP ${request.method.name.toUpperCase()}',
          kind: SpanKind.server,
          attributes: OTel.attributesFromMap({
            'http.request.method': request.method.name.toUpperCase(),
            'server.address': service,
            'nexus.request.id': requestId,
          }),
        );
        try {
          return await OTel.withSpanAsync(span, () async {
            try {
              final result = await operation();
              watch.stop();
              final statusCode = result is Response ? result.statusCode : null;
              if (statusCode != null) {
                span.setIntAttribute('http.response.status_code', statusCode);
                if (statusCode >= 500) {
                  span.setStatus(SpanStatusCode.Error, 'HTTP $statusCode');
                }
              }
              log(
                session,
                service: service,
                event: 'http_request',
                fields: {
                  'request_id': requestId,
                  'method': request.method.name,
                  'status_code': statusCode,
                  'duration_ms': watch.elapsedMilliseconds,
                },
              );
              return result;
            } catch (_) {
              watch.stop();
              // Never export raw exception messages or stack traces. Provider
              // and validation errors may contain prompts or credentials.
              span.setStatus(SpanStatusCode.Error, 'Unhandled HTTP error');
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
          });
        } finally {
          span.end();
        }
      }),
      zoneValues: {_requestIdZoneKey: requestId},
    );
  }

  static Map<String, List<String>> responseHeaders([
    Map<String, List<String>> headers = const {},
  ]) => {
    ...headers,
    if (currentRequestId case final id?) requestIdHeader: [id],
  };

  static void addOutboundHeaders(HttpHeaders headers) {
    if (currentRequestId case final id?) headers.set(requestIdHeader, id);
    final carrier = <String, String>{};
    _propagator.inject(Context.current, carrier, _MapTextMapSetter(carrier));
    for (final entry in carrier.entries) {
      headers.set(entry.key, entry.value);
    }
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
      if (Context.current.span?.spanContext case final context?
          when context.isValid) ...{
        'trace_id': context.traceId.toString(),
        'span_id': context.spanId.toString(),
      },
      ...sanitizeLogFields(fields),
    }..removeWhere((_, value) => value == null);
    // Do not attach exceptions or stack traces here: exception messages may
    // contain request payloads, credentials or user identifiers.
    session.log(jsonEncode(data), level: level);
  }

  static Map<String, Object?> sanitizeLogFields(Map<String, Object?> fields) =>
      fields.map(
        (key, value) => MapEntry(
          key,
          _sensitiveField.hasMatch(key) ? '[REDACTED]' : _sanitizeValue(value),
        ),
      );

  static final _sensitiveField = RegExp(
    r'(token|authorization|cookie|password|secret|prompt|question|content)',
    caseSensitive: false,
  );

  static Object? _sanitizeValue(Object? value) {
    if (value is Map) {
      return sanitizeLogFields({
        for (final entry in value.entries) entry.key.toString(): entry.value,
      });
    }
    if (value is Iterable) return value.map(_sanitizeValue).toList();
    return value;
  }
}

/// Initializes the process-wide OTLP exporter. Telemetry is deliberately
/// fail-open: an unavailable collector must never prevent an API from booting.
abstract final class NexusTelemetry {
  static Future<void> initialize(String serviceName) async {
    try {
      await OTel.initialize(
        serviceName: serviceName,
        enableMetrics: false,
        enableLogs: false,
        sampler: ParentBasedSampler(TraceIdRatioSampler(1.0)),
      );
    } on Object catch (error) {
      stderr.writeln('OpenTelemetry initialization failed: $error');
    }
  }
}

final class _MapTextMapSetter implements TextMapSetter<String> {
  _MapTextMapSetter(this._carrier);

  final Map<String, String> _carrier;

  @override
  void set(String key, String value) => _carrier[key] = value;
}

final class _MapTextMapGetter implements TextMapGetter<String> {
  _MapTextMapGetter(this._carrier);

  final Map<String, String> _carrier;

  @override
  String? get(String key) => _carrier[key.toLowerCase()];

  @override
  Iterable<String> keys() => _carrier.keys;
}
