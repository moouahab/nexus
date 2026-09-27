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
import 'package:serverpod/serverpod.dart' as _i1;

/// Minimal persistent FutureCall message. The sensitive payload stays server-side.
abstract class AiRunWork
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AiRunWork._({required this.runId});

  factory AiRunWork({required _i1.UuidValue runId}) = _AiRunWorkImpl;

  factory AiRunWork.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiRunWork(
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
    );
  }

  _i1.UuidValue runId;

  /// Returns a shallow copy of this [AiRunWork]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiRunWork copyWith({_i1.UuidValue? runId});
  @override
  Map<String, dynamic> toJson() {
    return {'__className__': 'AiRunWork', 'runId': runId.toJson()};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AiRunWorkImpl extends AiRunWork {
  _AiRunWorkImpl({required _i1.UuidValue runId}) : super._(runId: runId);

  /// Returns a shallow copy of this [AiRunWork]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiRunWork copyWith({_i1.UuidValue? runId}) {
    return AiRunWork(runId: runId ?? this.runId);
  }
}
