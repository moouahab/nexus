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

abstract class AiGatewayHealth implements _i1.SerializableModel {
  AiGatewayHealth._({
    required this.service,
    required this.status,
  });

  factory AiGatewayHealth({
    required String service,
    required String status,
  }) = _AiGatewayHealthImpl;

  factory AiGatewayHealth.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiGatewayHealth(
      service: jsonSerialization['service'] as String,
      status: jsonSerialization['status'] as String,
    );
  }

  String service;

  String status;

  /// Returns a shallow copy of this [AiGatewayHealth]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiGatewayHealth copyWith({
    String? service,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiGatewayHealth',
      'service': service,
      'status': status,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AiGatewayHealthImpl extends AiGatewayHealth {
  _AiGatewayHealthImpl({
    required String service,
    required String status,
  }) : super._(
         service: service,
         status: status,
       );

  /// Returns a shallow copy of this [AiGatewayHealth]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiGatewayHealth copyWith({
    String? service,
    String? status,
  }) {
    return AiGatewayHealth(
      service: service ?? this.service,
      status: status ?? this.status,
    );
  }
}
