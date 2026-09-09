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
import 'projects/models/project.dart' as _i2;
import 'projects/models/project_archive_entry.dart' as _i3;
import 'projects/models/project_event.dart' as _i4;
import 'projects/models/project_event_kind.dart' as _i5;
import 'projects/models/project_link.dart' as _i6;
import 'projects/models/project_link_kind.dart' as _i7;
import 'projects/models/project_link_status.dart' as _i8;
import 'projects/models/project_participant.dart' as _i9;
import 'projects/models/project_participant_role.dart' as _i10;
import 'projects/models/project_participant_status.dart' as _i11;
import 'projects/models/project_status.dart' as _i12;
import 'projects/models/project_visibility.dart' as _i13;
import 'package:projects_client/src/protocol/projects/models/project.dart'
    as _i14;
import 'package:projects_client/src/protocol/projects/models/project_participant.dart'
    as _i15;
import 'package:projects_client/src/protocol/projects/models/project_link.dart'
    as _i16;
import 'package:projects_client/src/protocol/projects/models/project_event.dart'
    as _i17;
export 'projects/models/project.dart';
export 'projects/models/project_archive_entry.dart';
export 'projects/models/project_event.dart';
export 'projects/models/project_event_kind.dart';
export 'projects/models/project_link.dart';
export 'projects/models/project_link_kind.dart';
export 'projects/models/project_link_status.dart';
export 'projects/models/project_participant.dart';
export 'projects/models/project_participant_role.dart';
export 'projects/models/project_participant_status.dart';
export 'projects/models/project_status.dart';
export 'projects/models/project_visibility.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Project) {
      return _i2.Project.fromJson(data) as T;
    }
    if (t == _i3.ProjectArchiveEntry) {
      return _i3.ProjectArchiveEntry.fromJson(data) as T;
    }
    if (t == _i4.ProjectEvent) {
      return _i4.ProjectEvent.fromJson(data) as T;
    }
    if (t == _i5.ProjectEventKind) {
      return _i5.ProjectEventKind.fromJson(data) as T;
    }
    if (t == _i6.ProjectLink) {
      return _i6.ProjectLink.fromJson(data) as T;
    }
    if (t == _i7.ProjectLinkKind) {
      return _i7.ProjectLinkKind.fromJson(data) as T;
    }
    if (t == _i8.ProjectLinkStatus) {
      return _i8.ProjectLinkStatus.fromJson(data) as T;
    }
    if (t == _i9.ProjectParticipant) {
      return _i9.ProjectParticipant.fromJson(data) as T;
    }
    if (t == _i10.ProjectParticipantRole) {
      return _i10.ProjectParticipantRole.fromJson(data) as T;
    }
    if (t == _i11.ProjectParticipantStatus) {
      return _i11.ProjectParticipantStatus.fromJson(data) as T;
    }
    if (t == _i12.ProjectStatus) {
      return _i12.ProjectStatus.fromJson(data) as T;
    }
    if (t == _i13.ProjectVisibility) {
      return _i13.ProjectVisibility.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Project?>()) {
      return (data != null ? _i2.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ProjectArchiveEntry?>()) {
      return (data != null ? _i3.ProjectArchiveEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.ProjectEvent?>()) {
      return (data != null ? _i4.ProjectEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ProjectEventKind?>()) {
      return (data != null ? _i5.ProjectEventKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ProjectLink?>()) {
      return (data != null ? _i6.ProjectLink.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ProjectLinkKind?>()) {
      return (data != null ? _i7.ProjectLinkKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ProjectLinkStatus?>()) {
      return (data != null ? _i8.ProjectLinkStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ProjectParticipant?>()) {
      return (data != null ? _i9.ProjectParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ProjectParticipantRole?>()) {
      return (data != null ? _i10.ProjectParticipantRole.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.ProjectParticipantStatus?>()) {
      return (data != null
              ? _i11.ProjectParticipantStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i12.ProjectStatus?>()) {
      return (data != null ? _i12.ProjectStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ProjectVisibility?>()) {
      return (data != null ? _i13.ProjectVisibility.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_i14.Project>) {
      return (data as List).map((e) => deserialize<_i14.Project>(e)).toList()
          as T;
    }
    if (t == List<_i15.ProjectParticipant>) {
      return (data as List)
              .map((e) => deserialize<_i15.ProjectParticipant>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.ProjectLink>) {
      return (data as List)
              .map((e) => deserialize<_i16.ProjectLink>(e))
              .toList()
          as T;
    }
    if (t == List<_i17.ProjectEvent>) {
      return (data as List)
              .map((e) => deserialize<_i17.ProjectEvent>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Project => 'Project',
      _i3.ProjectArchiveEntry => 'ProjectArchiveEntry',
      _i4.ProjectEvent => 'ProjectEvent',
      _i5.ProjectEventKind => 'ProjectEventKind',
      _i6.ProjectLink => 'ProjectLink',
      _i7.ProjectLinkKind => 'ProjectLinkKind',
      _i8.ProjectLinkStatus => 'ProjectLinkStatus',
      _i9.ProjectParticipant => 'ProjectParticipant',
      _i10.ProjectParticipantRole => 'ProjectParticipantRole',
      _i11.ProjectParticipantStatus => 'ProjectParticipantStatus',
      _i12.ProjectStatus => 'ProjectStatus',
      _i13.ProjectVisibility => 'ProjectVisibility',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('projects.', '');
    }

    switch (data) {
      case _i2.Project():
        return 'Project';
      case _i3.ProjectArchiveEntry():
        return 'ProjectArchiveEntry';
      case _i4.ProjectEvent():
        return 'ProjectEvent';
      case _i5.ProjectEventKind():
        return 'ProjectEventKind';
      case _i6.ProjectLink():
        return 'ProjectLink';
      case _i7.ProjectLinkKind():
        return 'ProjectLinkKind';
      case _i8.ProjectLinkStatus():
        return 'ProjectLinkStatus';
      case _i9.ProjectParticipant():
        return 'ProjectParticipant';
      case _i10.ProjectParticipantRole():
        return 'ProjectParticipantRole';
      case _i11.ProjectParticipantStatus():
        return 'ProjectParticipantStatus';
      case _i12.ProjectStatus():
        return 'ProjectStatus';
      case _i13.ProjectVisibility():
        return 'ProjectVisibility';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i2.Project>(data['data']);
    }
    if (dataClassName == 'ProjectArchiveEntry') {
      return deserialize<_i3.ProjectArchiveEntry>(data['data']);
    }
    if (dataClassName == 'ProjectEvent') {
      return deserialize<_i4.ProjectEvent>(data['data']);
    }
    if (dataClassName == 'ProjectEventKind') {
      return deserialize<_i5.ProjectEventKind>(data['data']);
    }
    if (dataClassName == 'ProjectLink') {
      return deserialize<_i6.ProjectLink>(data['data']);
    }
    if (dataClassName == 'ProjectLinkKind') {
      return deserialize<_i7.ProjectLinkKind>(data['data']);
    }
    if (dataClassName == 'ProjectLinkStatus') {
      return deserialize<_i8.ProjectLinkStatus>(data['data']);
    }
    if (dataClassName == 'ProjectParticipant') {
      return deserialize<_i9.ProjectParticipant>(data['data']);
    }
    if (dataClassName == 'ProjectParticipantRole') {
      return deserialize<_i10.ProjectParticipantRole>(data['data']);
    }
    if (dataClassName == 'ProjectParticipantStatus') {
      return deserialize<_i11.ProjectParticipantStatus>(data['data']);
    }
    if (dataClassName == 'ProjectStatus') {
      return deserialize<_i12.ProjectStatus>(data['data']);
    }
    if (dataClassName == 'ProjectVisibility') {
      return deserialize<_i13.ProjectVisibility>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
