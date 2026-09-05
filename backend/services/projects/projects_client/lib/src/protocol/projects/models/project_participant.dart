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
import '../../projects/models/project_participant_status.dart' as _i2;
import '../../projects/models/project.dart' as _i3;
import '../../projects/models/project_participant_role.dart' as _i4;
import 'package:projects_client/src/protocol/protocol.dart' as _i5;

/// Human or organization attached to a project.
abstract class ProjectParticipant implements _i1.SerializableModel {
  ProjectParticipant._({
    this.id,
    required this.projectId,
    this.project,
    required this.role,
    _i2.ProjectParticipantStatus? status,
    this.identityId,
    this.externalId,
    this.displayName,
    this.organizationName,
    this.email,
    this.phone,
    this.notes,
    bool? isPrimary,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.ProjectParticipantStatus.active,
       isPrimary = isPrimary ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory ProjectParticipant({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectParticipantRole role,
    _i2.ProjectParticipantStatus? status,
    _i1.UuidValue? identityId,
    String? externalId,
    String? displayName,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    bool? isPrimary,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectParticipantImpl;

  factory ProjectParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectParticipant(
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
      role: _i4.ProjectParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.ProjectParticipantStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      identityId: jsonSerialization['identityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['identityId'],
            ),
      externalId: jsonSerialization['externalId'] as String?,
      displayName: jsonSerialization['displayName'] as String?,
      organizationName: jsonSerialization['organizationName'] as String?,
      email: jsonSerialization['email'] as String?,
      phone: jsonSerialization['phone'] as String?,
      notes: jsonSerialization['notes'] as String?,
      isPrimary: jsonSerialization['isPrimary'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isPrimary']),
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

  /// Role in the project registry, not a permission model by itself.
  _i4.ProjectParticipantRole role;

  _i2.ProjectParticipantStatus status;

  /// Identity service UUID for Nexus-side users when available.
  _i1.UuidValue? identityId;

  /// External CRM/customer/contact id when this participant comes from another system.
  String? externalId;

  String? displayName;

  String? organizationName;

  String? email;

  String? phone;

  String? notes;

  /// Marks the main client or main client referent for quick lookup.
  bool isPrimary;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [ProjectParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectParticipant copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i3.Project? project,
    _i4.ProjectParticipantRole? role,
    _i2.ProjectParticipantStatus? status,
    _i1.UuidValue? identityId,
    String? externalId,
    String? displayName,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    bool? isPrimary,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectParticipant',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      'role': role.toJson(),
      'status': status.toJson(),
      if (identityId != null) 'identityId': identityId?.toJson(),
      if (externalId != null) 'externalId': externalId,
      if (displayName != null) 'displayName': displayName,
      if (organizationName != null) 'organizationName': organizationName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      'isPrimary': isPrimary,
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

class _ProjectParticipantImpl extends ProjectParticipant {
  _ProjectParticipantImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectParticipantRole role,
    _i2.ProjectParticipantStatus? status,
    _i1.UuidValue? identityId,
    String? externalId,
    String? displayName,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    bool? isPrimary,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         role: role,
         status: status,
         identityId: identityId,
         externalId: externalId,
         displayName: displayName,
         organizationName: organizationName,
         email: email,
         phone: phone,
         notes: notes,
         isPrimary: isPrimary,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ProjectParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectParticipant copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    _i4.ProjectParticipantRole? role,
    _i2.ProjectParticipantStatus? status,
    Object? identityId = _Undefined,
    Object? externalId = _Undefined,
    Object? displayName = _Undefined,
    Object? organizationName = _Undefined,
    Object? email = _Undefined,
    Object? phone = _Undefined,
    Object? notes = _Undefined,
    bool? isPrimary,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return ProjectParticipant(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i3.Project? ? project : this.project?.copyWith(),
      role: role ?? this.role,
      status: status ?? this.status,
      identityId: identityId is _i1.UuidValue? ? identityId : this.identityId,
      externalId: externalId is String? ? externalId : this.externalId,
      displayName: displayName is String? ? displayName : this.displayName,
      organizationName: organizationName is String?
          ? organizationName
          : this.organizationName,
      email: email is String? ? email : this.email,
      phone: phone is String? ? phone : this.phone,
      notes: notes is String? ? notes : this.notes,
      isPrimary: isPrimary ?? this.isPrimary,
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
