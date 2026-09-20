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

abstract class AiCapability
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AiCapability._({
    required this.name,
    required this.status,
    this.reason,
  });

  factory AiCapability({
    required String name,
    required String status,
    String? reason,
  }) = _AiCapabilityImpl;

  factory AiCapability.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiCapability(
      name: jsonSerialization['name'] as String,
      status: jsonSerialization['status'] as String,
      reason: jsonSerialization['reason'] as String?,
    );
  }

  String name;

  String status;

  String? reason;

  /// Returns a shallow copy of this [AiCapability]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiCapability copyWith({
    String? name,
    String? status,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiCapability',
      'name': name,
      'status': status,
      if (reason != null) 'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AiCapability',
      'name': name,
      'status': status,
      if (reason != null) 'reason': reason,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiCapabilityImpl extends AiCapability {
  _AiCapabilityImpl({
    required String name,
    required String status,
    String? reason,
  }) : super._(
         name: name,
         status: status,
         reason: reason,
       );

  /// Returns a shallow copy of this [AiCapability]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiCapability copyWith({
    String? name,
    String? status,
    Object? reason = _Undefined,
  }) {
    return AiCapability(
      name: name ?? this.name,
      status: status ?? this.status,
      reason: reason is String? ? reason : this.reason,
    );
  }
}
