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
import '../../parties/models/party_membership_status.dart' as _i2;
import '../../parties/models/party.dart' as _i3;
import '../../parties/models/party_membership_role.dart' as _i4;
import 'package:parties_client/src/protocol/protocol.dart' as _i5;

/// Link between a user profile owned by users and a business party context.
abstract class PartyMembership implements _i1.SerializableModel {
  PartyMembership._({
    this.id,
    required this.userProfileId,
    required this.partyId,
    this.party,
    required this.role,
    _i2.PartyMembershipStatus? status,
    bool? isPrimary,
    this.title,
    this.invitedByIdentityId,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.PartyMembershipStatus.active,
       isPrimary = isPrimary ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory PartyMembership({
    _i1.UuidValue? id,
    required _i1.UuidValue userProfileId,
    required _i1.UuidValue partyId,
    _i3.Party? party,
    required _i4.PartyMembershipRole role,
    _i2.PartyMembershipStatus? status,
    bool? isPrimary,
    String? title,
    _i1.UuidValue? invitedByIdentityId,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartyMembershipImpl;

  factory PartyMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return PartyMembership(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userProfileId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['userProfileId'],
      ),
      partyId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['partyId'],
      ),
      party: jsonSerialization['party'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.Party>(jsonSerialization['party']),
      role: _i4.PartyMembershipRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.PartyMembershipStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      isPrimary: jsonSerialization['isPrimary'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isPrimary']),
      title: jsonSerialization['title'] as String?,
      invitedByIdentityId: jsonSerialization['invitedByIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['invitedByIdentityId'],
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

  /// UserProfile UUID owned by the users service.
  _i1.UuidValue userProfileId;

  _i1.UuidValue partyId;

  _i3.Party? party;

  _i4.PartyMembershipRole role;

  _i2.PartyMembershipStatus status;

  bool isPrimary;

  String? title;

  _i1.UuidValue? invitedByIdentityId;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [PartyMembership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PartyMembership copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userProfileId,
    _i1.UuidValue? partyId,
    _i3.Party? party,
    _i4.PartyMembershipRole? role,
    _i2.PartyMembershipStatus? status,
    bool? isPrimary,
    String? title,
    _i1.UuidValue? invitedByIdentityId,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PartyMembership',
      if (id != null) 'id': id?.toJson(),
      'userProfileId': userProfileId.toJson(),
      'partyId': partyId.toJson(),
      if (party != null) 'party': party?.toJson(),
      'role': role.toJson(),
      'status': status.toJson(),
      'isPrimary': isPrimary,
      if (title != null) 'title': title,
      if (invitedByIdentityId != null)
        'invitedByIdentityId': invitedByIdentityId?.toJson(),
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

class _PartyMembershipImpl extends PartyMembership {
  _PartyMembershipImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue userProfileId,
    required _i1.UuidValue partyId,
    _i3.Party? party,
    required _i4.PartyMembershipRole role,
    _i2.PartyMembershipStatus? status,
    bool? isPrimary,
    String? title,
    _i1.UuidValue? invitedByIdentityId,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userProfileId: userProfileId,
         partyId: partyId,
         party: party,
         role: role,
         status: status,
         isPrimary: isPrimary,
         title: title,
         invitedByIdentityId: invitedByIdentityId,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PartyMembership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PartyMembership copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userProfileId,
    _i1.UuidValue? partyId,
    Object? party = _Undefined,
    _i4.PartyMembershipRole? role,
    _i2.PartyMembershipStatus? status,
    bool? isPrimary,
    Object? title = _Undefined,
    Object? invitedByIdentityId = _Undefined,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return PartyMembership(
      id: id is _i1.UuidValue? ? id : this.id,
      userProfileId: userProfileId ?? this.userProfileId,
      partyId: partyId ?? this.partyId,
      party: party is _i3.Party? ? party : this.party?.copyWith(),
      role: role ?? this.role,
      status: status ?? this.status,
      isPrimary: isPrimary ?? this.isPrimary,
      title: title is String? ? title : this.title,
      invitedByIdentityId: invitedByIdentityId is _i1.UuidValue?
          ? invitedByIdentityId
          : this.invitedByIdentityId,
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
