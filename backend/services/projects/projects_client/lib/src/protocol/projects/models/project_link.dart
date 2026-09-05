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
import '../../projects/models/project_link_status.dart' as _i2;
import '../../projects/models/project.dart' as _i3;
import '../../projects/models/project_link_kind.dart' as _i4;
import 'package:projects_client/src/protocol/protocol.dart' as _i5;

/// Lightweight reference from a project to another Nexus resource.
abstract class ProjectLink implements _i1.SerializableModel {
  ProjectLink._({
    this.id,
    required this.projectId,
    this.project,
    required this.kind,
    required this.service,
    required this.externalId,
    this.label,
    this.uri,
    _i2.ProjectLinkStatus? status,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.ProjectLinkStatus.active,
       createdAt = createdAt ?? DateTime.now();

  factory ProjectLink({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectLinkKind kind,
    required String service,
    required String externalId,
    String? label,
    String? uri,
    _i2.ProjectLinkStatus? status,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectLinkImpl;

  factory ProjectLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectLink(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      project: jsonSerialization['project'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.Project>(
              jsonSerialization['project'],
            ),
      kind: _i4.ProjectLinkKind.fromJson((jsonSerialization['kind'] as String)),
      service: jsonSerialization['service'] as String,
      externalId: jsonSerialization['externalId'] as String,
      label: jsonSerialization['label'] as String?,
      uri: jsonSerialization['uri'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.ProjectLinkStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _i5.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['metadata'],
            ),
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

  _i1.UuidValue projectId;

  _i3.Project? project;

  _i4.ProjectLinkKind kind;

  /// Owning service name, for example missions, labs, data, documents, history.
  String service;

  /// External resource id managed by the owning service.
  String externalId;

  String? label;

  String? uri;

  _i2.ProjectLinkStatus status;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [ProjectLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectLink copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i3.Project? project,
    _i4.ProjectLinkKind? kind,
    String? service,
    String? externalId,
    String? label,
    String? uri,
    _i2.ProjectLinkStatus? status,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectLink',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      'kind': kind.toJson(),
      'service': service,
      'externalId': externalId,
      if (label != null) 'label': label,
      if (uri != null) 'uri': uri,
      'status': status.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
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

class _ProjectLinkImpl extends ProjectLink {
  _ProjectLinkImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectLinkKind kind,
    required String service,
    required String externalId,
    String? label,
    String? uri,
    _i2.ProjectLinkStatus? status,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         kind: kind,
         service: service,
         externalId: externalId,
         label: label,
         uri: uri,
         status: status,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ProjectLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectLink copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    _i4.ProjectLinkKind? kind,
    String? service,
    String? externalId,
    Object? label = _Undefined,
    Object? uri = _Undefined,
    _i2.ProjectLinkStatus? status,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return ProjectLink(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i3.Project? ? project : this.project?.copyWith(),
      kind: kind ?? this.kind,
      service: service ?? this.service,
      externalId: externalId ?? this.externalId,
      label: label is String? ? label : this.label,
      uri: uri is String? ? uri : this.uri,
      status: status ?? this.status,
      metadata: metadata is Map<String, String>?
          ? metadata
          : this.metadata?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
