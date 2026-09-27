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

/// Many-to-many association recording how evidence relates to a claim.
abstract class AiClaimEvidence implements _i1.SerializableModel {
  AiClaimEvidence._({
    this.id,
    required this.runId,
    required this.claimId,
    required this.evidenceId,
    required this.relation,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AiClaimEvidence({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required _i1.UuidValue claimId,
    required _i1.UuidValue evidenceId,
    required String relation,
    DateTime? createdAt,
  }) = _AiClaimEvidenceImpl;

  factory AiClaimEvidence.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiClaimEvidence(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
      claimId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['claimId'],
      ),
      evidenceId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['evidenceId'],
      ),
      relation: jsonSerialization['relation'] as String,
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

  _i1.UuidValue claimId;

  _i1.UuidValue evidenceId;

  String relation;

  DateTime createdAt;

  /// Returns a shallow copy of this [AiClaimEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiClaimEvidence copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? runId,
    _i1.UuidValue? claimId,
    _i1.UuidValue? evidenceId,
    String? relation,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiClaimEvidence',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'claimId': claimId.toJson(),
      'evidenceId': evidenceId.toJson(),
      'relation': relation,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiClaimEvidenceImpl extends AiClaimEvidence {
  _AiClaimEvidenceImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required _i1.UuidValue claimId,
    required _i1.UuidValue evidenceId,
    required String relation,
    DateTime? createdAt,
  }) : super._(
         id: id,
         runId: runId,
         claimId: claimId,
         evidenceId: evidenceId,
         relation: relation,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AiClaimEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiClaimEvidence copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? runId,
    _i1.UuidValue? claimId,
    _i1.UuidValue? evidenceId,
    String? relation,
    DateTime? createdAt,
  }) {
    return AiClaimEvidence(
      id: id is _i1.UuidValue? ? id : this.id,
      runId: runId ?? this.runId,
      claimId: claimId ?? this.claimId,
      evidenceId: evidenceId ?? this.evidenceId,
      relation: relation ?? this.relation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
