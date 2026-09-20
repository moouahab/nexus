/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'ai/models/ai_capability.dart' as _i2;
import 'ai/models/ai_claim.dart' as _i3;
import 'ai/models/ai_claim_evidence.dart' as _i4;
import 'ai/models/ai_evidence.dart' as _i5;
import 'ai/models/ai_gateway_health.dart' as _i6;
import 'ai/models/ai_run.dart' as _i7;
import 'ai/models/ai_run_job_status.dart' as _i8;
import 'ai/models/ai_run_status.dart' as _i9;
import 'package:ai_gateway_client/src/protocol/ai/models/ai_capability.dart'
    as _i10;
export 'ai/models/ai_capability.dart';
export 'ai/models/ai_claim.dart';
export 'ai/models/ai_claim_evidence.dart';
export 'ai/models/ai_evidence.dart';
export 'ai/models/ai_gateway_health.dart';
export 'ai/models/ai_run.dart';
export 'ai/models/ai_run_job_status.dart';
export 'ai/models/ai_run_status.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AiCapability) {
      return _i2.AiCapability.fromJson(data) as T;
    }
    if (t == _i3.AiClaim) {
      return _i3.AiClaim.fromJson(data) as T;
    }
    if (t == _i4.AiClaimEvidence) {
      return _i4.AiClaimEvidence.fromJson(data) as T;
    }
    if (t == _i5.AiEvidence) {
      return _i5.AiEvidence.fromJson(data) as T;
    }
    if (t == _i6.AiGatewayHealth) {
      return _i6.AiGatewayHealth.fromJson(data) as T;
    }
    if (t == _i7.AiRun) {
      return _i7.AiRun.fromJson(data) as T;
    }
    if (t == _i8.AiRunJobStatus) {
      return _i8.AiRunJobStatus.fromJson(data) as T;
    }
    if (t == _i9.AiRunStatus) {
      return _i9.AiRunStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AiCapability?>()) {
      return (data != null ? _i2.AiCapability.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AiClaim?>()) {
      return (data != null ? _i3.AiClaim.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AiClaimEvidence?>()) {
      return (data != null ? _i4.AiClaimEvidence.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AiEvidence?>()) {
      return (data != null ? _i5.AiEvidence.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AiGatewayHealth?>()) {
      return (data != null ? _i6.AiGatewayHealth.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AiRun?>()) {
      return (data != null ? _i7.AiRun.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AiRunJobStatus?>()) {
      return (data != null ? _i8.AiRunJobStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AiRunStatus?>()) {
      return (data != null ? _i9.AiRunStatus.fromJson(data) : null) as T;
    }
    if (t == List<_i10.AiCapability>) {
      return (data as List)
              .map((e) => deserialize<_i10.AiCapability>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AiCapability => 'AiCapability',
      _i3.AiClaim => 'AiClaim',
      _i4.AiClaimEvidence => 'AiClaimEvidence',
      _i5.AiEvidence => 'AiEvidence',
      _i6.AiGatewayHealth => 'AiGatewayHealth',
      _i7.AiRun => 'AiRun',
      _i8.AiRunJobStatus => 'AiRunJobStatus',
      _i9.AiRunStatus => 'AiRunStatus',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('ai_gateway.', '');
    }

    switch (data) {
      case _i2.AiCapability():
        return 'AiCapability';
      case _i3.AiClaim():
        return 'AiClaim';
      case _i4.AiClaimEvidence():
        return 'AiClaimEvidence';
      case _i5.AiEvidence():
        return 'AiEvidence';
      case _i6.AiGatewayHealth():
        return 'AiGatewayHealth';
      case _i7.AiRun():
        return 'AiRun';
      case _i8.AiRunJobStatus():
        return 'AiRunJobStatus';
      case _i9.AiRunStatus():
        return 'AiRunStatus';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AiCapability') {
      return deserialize<_i2.AiCapability>(data['data']);
    }
    if (dataClassName == 'AiClaim') {
      return deserialize<_i3.AiClaim>(data['data']);
    }
    if (dataClassName == 'AiClaimEvidence') {
      return deserialize<_i4.AiClaimEvidence>(data['data']);
    }
    if (dataClassName == 'AiEvidence') {
      return deserialize<_i5.AiEvidence>(data['data']);
    }
    if (dataClassName == 'AiGatewayHealth') {
      return deserialize<_i6.AiGatewayHealth>(data['data']);
    }
    if (dataClassName == 'AiRun') {
      return deserialize<_i7.AiRun>(data['data']);
    }
    if (dataClassName == 'AiRunJobStatus') {
      return deserialize<_i8.AiRunJobStatus>(data['data']);
    }
    if (dataClassName == 'AiRunStatus') {
      return deserialize<_i9.AiRunStatus>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
