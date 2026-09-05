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
import '../../projects/models/project_event_kind.dart' as _i3;
import '../../projects/models/project_link_kind.dart' as _i4;
import 'package:projects_client/src/protocol/protocol.dart' as _i5;

/// Timeline event for project registry activity.
abstract class ProjectEvent implements _i1.SerializableModel {
  ProjectEvent._({
    this.id,
    required this.projectId,
    this.project,
    required this.kind,
    this.message,
    this.actorIdentityId,
    this.resourceKind,
    this.resourceService,
    this.resourceExternalId,
    this.payload,
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  factory ProjectEvent({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    required _i3.ProjectEventKind kind,
    String? message,
    _i1.UuidValue? actorIdentityId,
    _i4.ProjectLinkKind? resourceKind,
    String? resourceService,
    String? resourceExternalId,
    Map<String, String>? payload,
    DateTime? occurredAt,
  }) = _ProjectEventImpl;

  factory ProjectEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      project: jsonSerialization['project'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Project>(
              jsonSerialization['project'],
            ),
      kind: _i3.ProjectEventKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      message: jsonSerialization['message'] as String?,
      actorIdentityId: jsonSerialization['actorIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['actorIdentityId'],
            ),
      resourceKind: jsonSerialization['resourceKind'] == null
          ? null
          : _i4.ProjectLinkKind.fromJson(
              (jsonSerialization['resourceKind'] as String),
            ),
      resourceService: jsonSerialization['resourceService'] as String?,
      resourceExternalId: jsonSerialization['resourceExternalId'] as String?,
      payload: jsonSerialization['payload'] == null
          ? null
          : _i5.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['payload'],
            ),
      occurredAt: jsonSerialization['occurredAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['occurredAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue projectId;

  _i2.Project? project;

  _i3.ProjectEventKind kind;

  String? message;

  /// Identity service UUID of the actor that caused this event.
  _i1.UuidValue? actorIdentityId;

  _i4.ProjectLinkKind? resourceKind;

  String? resourceService;

  String? resourceExternalId;

  Map<String, String>? payload;

  DateTime occurredAt;

  /// Returns a shallow copy of this [ProjectEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectEvent copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i2.Project? project,
    _i3.ProjectEventKind? kind,
    String? message,
    _i1.UuidValue? actorIdentityId,
    _i4.ProjectLinkKind? resourceKind,
    String? resourceService,
    String? resourceExternalId,
    Map<String, String>? payload,
    DateTime? occurredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectEvent',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      'kind': kind.toJson(),
      if (message != null) 'message': message,
      if (actorIdentityId != null) 'actorIdentityId': actorIdentityId?.toJson(),
      if (resourceKind != null) 'resourceKind': resourceKind?.toJson(),
      if (resourceService != null) 'resourceService': resourceService,
      if (resourceExternalId != null) 'resourceExternalId': resourceExternalId,
      if (payload != null) 'payload': payload?.toJson(),
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectEventImpl extends ProjectEvent {
  _ProjectEventImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    required _i3.ProjectEventKind kind,
    String? message,
    _i1.UuidValue? actorIdentityId,
    _i4.ProjectLinkKind? resourceKind,
    String? resourceService,
    String? resourceExternalId,
    Map<String, String>? payload,
    DateTime? occurredAt,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         kind: kind,
         message: message,
         actorIdentityId: actorIdentityId,
         resourceKind: resourceKind,
         resourceService: resourceService,
         resourceExternalId: resourceExternalId,
         payload: payload,
         occurredAt: occurredAt,
       );

  /// Returns a shallow copy of this [ProjectEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectEvent copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    _i3.ProjectEventKind? kind,
    Object? message = _Undefined,
    Object? actorIdentityId = _Undefined,
    Object? resourceKind = _Undefined,
    Object? resourceService = _Undefined,
    Object? resourceExternalId = _Undefined,
    Object? payload = _Undefined,
    DateTime? occurredAt,
  }) {
    return ProjectEvent(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i2.Project? ? project : this.project?.copyWith(),
      kind: kind ?? this.kind,
      message: message is String? ? message : this.message,
      actorIdentityId: actorIdentityId is _i1.UuidValue?
          ? actorIdentityId
          : this.actorIdentityId,
      resourceKind: resourceKind is _i4.ProjectLinkKind?
          ? resourceKind
          : this.resourceKind,
      resourceService: resourceService is String?
          ? resourceService
          : this.resourceService,
      resourceExternalId: resourceExternalId is String?
          ? resourceExternalId
          : this.resourceExternalId,
      payload: payload is Map<String, String>?
          ? payload
          : this.payload?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }
}
