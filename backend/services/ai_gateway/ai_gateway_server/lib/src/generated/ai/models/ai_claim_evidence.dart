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

/// Many-to-many association recording how evidence relates to a claim.
abstract class AiClaimEvidence
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  AiClaimEvidence._({
    this.id,
    required this.runId,
    required this.claimId,
    required this.evidenceId,
    required this.relation,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AiClaimEvidence({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required _i1.UuidValue claimId,
    required _i1.UuidValue evidenceId,
    required String relation,
    DateTime? createdAt,
  }) = _AiClaimEvidenceImpl;

  factory AiClaimEvidence.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiClaimEvidence(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
      claimId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['claimId'],
      ),
      evidenceId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['evidenceId'],
      ),
      relation: jsonSerialization['relation'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AiClaimEvidenceTable();

  static const db = AiClaimEvidenceRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue runId;

  _i1.UuidValue claimId;

  _i1.UuidValue evidenceId;

  String relation;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AiClaimEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiClaimEvidence copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? runId,
    _i1.UuidValue? claimId,
    _i1.UuidValue? evidenceId,
    String? relation,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiClaimEvidence',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'claimId': claimId.toJson(),
      'evidenceId': evidenceId.toJson(),
      'relation': relation,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AiClaimEvidence',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'claimId': claimId.toJson(),
      'evidenceId': evidenceId.toJson(),
      'relation': relation,
      'createdAt': createdAt.toJson(),
    };
  }

  static AiClaimEvidenceInclude include() {
    return AiClaimEvidenceInclude._();
  }

  static AiClaimEvidenceIncludeList includeList({
    _i1.WhereExpressionBuilder<AiClaimEvidenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiClaimEvidenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiClaimEvidenceTable>? orderByList,
    AiClaimEvidenceInclude? include,
  }) {
    return AiClaimEvidenceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiClaimEvidence.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AiClaimEvidence.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiClaimEvidenceImpl extends AiClaimEvidence {
  _AiClaimEvidenceImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required _i1.UuidValue claimId,
    required _i1.UuidValue evidenceId,
    required String relation,
    DateTime? createdAt,
  }) : super._(
         id: id,
         runId: runId,
         claimId: claimId,
         evidenceId: evidenceId,
         relation: relation,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AiClaimEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiClaimEvidence copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? runId,
    _i1.UuidValue? claimId,
    _i1.UuidValue? evidenceId,
    String? relation,
    DateTime? createdAt,
  }) {
    return AiClaimEvidence(
      id: id is _i1.UuidValue? ? id : this.id,
      runId: runId ?? this.runId,
      claimId: claimId ?? this.claimId,
      evidenceId: evidenceId ?? this.evidenceId,
      relation: relation ?? this.relation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AiClaimEvidenceUpdateTable extends _i1.UpdateTable<AiClaimEvidenceTable> {
  AiClaimEvidenceUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> runId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.runId, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> claimId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.claimId, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> evidenceId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(table.evidenceId, value);

  _i1.ColumnValue<String, String> relation(String value) =>
      _i1.ColumnValue(table.relation, value);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(table.createdAt, value);
}

class AiClaimEvidenceTable extends _i1.Table<_i1.UuidValue?> {
  AiClaimEvidenceTable({super.tableRelation})
    : super(tableName: 'ai_claim_evidence') {
    updateTable = AiClaimEvidenceUpdateTable(this);
    runId = _i1.ColumnUuid('runId', this);
    claimId = _i1.ColumnUuid('claimId', this);
    evidenceId = _i1.ColumnUuid('evidenceId', this);
    relation = _i1.ColumnString('relation', this);
    createdAt = _i1.ColumnDateTime('createdAt', this, hasDefault: true);
  }

  late final AiClaimEvidenceUpdateTable updateTable;

  late final _i1.ColumnUuid runId;

  late final _i1.ColumnUuid claimId;

  late final _i1.ColumnUuid evidenceId;

  late final _i1.ColumnString relation;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    runId,
    claimId,
    evidenceId,
    relation,
    createdAt,
  ];
}

class AiClaimEvidenceInclude extends _i1.IncludeObject {
  AiClaimEvidenceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiClaimEvidence.t;
}

class AiClaimEvidenceIncludeList extends _i1.IncludeList {
  AiClaimEvidenceIncludeList._({
    _i1.WhereExpressionBuilder<AiClaimEvidenceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AiClaimEvidence.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiClaimEvidence.t;
}

class AiClaimEvidenceRepository {
  const AiClaimEvidenceRepository._();

  /// Returns a list of [AiClaimEvidence]s matching the given query parameters.
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
  Future<List<AiClaimEvidence>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiClaimEvidenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiClaimEvidenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiClaimEvidenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AiClaimEvidence>(
      where: where?.call(AiClaimEvidence.t),
      orderBy: orderBy?.call(AiClaimEvidence.t),
      orderByList: orderByList?.call(AiClaimEvidence.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AiClaimEvidence] matching the given query parameters.
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
  Future<AiClaimEvidence?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiClaimEvidenceTable>? where,
    int? offset,
    _i1.OrderByBuilder<AiClaimEvidenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiClaimEvidenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AiClaimEvidence>(
      where: where?.call(AiClaimEvidence.t),
      orderBy: orderBy?.call(AiClaimEvidence.t),
      orderByList: orderByList?.call(AiClaimEvidence.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AiClaimEvidence] by its [id] or null if no such row exists.
  Future<AiClaimEvidence?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AiClaimEvidence>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AiClaimEvidence]s in the list and returns the inserted rows.
  ///
  /// The returned [AiClaimEvidence]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AiClaimEvidence>> insert(
    _i1.DatabaseSession session,
    List<AiClaimEvidence> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AiClaimEvidence>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AiClaimEvidence] and returns the inserted row.
  ///
  /// The returned [AiClaimEvidence] will have its `id` field set.
  Future<AiClaimEvidence> insertRow(
    _i1.DatabaseSession session,
    AiClaimEvidence row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AiClaimEvidence>(row, transaction: transaction);
  }

  /// Updates all [AiClaimEvidence]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AiClaimEvidence>> update(
    _i1.DatabaseSession session,
    List<AiClaimEvidence> rows, {
    _i1.ColumnSelections<AiClaimEvidenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AiClaimEvidence>(
      rows,
      columns: columns?.call(AiClaimEvidence.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiClaimEvidence]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AiClaimEvidence> updateRow(
    _i1.DatabaseSession session,
    AiClaimEvidence row, {
    _i1.ColumnSelections<AiClaimEvidenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AiClaimEvidence>(
      row,
      columns: columns?.call(AiClaimEvidence.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiClaimEvidence] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AiClaimEvidence?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AiClaimEvidenceUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AiClaimEvidence>(
      id,
      columnValues: columnValues(AiClaimEvidence.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AiClaimEvidence]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AiClaimEvidence>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AiClaimEvidenceUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<AiClaimEvidenceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiClaimEvidenceTable>? orderBy,
    _i1.OrderByListBuilder<AiClaimEvidenceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AiClaimEvidence>(
      columnValues: columnValues(AiClaimEvidence.t.updateTable),
      where: where(AiClaimEvidence.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiClaimEvidence.t),
      orderByList: orderByList?.call(AiClaimEvidence.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AiClaimEvidence]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AiClaimEvidence>> delete(
    _i1.DatabaseSession session,
    List<AiClaimEvidence> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AiClaimEvidence>(rows, transaction: transaction);
  }

  /// Deletes a single [AiClaimEvidence].
  Future<AiClaimEvidence> deleteRow(
    _i1.DatabaseSession session,
    AiClaimEvidence row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AiClaimEvidence>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AiClaimEvidence>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiClaimEvidenceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AiClaimEvidence>(
      where: where(AiClaimEvidence.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiClaimEvidenceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AiClaimEvidence>(
      where: where?.call(AiClaimEvidence.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AiClaimEvidence] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiClaimEvidenceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AiClaimEvidence>(
      where: where(AiClaimEvidence.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
