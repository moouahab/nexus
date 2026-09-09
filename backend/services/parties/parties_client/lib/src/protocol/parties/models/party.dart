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
import '../../parties/models/party_status.dart' as _i2;
import '../../parties/models/party_kind.dart' as _i3;
import 'package:parties_client/src/protocol/protocol.dart' as _i4;

/// Business actor represented in NEXUS: company, association, or consultant practice.
abstract class Party implements _i1.SerializableModel {
  Party._({
    this.id,
    required this.kind,
    _i2.PartyStatus? status,
    required this.name,
    this.legalName,
    this.registrationNumber,
    this.country,
    this.website,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.PartyStatus.active,
       createdAt = createdAt ?? DateTime.now();

  factory Party({
    _i1.UuidValue? id,
    required _i3.PartyKind kind,
    _i2.PartyStatus? status,
    required String name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PartyImpl;

  factory Party.fromJson(Map<String, dynamic> jsonSerialization) {
    return Party(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      kind: _i3.PartyKind.fromJson((jsonSerialization['kind'] as String)),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.PartyStatus.fromJson((jsonSerialization['status'] as String)),
      name: jsonSerialization['name'] as String,
      legalName: jsonSerialization['legalName'] as String?,
      registrationNumber: jsonSerialization['registrationNumber'] as String?,
      country: jsonSerialization['country'] as String?,
      website: jsonSerialization['website'] as String?,
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

  _i3.PartyKind kind;

  _i2.PartyStatus status;

  String name;

  String? legalName;

  String? registrationNumber;

  String? country;

  String? website;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Party]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Party copyWith({
    _i1.UuidValue? id,
    _i3.PartyKind? kind,
    _i2.PartyStatus? status,
    String? name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Party',
      if (id != null) 'id': id?.toJson(),
      'kind': kind.toJson(),
      'status': status.toJson(),
      'name': name,
      if (legalName != null) 'legalName': legalName,
      if (registrationNumber != null) 'registrationNumber': registrationNumber,
      if (country != null) 'country': country,
      if (website != null) 'website': website,
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

class _PartyImpl extends Party {
  _PartyImpl({
    _i1.UuidValue? id,
    required _i3.PartyKind kind,
    _i2.PartyStatus? status,
    required String name,
    String? legalName,
    String? registrationNumber,
    String? country,
    String? website,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         kind: kind,
         status: status,
         name: name,
         legalName: legalName,
         registrationNumber: registrationNumber,
         country: country,
         website: website,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Party]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Party copyWith({
    Object? id = _Undefined,
    _i3.PartyKind? kind,
    _i2.PartyStatus? status,
    String? name,
    Object? legalName = _Undefined,
    Object? registrationNumber = _Undefined,
    Object? country = _Undefined,
    Object? website = _Undefined,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return Party(
      id: id is _i1.UuidValue? ? id : this.id,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      name: name ?? this.name,
      legalName: legalName is String? ? legalName : this.legalName,
      registrationNumber: registrationNumber is String?
          ? registrationNumber
          : this.registrationNumber,
      country: country is String? ? country : this.country,
      website: website is String? ? website : this.website,
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
