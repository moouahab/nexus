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
import '../../projects/models/project_status.dart' as _i2;
import '../../projects/models/project_visibility.dart' as _i3;
import 'package:projects_client/src/protocol/protocol.dart' as _i4;

/// Registry entry for one Nexus workspace.
abstract class Project implements _i1.SerializableModel {
  Project._({
    this.id,
    required this.slug,
    required this.name,
    this.summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    this.tenantPartyId,
    this.ownerIdentityId,
    this.workspacePath,
    this.archivePath,
    this.tags,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
    this.archivedAt,
  }) : status = status ?? _i2.ProjectStatus.active,
       visibility = visibility ?? _i3.ProjectVisibility.private,
       createdAt = createdAt ?? DateTime.now();

  factory Project({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    _i1.UuidValue? tenantPartyId,
    _i1.UuidValue? ownerIdentityId,
    String? workspacePath,
    String? archivePath,
    List<String>? tags,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      slug: jsonSerialization['slug'] as String,
      name: jsonSerialization['name'] as String,
      summary: jsonSerialization['summary'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.ProjectStatus.fromJson((jsonSerialization['status'] as String)),
      visibility: jsonSerialization['visibility'] == null
          ? null
          : _i3.ProjectVisibility.fromJson(
              (jsonSerialization['visibility'] as String),
            ),
      tenantPartyId: jsonSerialization['tenantPartyId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['tenantPartyId'],
            ),
      ownerIdentityId: jsonSerialization['ownerIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['ownerIdentityId'],
            ),
      workspacePath: jsonSerialization['workspacePath'] as String?,
      archivePath: jsonSerialization['archivePath'] as String?,
      tags: jsonSerialization['tags'] == null
          ? null
          : _i4.Protocol().deserialize<List<String>>(jsonSerialization['tags']),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _i4.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['metadata'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  /// Stable human-readable key used in URLs and filesystem integrations.
  String slug;

  /// Display name shown in clients.
  String name;

  /// Short registry description. Domain-specific documents stay outside this service.
  String? summary;

  _i2.ProjectStatus status;

  _i3.ProjectVisibility visibility;

  /// Party service UUID owning this workspace tenant boundary.
  _i1.UuidValue? tenantPartyId;

  /// Identity service UUID of the owner, kept as an external reference.
  _i1.UuidValue? ownerIdentityId;

  /// Optional local/source workspace path for filesystem-backed projects.
  String? workspacePath;

  /// Optional archive location when the project is archived.
  String? archivePath;

  List<String>? tags;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  DateTime? archivedAt;

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Project copyWith({
    _i1.UuidValue? id,
    String? slug,
    String? name,
    String? summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    _i1.UuidValue? tenantPartyId,
    _i1.UuidValue? ownerIdentityId,
    String? workspacePath,
    String? archivePath,
    List<String>? tags,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Project',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (summary != null) 'summary': summary,
      'status': status.toJson(),
      'visibility': visibility.toJson(),
      if (tenantPartyId != null) 'tenantPartyId': tenantPartyId?.toJson(),
      if (ownerIdentityId != null) 'ownerIdentityId': ownerIdentityId?.toJson(),
      if (workspacePath != null) 'workspacePath': workspacePath,
      if (archivePath != null) 'archivePath': archivePath,
      if (tags != null) 'tags': tags?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectImpl extends Project {
  _ProjectImpl({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    _i1.UuidValue? tenantPartyId,
    _i1.UuidValue? ownerIdentityId,
    String? workspacePath,
    String? archivePath,
    List<String>? tags,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) : super._(
         id: id,
         slug: slug,
         name: name,
         summary: summary,
         status: status,
         visibility: visibility,
         tenantPartyId: tenantPartyId,
         ownerIdentityId: ownerIdentityId,
         workspacePath: workspacePath,
         archivePath: archivePath,
         tags: tags,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
         archivedAt: archivedAt,
       );

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Project copyWith({
    Object? id = _Undefined,
    String? slug,
    String? name,
    Object? summary = _Undefined,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    Object? tenantPartyId = _Undefined,
    Object? ownerIdentityId = _Undefined,
    Object? workspacePath = _Undefined,
    Object? archivePath = _Undefined,
    Object? tags = _Undefined,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
    Object? archivedAt = _Undefined,
  }) {
    return Project(
      id: id is _i1.UuidValue? ? id : this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      summary: summary is String? ? summary : this.summary,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      tenantPartyId: tenantPartyId is _i1.UuidValue?
          ? tenantPartyId
          : this.tenantPartyId,
      ownerIdentityId: ownerIdentityId is _i1.UuidValue?
          ? ownerIdentityId
          : this.ownerIdentityId,
      workspacePath: workspacePath is String?
          ? workspacePath
          : this.workspacePath,
      archivePath: archivePath is String? ? archivePath : this.archivePath,
      tags: tags is List<String>? ? tags : this.tags?.map((e0) => e0).toList(),
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
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
    );
  }
}
