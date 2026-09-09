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
import 'parties/models/party.dart' as _i2;
import 'parties/models/party_kind.dart' as _i3;
import 'parties/models/party_membership.dart' as _i4;
import 'parties/models/party_membership_role.dart' as _i5;
import 'parties/models/party_membership_status.dart' as _i6;
import 'parties/models/party_status.dart' as _i7;
import 'package:parties_client/src/protocol/parties/models/party.dart' as _i8;
import 'package:parties_client/src/protocol/parties/models/party_membership.dart'
    as _i9;
export 'parties/models/party.dart';
export 'parties/models/party_kind.dart';
export 'parties/models/party_membership.dart';
export 'parties/models/party_membership_role.dart';
export 'parties/models/party_membership_status.dart';
export 'parties/models/party_status.dart';
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

    if (t == _i2.Party) {
      return _i2.Party.fromJson(data) as T;
    }
    if (t == _i3.PartyKind) {
      return _i3.PartyKind.fromJson(data) as T;
    }
    if (t == _i4.PartyMembership) {
      return _i4.PartyMembership.fromJson(data) as T;
    }
    if (t == _i5.PartyMembershipRole) {
      return _i5.PartyMembershipRole.fromJson(data) as T;
    }
    if (t == _i6.PartyMembershipStatus) {
      return _i6.PartyMembershipStatus.fromJson(data) as T;
    }
    if (t == _i7.PartyStatus) {
      return _i7.PartyStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Party?>()) {
      return (data != null ? _i2.Party.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.PartyKind?>()) {
      return (data != null ? _i3.PartyKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.PartyMembership?>()) {
      return (data != null ? _i4.PartyMembership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.PartyMembershipRole?>()) {
      return (data != null ? _i5.PartyMembershipRole.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.PartyMembershipStatus?>()) {
      return (data != null ? _i6.PartyMembershipStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.PartyStatus?>()) {
      return (data != null ? _i7.PartyStatus.fromJson(data) : null) as T;
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
    if (t == List<_i8.Party>) {
      return (data as List).map((e) => deserialize<_i8.Party>(e)).toList() as T;
    }
    if (t == List<_i9.PartyMembership>) {
      return (data as List)
              .map((e) => deserialize<_i9.PartyMembership>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Party => 'Party',
      _i3.PartyKind => 'PartyKind',
      _i4.PartyMembership => 'PartyMembership',
      _i5.PartyMembershipRole => 'PartyMembershipRole',
      _i6.PartyMembershipStatus => 'PartyMembershipStatus',
      _i7.PartyStatus => 'PartyStatus',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('parties.', '');
    }

    switch (data) {
      case _i2.Party():
        return 'Party';
      case _i3.PartyKind():
        return 'PartyKind';
      case _i4.PartyMembership():
        return 'PartyMembership';
      case _i5.PartyMembershipRole():
        return 'PartyMembershipRole';
      case _i6.PartyMembershipStatus():
        return 'PartyMembershipStatus';
      case _i7.PartyStatus():
        return 'PartyStatus';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Party') {
      return deserialize<_i2.Party>(data['data']);
    }
    if (dataClassName == 'PartyKind') {
      return deserialize<_i3.PartyKind>(data['data']);
    }
    if (dataClassName == 'PartyMembership') {
      return deserialize<_i4.PartyMembership>(data['data']);
    }
    if (dataClassName == 'PartyMembershipRole') {
      return deserialize<_i5.PartyMembershipRole>(data['data']);
    }
    if (dataClassName == 'PartyMembershipStatus') {
      return deserialize<_i6.PartyMembershipStatus>(data['data']);
    }
    if (dataClassName == 'PartyStatus') {
      return deserialize<_i7.PartyStatus>(data['data']);
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
