/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../../parties/models/party_membership_status.dart' as _i2;
import '../../parties/models/party.dart' as _i3;
import '../../parties/models/party_membership_role.dart' as _i4;
import 'package:parties_server/src/generated/protocol.dart' as _i5;

/// Link between a user profile owned by users and a business party context.
abstract class PartyMembership
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = PartyMembershipTable();

  static const db = PartyMembershipRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PartyMembership',
      if (id != null) 'id': id?.toJson(),
      'userProfileId': userProfileId.toJson(),
      'partyId': partyId.toJson(),
      if (party != null) 'party': party?.toJsonForProtocol(),
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

  static PartyMembershipInclude include({_i3.PartyInclude? party}) {
    return PartyMembershipInclude._(party: party);
  }

  static PartyMembershipIncludeList includeList({
    _i1.WhereExpressionBuilder<PartyMembershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartyMembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartyMembershipTable>? orderByList,
    PartyMembershipInclude? include,
  }) {
    return PartyMembershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PartyMembership.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PartyMembership.t),
      include: include,
    );
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

class PartyMembershipUpdateTable extends _i1.UpdateTable<PartyMembershipTable> {
  PartyMembershipUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> userProfileId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.userProfileId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> partyId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.partyId,
        value,
      );

  _i1.ColumnValue<_i4.PartyMembershipRole, _i4.PartyMembershipRole> role(
    _i4.PartyMembershipRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<_i2.PartyMembershipStatus, _i2.PartyMembershipStatus> status(
    _i2.PartyMembershipStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<bool, bool> isPrimary(bool value) => _i1.ColumnValue(
    table.isPrimary,
    value,
  );

  _i1.ColumnValue<String, String> title(String? value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> invitedByIdentityId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.invitedByIdentityId,
    value,
  );

  _i1.ColumnValue<Map<String, String>, Map<String, String>> metadata(
    Map<String, String>? value,
  ) => _i1.ColumnValue(
    table.metadata,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class PartyMembershipTable extends _i1.Table<_i1.UuidValue?> {
  PartyMembershipTable({super.tableRelation})
    : super(tableName: 'party_membership') {
    updateTable = PartyMembershipUpdateTable(this);
    userProfileId = _i1.ColumnUuid(
      'userProfileId',
      this,
    );
    partyId = _i1.ColumnUuid(
      'partyId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    isPrimary = _i1.ColumnBool(
      'isPrimary',
      this,
      hasDefault: true,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    invitedByIdentityId = _i1.ColumnUuid(
      'invitedByIdentityId',
      this,
    );
    metadata = _i1.ColumnSerializable<Map<String, String>>(
      'metadata',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final PartyMembershipUpdateTable updateTable;

  /// UserProfile UUID owned by the users service.
  late final _i1.ColumnUuid userProfileId;

  late final _i1.ColumnUuid partyId;

  _i3.PartyTable? _party;

  late final _i1.ColumnEnum<_i4.PartyMembershipRole> role;

  late final _i1.ColumnEnum<_i2.PartyMembershipStatus> status;

  late final _i1.ColumnBool isPrimary;

  late final _i1.ColumnString title;

  late final _i1.ColumnUuid invitedByIdentityId;

  late final _i1.ColumnSerializable<Map<String, String>> metadata;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  _i3.PartyTable get party {
    if (_party != null) return _party!;
    _party = _i1.createRelationTable(
      relationFieldName: 'party',
      field: PartyMembership.t.partyId,
      foreignField: _i3.Party.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.PartyTable(tableRelation: foreignTableRelation),
    );
    return _party!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    userProfileId,
    partyId,
    role,
    status,
    isPrimary,
    title,
    invitedByIdentityId,
    metadata,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'party') {
      return party;
    }
    return null;
  }
}

class PartyMembershipInclude extends _i1.IncludeObject {
  PartyMembershipInclude._({_i3.PartyInclude? party}) {
    _party = party;
  }

  _i3.PartyInclude? _party;

  @override
  Map<String, _i1.Include?> get includes => {'party': _party};

  @override
  _i1.Table<_i1.UuidValue?> get table => PartyMembership.t;
}

class PartyMembershipIncludeList extends _i1.IncludeList {
  PartyMembershipIncludeList._({
    _i1.WhereExpressionBuilder<PartyMembershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PartyMembership.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PartyMembership.t;
}

class PartyMembershipRepository {
  const PartyMembershipRepository._();

  final attachRow = const PartyMembershipAttachRowRepository._();

  /// Returns a list of [PartyMembership]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<PartyMembership>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartyMembershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartyMembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartyMembershipTable>? orderByList,
    _i1.Transaction? transaction,
    PartyMembershipInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PartyMembership>(
      where: where?.call(PartyMembership.t),
      orderBy: orderBy?.call(PartyMembership.t),
      orderByList: orderByList?.call(PartyMembership.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PartyMembership] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<PartyMembership?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartyMembershipTable>? where,
    int? offset,
    _i1.OrderByBuilder<PartyMembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartyMembershipTable>? orderByList,
    _i1.Transaction? transaction,
    PartyMembershipInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PartyMembership>(
      where: where?.call(PartyMembership.t),
      orderBy: orderBy?.call(PartyMembership.t),
      orderByList: orderByList?.call(PartyMembership.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PartyMembership] by its [id] or null if no such row exists.
  Future<PartyMembership?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    PartyMembershipInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PartyMembership>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PartyMembership]s in the list and returns the inserted rows.
  ///
  /// The returned [PartyMembership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PartyMembership>> insert(
    _i1.DatabaseSession session,
    List<PartyMembership> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PartyMembership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PartyMembership] and returns the inserted row.
  ///
  /// The returned [PartyMembership] will have its `id` field set.
  Future<PartyMembership> insertRow(
    _i1.DatabaseSession session,
    PartyMembership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PartyMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PartyMembership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PartyMembership>> update(
    _i1.DatabaseSession session,
    List<PartyMembership> rows, {
    _i1.ColumnSelections<PartyMembershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PartyMembership>(
      rows,
      columns: columns?.call(PartyMembership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PartyMembership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PartyMembership> updateRow(
    _i1.DatabaseSession session,
    PartyMembership row, {
    _i1.ColumnSelections<PartyMembershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PartyMembership>(
      row,
      columns: columns?.call(PartyMembership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PartyMembership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PartyMembership?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PartyMembershipUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PartyMembership>(
      id,
      columnValues: columnValues(PartyMembership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PartyMembership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PartyMembership>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PartyMembershipUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PartyMembershipTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartyMembershipTable>? orderBy,
    _i1.OrderByListBuilder<PartyMembershipTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PartyMembership>(
      columnValues: columnValues(PartyMembership.t.updateTable),
      where: where(PartyMembership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PartyMembership.t),
      orderByList: orderByList?.call(PartyMembership.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PartyMembership]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PartyMembership>> delete(
    _i1.DatabaseSession session,
    List<PartyMembership> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PartyMembership>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PartyMembership].
  Future<PartyMembership> deleteRow(
    _i1.DatabaseSession session,
    PartyMembership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PartyMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PartyMembership>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PartyMembershipTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PartyMembership>(
      where: where(PartyMembership.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartyMembershipTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PartyMembership>(
      where: where?.call(PartyMembership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PartyMembership] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PartyMembershipTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PartyMembership>(
      where: where(PartyMembership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class PartyMembershipAttachRowRepository {
  const PartyMembershipAttachRowRepository._();

  /// Creates a relation between the given [PartyMembership] and [Party]
  /// by setting the [PartyMembership]'s foreign key `partyId` to refer to the [Party].
  Future<void> party(
    _i1.DatabaseSession session,
    PartyMembership partyMembership,
    _i3.Party party, {
    _i1.Transaction? transaction,
  }) async {
    if (partyMembership.id == null) {
      throw ArgumentError.notNull('partyMembership.id');
    }
    if (party.id == null) {
      throw ArgumentError.notNull('party.id');
    }

    var $partyMembership = partyMembership.copyWith(partyId: party.id);
    await session.db.updateRow<PartyMembership>(
      $partyMembership,
      columns: [PartyMembership.t.partyId],
      transaction: transaction,
    );
  }
}
