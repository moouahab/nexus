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

/// One-time Projects grant marker. Only a SHA-256 digest of the jti is stored.
abstract class ConsumedProjectAuthorizationGrant
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  ConsumedProjectAuthorizationGrant._({
    this.id,
    required this.jwtIdHash,
    required this.expiresAt,
    DateTime? consumedAt,
  }) : consumedAt = consumedAt ?? DateTime.now();

  factory ConsumedProjectAuthorizationGrant({
    _i1.UuidValue? id,
    required String jwtIdHash,
    required DateTime expiresAt,
    DateTime? consumedAt,
  }) = _ConsumedProjectAuthorizationGrantImpl;

  factory ConsumedProjectAuthorizationGrant.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ConsumedProjectAuthorizationGrant(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      jwtIdHash: jsonSerialization['jwtIdHash'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
    );
  }

  static final t = ConsumedProjectAuthorizationGrantTable();

  static const db = ConsumedProjectAuthorizationGrantRepository._();

  @override
  _i1.UuidValue? id;

  String jwtIdHash;

  DateTime expiresAt;

  DateTime consumedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ConsumedProjectAuthorizationGrant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConsumedProjectAuthorizationGrant copyWith({
    _i1.UuidValue? id,
    String? jwtIdHash,
    DateTime? expiresAt,
    DateTime? consumedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConsumedProjectAuthorizationGrant',
      if (id != null) 'id': id?.toJson(),
      'jwtIdHash': jwtIdHash,
      'expiresAt': expiresAt.toJson(),
      'consumedAt': consumedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ConsumedProjectAuthorizationGrantInclude include() {
    return ConsumedProjectAuthorizationGrantInclude._();
  }

  static ConsumedProjectAuthorizationGrantIncludeList includeList({
    _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumedProjectAuthorizationGrantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumedProjectAuthorizationGrantTable>? orderByList,
    ConsumedProjectAuthorizationGrantInclude? include,
  }) {
    return ConsumedProjectAuthorizationGrantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumedProjectAuthorizationGrant.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ConsumedProjectAuthorizationGrant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumedProjectAuthorizationGrantImpl
    extends ConsumedProjectAuthorizationGrant {
  _ConsumedProjectAuthorizationGrantImpl({
    _i1.UuidValue? id,
    required String jwtIdHash,
    required DateTime expiresAt,
    DateTime? consumedAt,
  }) : super._(
         id: id,
         jwtIdHash: jwtIdHash,
         expiresAt: expiresAt,
         consumedAt: consumedAt,
       );

  /// Returns a shallow copy of this [ConsumedProjectAuthorizationGrant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConsumedProjectAuthorizationGrant copyWith({
    Object? id = _Undefined,
    String? jwtIdHash,
    DateTime? expiresAt,
    DateTime? consumedAt,
  }) {
    return ConsumedProjectAuthorizationGrant(
      id: id is _i1.UuidValue? ? id : this.id,
      jwtIdHash: jwtIdHash ?? this.jwtIdHash,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedAt: consumedAt ?? this.consumedAt,
    );
  }
}

class ConsumedProjectAuthorizationGrantUpdateTable
    extends _i1.UpdateTable<ConsumedProjectAuthorizationGrantTable> {
  ConsumedProjectAuthorizationGrantUpdateTable(super.table);

  _i1.ColumnValue<String, String> jwtIdHash(String value) => _i1.ColumnValue(
    table.jwtIdHash,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> consumedAt(DateTime value) =>
      _i1.ColumnValue(
        table.consumedAt,
        value,
      );
}

class ConsumedProjectAuthorizationGrantTable extends _i1.Table<_i1.UuidValue?> {
  ConsumedProjectAuthorizationGrantTable({super.tableRelation})
    : super(tableName: 'consumed_project_authorization_grant') {
    updateTable = ConsumedProjectAuthorizationGrantUpdateTable(this);
    jwtIdHash = _i1.ColumnString(
      'jwtIdHash',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    consumedAt = _i1.ColumnDateTime(
      'consumedAt',
      this,
      hasDefault: true,
    );
  }

  late final ConsumedProjectAuthorizationGrantUpdateTable updateTable;

  late final _i1.ColumnString jwtIdHash;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime consumedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    jwtIdHash,
    expiresAt,
    consumedAt,
  ];
}

class ConsumedProjectAuthorizationGrantInclude extends _i1.IncludeObject {
  ConsumedProjectAuthorizationGrantInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ConsumedProjectAuthorizationGrant.t;
}

class ConsumedProjectAuthorizationGrantIncludeList extends _i1.IncludeList {
  ConsumedProjectAuthorizationGrantIncludeList._({
    _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ConsumedProjectAuthorizationGrant.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ConsumedProjectAuthorizationGrant.t;
}

class ConsumedProjectAuthorizationGrantRepository {
  const ConsumedProjectAuthorizationGrantRepository._();

  /// Returns a list of [ConsumedProjectAuthorizationGrant]s matching the given query parameters.
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
  Future<List<ConsumedProjectAuthorizationGrant>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumedProjectAuthorizationGrantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumedProjectAuthorizationGrantTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ConsumedProjectAuthorizationGrant>(
      where: where?.call(ConsumedProjectAuthorizationGrant.t),
      orderBy: orderBy?.call(ConsumedProjectAuthorizationGrant.t),
      orderByList: orderByList?.call(ConsumedProjectAuthorizationGrant.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ConsumedProjectAuthorizationGrant] matching the given query parameters.
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
  Future<ConsumedProjectAuthorizationGrant?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>? where,
    int? offset,
    _i1.OrderByBuilder<ConsumedProjectAuthorizationGrantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumedProjectAuthorizationGrantTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ConsumedProjectAuthorizationGrant>(
      where: where?.call(ConsumedProjectAuthorizationGrant.t),
      orderBy: orderBy?.call(ConsumedProjectAuthorizationGrant.t),
      orderByList: orderByList?.call(ConsumedProjectAuthorizationGrant.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ConsumedProjectAuthorizationGrant] by its [id] or null if no such row exists.
  Future<ConsumedProjectAuthorizationGrant?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ConsumedProjectAuthorizationGrant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ConsumedProjectAuthorizationGrant]s in the list and returns the inserted rows.
  ///
  /// The returned [ConsumedProjectAuthorizationGrant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ConsumedProjectAuthorizationGrant>> insert(
    _i1.DatabaseSession session,
    List<ConsumedProjectAuthorizationGrant> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ConsumedProjectAuthorizationGrant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ConsumedProjectAuthorizationGrant] and returns the inserted row.
  ///
  /// The returned [ConsumedProjectAuthorizationGrant] will have its `id` field set.
  Future<ConsumedProjectAuthorizationGrant> insertRow(
    _i1.DatabaseSession session,
    ConsumedProjectAuthorizationGrant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ConsumedProjectAuthorizationGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ConsumedProjectAuthorizationGrant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ConsumedProjectAuthorizationGrant>> update(
    _i1.DatabaseSession session,
    List<ConsumedProjectAuthorizationGrant> rows, {
    _i1.ColumnSelections<ConsumedProjectAuthorizationGrantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ConsumedProjectAuthorizationGrant>(
      rows,
      columns: columns?.call(ConsumedProjectAuthorizationGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ConsumedProjectAuthorizationGrant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ConsumedProjectAuthorizationGrant> updateRow(
    _i1.DatabaseSession session,
    ConsumedProjectAuthorizationGrant row, {
    _i1.ColumnSelections<ConsumedProjectAuthorizationGrantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ConsumedProjectAuthorizationGrant>(
      row,
      columns: columns?.call(ConsumedProjectAuthorizationGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ConsumedProjectAuthorizationGrant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ConsumedProjectAuthorizationGrant?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<
      ConsumedProjectAuthorizationGrantUpdateTable
    >
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ConsumedProjectAuthorizationGrant>(
      id,
      columnValues: columnValues(
        ConsumedProjectAuthorizationGrant.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [ConsumedProjectAuthorizationGrant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ConsumedProjectAuthorizationGrant>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<
      ConsumedProjectAuthorizationGrantUpdateTable
    >
    columnValues,
    required _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>
    where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumedProjectAuthorizationGrantTable>? orderBy,
    _i1.OrderByListBuilder<ConsumedProjectAuthorizationGrantTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ConsumedProjectAuthorizationGrant>(
      columnValues: columnValues(
        ConsumedProjectAuthorizationGrant.t.updateTable,
      ),
      where: where(ConsumedProjectAuthorizationGrant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ConsumedProjectAuthorizationGrant.t),
      orderByList: orderByList?.call(ConsumedProjectAuthorizationGrant.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ConsumedProjectAuthorizationGrant]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ConsumedProjectAuthorizationGrant>> delete(
    _i1.DatabaseSession session,
    List<ConsumedProjectAuthorizationGrant> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ConsumedProjectAuthorizationGrant>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ConsumedProjectAuthorizationGrant].
  Future<ConsumedProjectAuthorizationGrant> deleteRow(
    _i1.DatabaseSession session,
    ConsumedProjectAuthorizationGrant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ConsumedProjectAuthorizationGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ConsumedProjectAuthorizationGrant>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>
    where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ConsumedProjectAuthorizationGrant>(
      where: where(ConsumedProjectAuthorizationGrant.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ConsumedProjectAuthorizationGrant>(
      where: where?.call(ConsumedProjectAuthorizationGrant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ConsumedProjectAuthorizationGrant] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ConsumedProjectAuthorizationGrantTable>
    where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ConsumedProjectAuthorizationGrant>(
      where: where(ConsumedProjectAuthorizationGrant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
