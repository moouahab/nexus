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
import '../../projects/models/project.dart' as _i2;
import 'package:projects_client/src/protocol/protocol.dart' as _i3;

/// Archive lifecycle record for a project.
abstract class ProjectArchiveEntry implements _i1.SerializableModel {
  ProjectArchiveEntry._({
    this.id,
    required this.projectId,
    this.project,
    this.archivePath,
    this.reason,
    this.archivedByIdentityId,
    DateTime? archivedAt,
    this.restoredAt,
    this.restoredByIdentityId,
    this.metadata,
  }) : archivedAt = archivedAt ?? DateTime.now();

  factory ProjectArchiveEntry({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    String? archivePath,
    String? reason,
    _i1.UuidValue? archivedByIdentityId,
    DateTime? archivedAt,
    DateTime? restoredAt,
    _i1.UuidValue? restoredByIdentityId,
    Map<String, String>? metadata,
  }) = _ProjectArchiveEntryImpl;

  factory ProjectArchiveEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectArchiveEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      project: jsonSerialization['project'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Project>(
              jsonSerialization['project'],
            ),
      archivePath: jsonSerialization['archivePath'] as String?,
      reason: jsonSerialization['reason'] as String?,
      archivedByIdentityId: jsonSerialization['archivedByIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['archivedByIdentityId'],
            ),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      restoredAt: jsonSerialization['restoredAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['restoredAt']),
      restoredByIdentityId: jsonSerialization['restoredByIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['restoredByIdentityId'],
            ),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _i3.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['metadata'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue projectId;

  _i2.Project? project;

  String? archivePath;

  String? reason;

  /// Identity service UUID of the actor that archived the project.
  _i1.UuidValue? archivedByIdentityId;

  DateTime archivedAt;

  DateTime? restoredAt;

  _i1.UuidValue? restoredByIdentityId;

  Map<String, String>? metadata;

  /// Returns a shallow copy of this [ProjectArchiveEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectArchiveEntry copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i2.Project? project,
    String? archivePath,
    String? reason,
    _i1.UuidValue? archivedByIdentityId,
    DateTime? archivedAt,
    DateTime? restoredAt,
    _i1.UuidValue? restoredByIdentityId,
    Map<String, String>? metadata,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectArchiveEntry',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      if (archivePath != null) 'archivePath': archivePath,
      if (reason != null) 'reason': reason,
      if (archivedByIdentityId != null)
        'archivedByIdentityId': archivedByIdentityId?.toJson(),
      'archivedAt': archivedAt.toJson(),
      if (restoredAt != null) 'restoredAt': restoredAt?.toJson(),
      if (restoredByIdentityId != null)
        'restoredByIdentityId': restoredByIdentityId?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectArchiveEntryImpl extends ProjectArchiveEntry {
  _ProjectArchiveEntryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    String? archivePath,
    String? reason,
    _i1.UuidValue? archivedByIdentityId,
    DateTime? archivedAt,
    DateTime? restoredAt,
    _i1.UuidValue? restoredByIdentityId,
    Map<String, String>? metadata,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         archivePath: archivePath,
         reason: reason,
         archivedByIdentityId: archivedByIdentityId,
         archivedAt: archivedAt,
         restoredAt: restoredAt,
         restoredByIdentityId: restoredByIdentityId,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [ProjectArchiveEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectArchiveEntry copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    Object? archivePath = _Undefined,
    Object? reason = _Undefined,
    Object? archivedByIdentityId = _Undefined,
    DateTime? archivedAt,
    Object? restoredAt = _Undefined,
    Object? restoredByIdentityId = _Undefined,
    Object? metadata = _Undefined,
  }) {
    return ProjectArchiveEntry(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i2.Project? ? project : this.project?.copyWith(),
      archivePath: archivePath is String? ? archivePath : this.archivePath,
      reason: reason is String? ? reason : this.reason,
      archivedByIdentityId: archivedByIdentityId is _i1.UuidValue?
          ? archivedByIdentityId
          : this.archivedByIdentityId,
      archivedAt: archivedAt ?? this.archivedAt,
      restoredAt: restoredAt is DateTime? ? restoredAt : this.restoredAt,
      restoredByIdentityId: restoredByIdentityId is _i1.UuidValue?
          ? restoredByIdentityId
          : this.restoredByIdentityId,
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
    );
  }
}
