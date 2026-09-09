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
import 'package:serverpod/serverpod.dart' as _i1;
import '../../parties/models/party_status.dart' as _i2;
import '../../parties/models/party_kind.dart' as _i3;
import 'package:parties_server/src/generated/protocol.dart' as _i4;

/// Business actor represented in NEXUS: company, association, or consultant practice.
abstract class Party
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = PartyTable();

  static const db = PartyRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static PartyInclude include() {
    return PartyInclude._();
  }

  static PartyIncludeList includeList({
    _i1.WhereExpressionBuilder<PartyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartyTable>? orderByList,
    PartyInclude? include,
  }) {
    return PartyIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Party.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Party.t),
      include: include,
    );
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

class PartyUpdateTable extends _i1.UpdateTable<PartyTable> {
  PartyUpdateTable(super.table);

  _i1.ColumnValue<_i3.PartyKind, _i3.PartyKind> kind(_i3.PartyKind value) =>
      _i1.ColumnValue(
        table.kind,
        value,
      );

  _i1.ColumnValue<_i2.PartyStatus, _i2.PartyStatus> status(
    _i2.PartyStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> legalName(String? value) => _i1.ColumnValue(
    table.legalName,
    value,
  );

  _i1.ColumnValue<String, String> registrationNumber(String? value) =>
      _i1.ColumnValue(
        table.registrationNumber,
        value,
      );

  _i1.ColumnValue<String, String> country(String? value) => _i1.ColumnValue(
    table.country,
    value,
  );

  _i1.ColumnValue<String, String> website(String? value) => _i1.ColumnValue(
    table.website,
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

class PartyTable extends _i1.Table<_i1.UuidValue?> {
  PartyTable({super.tableRelation}) : super(tableName: 'party') {
    updateTable = PartyUpdateTable(this);
    kind = _i1.ColumnEnum(
      'kind',
      this,
      _i1.EnumSerialization.byName,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    legalName = _i1.ColumnString(
      'legalName',
      this,
    );
    registrationNumber = _i1.ColumnString(
      'registrationNumber',
      this,
    );
    country = _i1.ColumnString(
      'country',
      this,
    );
    website = _i1.ColumnString(
      'website',
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

  late final PartyUpdateTable updateTable;

  late final _i1.ColumnEnum<_i3.PartyKind> kind;

  late final _i1.ColumnEnum<_i2.PartyStatus> status;

  late final _i1.ColumnString name;

  late final _i1.ColumnString legalName;

  late final _i1.ColumnString registrationNumber;

  late final _i1.ColumnString country;

  late final _i1.ColumnString website;

  late final _i1.ColumnSerializable<Map<String, String>> metadata;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    kind,
    status,
    name,
    legalName,
    registrationNumber,
    country,
    website,
    metadata,
    createdAt,
    updatedAt,
  ];
}

class PartyInclude extends _i1.IncludeObject {
  PartyInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Party.t;
}

class PartyIncludeList extends _i1.IncludeList {
  PartyIncludeList._({
    _i1.WhereExpressionBuilder<PartyTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Party.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Party.t;
}

class PartyRepository {
  const PartyRepository._();

  /// Returns a list of [Party]s matching the given query parameters.
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
  Future<List<Party>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartyTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Party>(
      where: where?.call(Party.t),
      orderBy: orderBy?.call(Party.t),
      orderByList: orderByList?.call(Party.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Party] matching the given query parameters.
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
  Future<Party?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartyTable>? where,
    int? offset,
    _i1.OrderByBuilder<PartyTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartyTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Party>(
      where: where?.call(Party.t),
      orderBy: orderBy?.call(Party.t),
      orderByList: orderByList?.call(Party.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Party] by its [id] or null if no such row exists.
  Future<Party?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Party>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Party]s in the list and returns the inserted rows.
  ///
  /// The returned [Party]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Party>> insert(
    _i1.DatabaseSession session,
    List<Party> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Party>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Party] and returns the inserted row.
  ///
  /// The returned [Party] will have its `id` field set.
  Future<Party> insertRow(
    _i1.DatabaseSession session,
    Party row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Party>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Party]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Party>> update(
    _i1.DatabaseSession session,
    List<Party> rows, {
    _i1.ColumnSelections<PartyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Party>(
      rows,
      columns: columns?.call(Party.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Party]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Party> updateRow(
    _i1.DatabaseSession session,
    Party row, {
    _i1.ColumnSelections<PartyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Party>(
      row,
      columns: columns?.call(Party.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Party] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Party?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PartyUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Party>(
      id,
      columnValues: columnValues(Party.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Party]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Party>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PartyUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PartyTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartyTable>? orderBy,
    _i1.OrderByListBuilder<PartyTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Party>(
      columnValues: columnValues(Party.t.updateTable),
      where: where(Party.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Party.t),
      orderByList: orderByList?.call(Party.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Party]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Party>> delete(
    _i1.DatabaseSession session,
    List<Party> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Party>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Party].
  Future<Party> deleteRow(
    _i1.DatabaseSession session,
    Party row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Party>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Party>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PartyTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Party>(
      where: where(Party.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartyTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Party>(
      where: where?.call(Party.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Party] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PartyTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Party>(
      where: where(Party.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
