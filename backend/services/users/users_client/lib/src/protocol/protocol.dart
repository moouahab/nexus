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
import 'users/models/user_profile.dart' as _i2;
import 'users/models/user_profile_kind.dart' as _i3;
import 'users/models/user_profile_status.dart' as _i4;
export 'users/models/user_profile.dart';
export 'users/models/user_profile_kind.dart';
export 'users/models/user_profile_status.dart';
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

    if (t == _i2.UserProfile) {
      return _i2.UserProfile.fromJson(data) as T;
    }
    if (t == _i3.UserProfileKind) {
      return _i3.UserProfileKind.fromJson(data) as T;
    }
    if (t == _i4.UserProfileStatus) {
      return _i4.UserProfileStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.UserProfile?>()) {
      return (data != null ? _i2.UserProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.UserProfileKind?>()) {
      return (data != null ? _i3.UserProfileKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.UserProfileStatus?>()) {
      return (data != null ? _i4.UserProfileStatus.fromJson(data) : null) as T;
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
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.UserProfile => 'UserProfile',
      _i3.UserProfileKind => 'UserProfileKind',
      _i4.UserProfileStatus => 'UserProfileStatus',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('users.', '');
    }

    switch (data) {
      case _i2.UserProfile():
        return 'UserProfile';
      case _i3.UserProfileKind():
        return 'UserProfileKind';
      case _i4.UserProfileStatus():
        return 'UserProfileStatus';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'UserProfile') {
      return deserialize<_i2.UserProfile>(data['data']);
    }
    if (dataClassName == 'UserProfileKind') {
      return deserialize<_i3.UserProfileKind>(data['data']);
    }
    if (dataClassName == 'UserProfileStatus') {
      return deserialize<_i4.UserProfileStatus>(data['data']);
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
