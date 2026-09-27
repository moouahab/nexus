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

/// A structured conclusion produced during a reasoning run.
/// `statement` contains the claim, never the user's original prompt.
abstract class AiClaim implements _i1.SerializableModel {
  AiClaim._({
    this.id,
    required this.runId,
    required this.statement,
    required this.claimType,
    required this.confidence,
    required this.verificationDecision,
    required this.iteration,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AiClaim({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String statement,
    required String claimType,
    required String confidence,
    required String verificationDecision,
    required int iteration,
    DateTime? createdAt,
  }) = _AiClaimImpl;

  factory AiClaim.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiClaim(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
      statement: jsonSerialization['statement'] as String,
      claimType: jsonSerialization['claimType'] as String,
      confidence: jsonSerialization['confidence'] as String,
      verificationDecision: jsonSerialization['verificationDecision'] as String,
      iteration: jsonSerialization['iteration'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue runId;

  String statement;

  String claimType;

  String confidence;

  String verificationDecision;

  int iteration;

  DateTime createdAt;

  /// Returns a shallow copy of this [AiClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiClaim copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? runId,
    String? statement,
    String? claimType,
    String? confidence,
    String? verificationDecision,
    int? iteration,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiClaim',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'statement': statement,
      'claimType': claimType,
      'confidence': confidence,
      'verificationDecision': verificationDecision,
      'iteration': iteration,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiClaimImpl extends AiClaim {
  _AiClaimImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String statement,
    required String claimType,
    required String confidence,
    required String verificationDecision,
    required int iteration,
    DateTime? createdAt,
  }) : super._(
         id: id,
         runId: runId,
         statement: statement,
         claimType: claimType,
         confidence: confidence,
         verificationDecision: verificationDecision,
         iteration: iteration,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AiClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiClaim copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? runId,
    String? statement,
    String? claimType,
    String? confidence,
    String? verificationDecision,
    int? iteration,
    DateTime? createdAt,
  }) {
    return AiClaim(
      id: id is _i1.UuidValue? ? id : this.id,
      runId: runId ?? this.runId,
      statement: statement ?? this.statement,
      claimType: claimType ?? this.claimType,
      confidence: confidence ?? this.confidence,
      verificationDecision: verificationDecision ?? this.verificationDecision,
      iteration: iteration ?? this.iteration,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
