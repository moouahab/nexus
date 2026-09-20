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
import '../../ai/models/ai_run_status.dart' as _i2;

/// Audit-safe run metadata. Prompt and provider credentials are deliberately not stored.
abstract class AiRun implements _i1.SerializableModel {
  AiRun._({
    this.id,
    required this.requestId,
    required this.projectId,
    required this.tenantPartyId,
    this.missionId,
    required this.capability,
    _i2.AiRunStatus? status,
    this.requesterIdentityId,
    this.requesterService,
    this.failureCode,
    this.provider,
    this.model,
    this.outputText,
    this.reasoningLevel,
    this.currentIteration,
    this.maxIterations,
    bool? validated,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.AiRunStatus.queued,
       validated = validated ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory AiRun({
    _i1.UuidValue? id,
    required _i1.UuidValue requestId,
    required _i1.UuidValue projectId,
    required _i1.UuidValue tenantPartyId,
    _i1.UuidValue? missionId,
    required String capability,
    _i2.AiRunStatus? status,
    _i1.UuidValue? requesterIdentityId,
    String? requesterService,
    String? failureCode,
    String? provider,
    String? model,
    String? outputText,
    String? reasoningLevel,
    int? currentIteration,
    int? maxIterations,
    bool? validated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AiRunImpl;

  factory AiRun.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiRun(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      requestId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      tenantPartyId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantPartyId'],
      ),
      missionId: jsonSerialization['missionId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['missionId']),
      capability: jsonSerialization['capability'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.AiRunStatus.fromJson((jsonSerialization['status'] as String)),
      requesterIdentityId: jsonSerialization['requesterIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['requesterIdentityId'],
            ),
      requesterService: jsonSerialization['requesterService'] as String?,
      failureCode: jsonSerialization['failureCode'] as String?,
      provider: jsonSerialization['provider'] as String?,
      model: jsonSerialization['model'] as String?,
      outputText: jsonSerialization['outputText'] as String?,
      reasoningLevel: jsonSerialization['reasoningLevel'] as String?,
      currentIteration: jsonSerialization['currentIteration'] as int?,
      maxIterations: jsonSerialization['maxIterations'] as int?,
      validated: jsonSerialization['validated'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['validated']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue requestId;

  _i1.UuidValue projectId;

  _i1.UuidValue tenantPartyId;

  _i1.UuidValue? missionId;

  String capability;

  _i2.AiRunStatus status;

  _i1.UuidValue? requesterIdentityId;

  String? requesterService;

  String? failureCode;

  String? provider;

  String? model;

  String? outputText;

  String? reasoningLevel;

  int? currentIteration;

  int? maxIterations;

  bool? validated;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [AiRun]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiRun copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? requestId,
    _i1.UuidValue? projectId,
    _i1.UuidValue? tenantPartyId,
    _i1.UuidValue? missionId,
    String? capability,
    _i2.AiRunStatus? status,
    _i1.UuidValue? requesterIdentityId,
    String? requesterService,
    String? failureCode,
    String? provider,
    String? model,
    String? outputText,
    String? reasoningLevel,
    int? currentIteration,
    int? maxIterations,
    bool? validated,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiRun',
      if (id != null) 'id': id?.toJson(),
      'requestId': requestId.toJson(),
      'projectId': projectId.toJson(),
      'tenantPartyId': tenantPartyId.toJson(),
      if (missionId != null) 'missionId': missionId?.toJson(),
      'capability': capability,
      'status': status.toJson(),
      if (requesterIdentityId != null)
        'requesterIdentityId': requesterIdentityId?.toJson(),
      if (requesterService != null) 'requesterService': requesterService,
      if (failureCode != null) 'failureCode': failureCode,
      if (provider != null) 'provider': provider,
      if (model != null) 'model': model,
      if (outputText != null) 'outputText': outputText,
      if (reasoningLevel != null) 'reasoningLevel': reasoningLevel,
      if (currentIteration != null) 'currentIteration': currentIteration,
      if (maxIterations != null) 'maxIterations': maxIterations,
      if (validated != null) 'validated': validated,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiRunImpl extends AiRun {
  _AiRunImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue requestId,
    required _i1.UuidValue projectId,
    required _i1.UuidValue tenantPartyId,
    _i1.UuidValue? missionId,
    required String capability,
    _i2.AiRunStatus? status,
    _i1.UuidValue? requesterIdentityId,
    String? requesterService,
    String? failureCode,
    String? provider,
    String? model,
    String? outputText,
    String? reasoningLevel,
    int? currentIteration,
    int? maxIterations,
    bool? validated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         requestId: requestId,
         projectId: projectId,
         tenantPartyId: tenantPartyId,
         missionId: missionId,
         capability: capability,
         status: status,
         requesterIdentityId: requesterIdentityId,
         requesterService: requesterService,
         failureCode: failureCode,
         provider: provider,
         model: model,
         outputText: outputText,
         reasoningLevel: reasoningLevel,
         currentIteration: currentIteration,
         maxIterations: maxIterations,
         validated: validated,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AiRun]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiRun copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? requestId,
    _i1.UuidValue? projectId,
    _i1.UuidValue? tenantPartyId,
    Object? missionId = _Undefined,
    String? capability,
    _i2.AiRunStatus? status,
    Object? requesterIdentityId = _Undefined,
    Object? requesterService = _Undefined,
    Object? failureCode = _Undefined,
    Object? provider = _Undefined,
    Object? model = _Undefined,
    Object? outputText = _Undefined,
    Object? reasoningLevel = _Undefined,
    Object? currentIteration = _Undefined,
    Object? maxIterations = _Undefined,
    Object? validated = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return AiRun(
      id: id is _i1.UuidValue? ? id : this.id,
      requestId: requestId ?? this.requestId,
      projectId: projectId ?? this.projectId,
      tenantPartyId: tenantPartyId ?? this.tenantPartyId,
      missionId: missionId is _i1.UuidValue? ? missionId : this.missionId,
      capability: capability ?? this.capability,
      status: status ?? this.status,
      requesterIdentityId: requesterIdentityId is _i1.UuidValue?
          ? requesterIdentityId
          : this.requesterIdentityId,
      requesterService: requesterService is String?
          ? requesterService
          : this.requesterService,
      failureCode: failureCode is String? ? failureCode : this.failureCode,
      provider: provider is String? ? provider : this.provider,
      model: model is String? ? model : this.model,
      outputText: outputText is String? ? outputText : this.outputText,
      reasoningLevel: reasoningLevel is String?
          ? reasoningLevel
          : this.reasoningLevel,
      currentIteration: currentIteration is int?
          ? currentIteration
          : this.currentIteration,
      maxIterations: maxIterations is int? ? maxIterations : this.maxIterations,
      validated: validated is bool? ? validated : this.validated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
