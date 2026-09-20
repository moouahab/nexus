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

/// A structured conclusion produced during a reasoning run.
/// `statement` contains the claim, never the user's original prompt.
abstract class AiClaim
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  AiClaim._({
    this.id,
    required this.runId,
    required this.statement,
    required this.claimType,
    required this.confidence,
    required this.verificationDecision,
    required this.iteration,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AiClaim({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String statement,
    required String claimType,
    required String confidence,
    required String verificationDecision,
    required int iteration,
    DateTime? createdAt,
  }) = _AiClaimImpl;

  factory AiClaim.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiClaim(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
      statement: jsonSerialization['statement'] as String,
      claimType: jsonSerialization['claimType'] as String,
      confidence: jsonSerialization['confidence'] as String,
      verificationDecision: jsonSerialization['verificationDecision'] as String,
      iteration: jsonSerialization['iteration'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AiClaimTable();

  static const db = AiClaimRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue runId;

  String statement;

  String claimType;

  String confidence;

  String verificationDecision;

  int iteration;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AiClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiClaim copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? runId,
    String? statement,
    String? claimType,
    String? confidence,
    String? verificationDecision,
    int? iteration,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiClaim',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'statement': statement,
      'claimType': claimType,
      'confidence': confidence,
      'verificationDecision': verificationDecision,
      'iteration': iteration,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AiClaim',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'statement': statement,
      'claimType': claimType,
      'confidence': confidence,
      'verificationDecision': verificationDecision,
      'iteration': iteration,
      'createdAt': createdAt.toJson(),
    };
  }

  static AiClaimInclude include() {
    return AiClaimInclude._();
  }

  static AiClaimIncludeList includeList({
    _i1.WhereExpressionBuilder<AiClaimTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiClaimTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiClaimTable>? orderByList,
    AiClaimInclude? include,
  }) {
    return AiClaimIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiClaim.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AiClaim.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiClaimImpl extends AiClaim {
  _AiClaimImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String statement,
    required String claimType,
    required String confidence,
    required String verificationDecision,
    required int iteration,
    DateTime? createdAt,
  }) : super._(
         id: id,
         runId: runId,
         statement: statement,
         claimType: claimType,
         confidence: confidence,
         verificationDecision: verificationDecision,
         iteration: iteration,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AiClaim]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiClaim copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? runId,
    String? statement,
    String? claimType,
    String? confidence,
    String? verificationDecision,
    int? iteration,
    DateTime? createdAt,
  }) {
    return AiClaim(
      id: id is _i1.UuidValue? ? id : this.id,
      runId: runId ?? this.runId,
      statement: statement ?? this.statement,
      claimType: claimType ?? this.claimType,
      confidence: confidence ?? this.confidence,
      verificationDecision: verificationDecision ?? this.verificationDecision,
      iteration: iteration ?? this.iteration,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AiClaimUpdateTable extends _i1.UpdateTable<AiClaimTable> {
  AiClaimUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> runId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.runId,
        value,
      );

  _i1.ColumnValue<String, String> statement(String value) => _i1.ColumnValue(
    table.statement,
    value,
  );

  _i1.ColumnValue<String, String> claimType(String value) => _i1.ColumnValue(
    table.claimType,
    value,
  );

  _i1.ColumnValue<String, String> confidence(String value) => _i1.ColumnValue(
    table.confidence,
    value,
  );

  _i1.ColumnValue<String, String> verificationDecision(String value) =>
      _i1.ColumnValue(
        table.verificationDecision,
        value,
      );

  _i1.ColumnValue<int, int> iteration(int value) => _i1.ColumnValue(
    table.iteration,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class AiClaimTable extends _i1.Table<_i1.UuidValue?> {
  AiClaimTable({super.tableRelation}) : super(tableName: 'ai_claim') {
    updateTable = AiClaimUpdateTable(this);
    runId = _i1.ColumnUuid(
      'runId',
      this,
    );
    statement = _i1.ColumnString(
      'statement',
      this,
    );
    claimType = _i1.ColumnString(
      'claimType',
      this,
    );
    confidence = _i1.ColumnString(
      'confidence',
      this,
    );
    verificationDecision = _i1.ColumnString(
      'verificationDecision',
      this,
    );
    iteration = _i1.ColumnInt(
      'iteration',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AiClaimUpdateTable updateTable;

  late final _i1.ColumnUuid runId;

  late final _i1.ColumnString statement;

  late final _i1.ColumnString claimType;

  late final _i1.ColumnString confidence;

  late final _i1.ColumnString verificationDecision;

  late final _i1.ColumnInt iteration;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    runId,
    statement,
    claimType,
    confidence,
    verificationDecision,
    iteration,
    createdAt,
  ];
}

class AiClaimInclude extends _i1.IncludeObject {
  AiClaimInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiClaim.t;
}

class AiClaimIncludeList extends _i1.IncludeList {
  AiClaimIncludeList._({
    _i1.WhereExpressionBuilder<AiClaimTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AiClaim.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiClaim.t;
}

class AiClaimRepository {
  const AiClaimRepository._();

  /// Returns a list of [AiClaim]s matching the given query parameters.
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
  Future<List<AiClaim>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiClaimTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiClaimTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiClaimTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AiClaim>(
      where: where?.call(AiClaim.t),
      orderBy: orderBy?.call(AiClaim.t),
      orderByList: orderByList?.call(AiClaim.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AiClaim] matching the given query parameters.
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
  Future<AiClaim?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiClaimTable>? where,
    int? offset,
    _i1.OrderByBuilder<AiClaimTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiClaimTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AiClaim>(
      where: where?.call(AiClaim.t),
      orderBy: orderBy?.call(AiClaim.t),
      orderByList: orderByList?.call(AiClaim.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AiClaim] by its [id] or null if no such row exists.
  Future<AiClaim?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AiClaim>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AiClaim]s in the list and returns the inserted rows.
  ///
  /// The returned [AiClaim]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AiClaim>> insert(
    _i1.DatabaseSession session,
    List<AiClaim> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AiClaim>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AiClaim] and returns the inserted row.
  ///
  /// The returned [AiClaim] will have its `id` field set.
  Future<AiClaim> insertRow(
    _i1.DatabaseSession session,
    AiClaim row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AiClaim>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AiClaim]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AiClaim>> update(
    _i1.DatabaseSession session,
    List<AiClaim> rows, {
    _i1.ColumnSelections<AiClaimTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AiClaim>(
      rows,
      columns: columns?.call(AiClaim.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiClaim]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AiClaim> updateRow(
    _i1.DatabaseSession session,
    AiClaim row, {
    _i1.ColumnSelections<AiClaimTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AiClaim>(
      row,
      columns: columns?.call(AiClaim.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiClaim] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AiClaim?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AiClaimUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AiClaim>(
      id,
      columnValues: columnValues(AiClaim.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AiClaim]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AiClaim>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AiClaimUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AiClaimTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiClaimTable>? orderBy,
    _i1.OrderByListBuilder<AiClaimTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AiClaim>(
      columnValues: columnValues(AiClaim.t.updateTable),
      where: where(AiClaim.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiClaim.t),
      orderByList: orderByList?.call(AiClaim.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AiClaim]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AiClaim>> delete(
    _i1.DatabaseSession session,
    List<AiClaim> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AiClaim>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AiClaim].
  Future<AiClaim> deleteRow(
    _i1.DatabaseSession session,
    AiClaim row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AiClaim>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AiClaim>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiClaimTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AiClaim>(
      where: where(AiClaim.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiClaimTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AiClaim>(
      where: where?.call(AiClaim.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AiClaim] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiClaimTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AiClaim>(
      where: where(AiClaim.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
