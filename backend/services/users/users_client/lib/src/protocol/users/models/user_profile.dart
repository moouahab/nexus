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
import '../../users/models/user_profile_kind.dart' as _i2;
import '../../users/models/user_profile_status.dart' as _i3;
import 'package:users_client/src/protocol/protocol.dart' as _i4;

/// Functional NEXUS profile for one connected technical identity.
abstract class UserProfile implements _i1.SerializableModel {
  UserProfile._({
    this.id,
    required this.identityId,
    required this.displayName,
    _i2.UserProfileKind? kind,
    _i3.UserProfileStatus? status,
    this.primaryPartyId,
    this.email,
    this.avatarUri,
    this.bio,
    this.locale,
    this.timezone,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : kind = kind ?? _i2.UserProfileKind.consultant,
       status = status ?? _i3.UserProfileStatus.active,
       createdAt = createdAt ?? DateTime.now();

  factory UserProfile({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    required String displayName,
    _i2.UserProfileKind? kind,
    _i3.UserProfileStatus? status,
    _i1.UuidValue? primaryPartyId,
    String? email,
    String? avatarUri,
    String? bio,
    String? locale,
    String? timezone,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfileImpl;

  factory UserProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProfile(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      identityId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['identityId'],
      ),
      displayName: jsonSerialization['displayName'] as String,
      kind: jsonSerialization['kind'] == null
          ? null
          : _i2.UserProfileKind.fromJson((jsonSerialization['kind'] as String)),
      status: jsonSerialization['status'] == null
          ? null
          : _i3.UserProfileStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      primaryPartyId: jsonSerialization['primaryPartyId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['primaryPartyId'],
            ),
      email: jsonSerialization['email'] as String?,
      avatarUri: jsonSerialization['avatarUri'] as String?,
      bio: jsonSerialization['bio'] as String?,
      locale: jsonSerialization['locale'] as String?,
      timezone: jsonSerialization['timezone'] as String?,
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
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  /// Identity service UUID. Authentication remains owned by identity.
  _i1.UuidValue identityId;

  String displayName;

  _i2.UserProfileKind kind;

  _i3.UserProfileStatus status;

  /// Preferred party context UUID owned by the parties service, when one exists.
  _i1.UuidValue? primaryPartyId;

  String? email;

  String? avatarUri;

  String? bio;

  String? locale;

  String? timezone;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserProfile copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? identityId,
    String? displayName,
    _i2.UserProfileKind? kind,
    _i3.UserProfileStatus? status,
    _i1.UuidValue? primaryPartyId,
    String? email,
    String? avatarUri,
    String? bio,
    String? locale,
    String? timezone,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id?.toJson(),
      'identityId': identityId.toJson(),
      'displayName': displayName,
      'kind': kind.toJson(),
      'status': status.toJson(),
      if (primaryPartyId != null) 'primaryPartyId': primaryPartyId?.toJson(),
      if (email != null) 'email': email,
      if (avatarUri != null) 'avatarUri': avatarUri,
      if (bio != null) 'bio': bio,
      if (locale != null) 'locale': locale,
      if (timezone != null) 'timezone': timezone,
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

class _UserProfileImpl extends UserProfile {
  _UserProfileImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    required String displayName,
    _i2.UserProfileKind? kind,
    _i3.UserProfileStatus? status,
    _i1.UuidValue? primaryPartyId,
    String? email,
    String? avatarUri,
    String? bio,
    String? locale,
    String? timezone,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         identityId: identityId,
         displayName: displayName,
         kind: kind,
         status: status,
         primaryPartyId: primaryPartyId,
         email: email,
         avatarUri: avatarUri,
         bio: bio,
         locale: locale,
         timezone: timezone,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserProfile copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? identityId,
    String? displayName,
    _i2.UserProfileKind? kind,
    _i3.UserProfileStatus? status,
    Object? primaryPartyId = _Undefined,
    Object? email = _Undefined,
    Object? avatarUri = _Undefined,
    Object? bio = _Undefined,
    Object? locale = _Undefined,
    Object? timezone = _Undefined,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return UserProfile(
      id: id is _i1.UuidValue? ? id : this.id,
      identityId: identityId ?? this.identityId,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      primaryPartyId: primaryPartyId is _i1.UuidValue?
          ? primaryPartyId
          : this.primaryPartyId,
      email: email is String? ? email : this.email,
      avatarUri: avatarUri is String? ? avatarUri : this.avatarUri,
      bio: bio is String? ? bio : this.bio,
      locale: locale is String? ? locale : this.locale,
      timezone: timezone is String? ? timezone : this.timezone,
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
