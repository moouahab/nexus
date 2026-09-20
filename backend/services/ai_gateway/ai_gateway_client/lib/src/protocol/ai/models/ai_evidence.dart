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

/// Immutable reference to evidence used by a reasoning run.
/// The source payload is not duplicated; `summary` is a bounded normalized view.
abstract class AiEvidence implements _i1.SerializableModel {
  AiEvidence._({
    this.id,
    required this.runId,
    required this.sourceService,
    required this.resourceType,
    required this.resourceId,
    this.summary,
    required this.reliability,
    required this.freshness,
    this.observedAt,
    DateTime? collectedAt,
  }) : collectedAt = collectedAt ?? DateTime.now();

  factory AiEvidence({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String sourceService,
    required String resourceType,
    required String resourceId,
    String? summary,
    required double reliability,
    required double freshness,
    DateTime? observedAt,
    DateTime? collectedAt,
  }) = _AiEvidenceImpl;

  factory AiEvidence.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiEvidence(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
      sourceService: jsonSerialization['sourceService'] as String,
      resourceType: jsonSerialization['resourceType'] as String,
      resourceId: jsonSerialization['resourceId'] as String,
      summary: jsonSerialization['summary'] as String?,
      reliability: (jsonSerialization['reliability'] as num).toDouble(),
      freshness: (jsonSerialization['freshness'] as num).toDouble(),
      observedAt: jsonSerialization['observedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['observedAt']),
      collectedAt: jsonSerialization['collectedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['collectedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue runId;

  String sourceService;

  String resourceType;

  String resourceId;

  String? summary;

  double reliability;

  double freshness;

  DateTime? observedAt;

  DateTime collectedAt;

  /// Returns a shallow copy of this [AiEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiEvidence copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? runId,
    String? sourceService,
    String? resourceType,
    String? resourceId,
    String? summary,
    double? reliability,
    double? freshness,
    DateTime? observedAt,
    DateTime? collectedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiEvidence',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'sourceService': sourceService,
      'resourceType': resourceType,
      'resourceId': resourceId,
      if (summary != null) 'summary': summary,
      'reliability': reliability,
      'freshness': freshness,
      if (observedAt != null) 'observedAt': observedAt?.toJson(),
      'collectedAt': collectedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiEvidenceImpl extends AiEvidence {
  _AiEvidenceImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String sourceService,
    required String resourceType,
    required String resourceId,
    String? summary,
    required double reliability,
    required double freshness,
    DateTime? observedAt,
    DateTime? collectedAt,
  }) : super._(
         id: id,
         runId: runId,
         sourceService: sourceService,
         resourceType: resourceType,
         resourceId: resourceId,
         summary: summary,
         reliability: reliability,
         freshness: freshness,
         observedAt: observedAt,
         collectedAt: collectedAt,
       );

  /// Returns a shallow copy of this [AiEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiEvidence copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? runId,
    String? sourceService,
    String? resourceType,
    String? resourceId,
    Object? summary = _Undefined,
    double? reliability,
    double? freshness,
    Object? observedAt = _Undefined,
    DateTime? collectedAt,
  }) {
    return AiEvidence(
      id: id is _i1.UuidValue? ? id : this.id,
      runId: runId ?? this.runId,
      sourceService: sourceService ?? this.sourceService,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      summary: summary is String? ? summary : this.summary,
      reliability: reliability ?? this.reliability,
      freshness: freshness ?? this.freshness,
      observedAt: observedAt is DateTime? ? observedAt : this.observedAt,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }
}
