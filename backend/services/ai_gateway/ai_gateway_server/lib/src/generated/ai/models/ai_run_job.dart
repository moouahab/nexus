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
import '../../ai/models/ai_run_job_status.dart' as _i2;

/// Internal durable payload for an AI run. Cleared when processing finishes.
abstract class AiRunJob
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  AiRunJob._({
    this.id,
    required this.runId,
    required this.inputJson,
    this.bearerToken,
    this.idempotencyKey,
    required this.requesterScope,
    required this.tenantPartyId,
    _i2.AiRunJobStatus? status,
    int? attemptCount,
    this.claimedAt,
    this.completedAt,
    this.lastErrorCode,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.AiRunJobStatus.queued,
       attemptCount = attemptCount ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory AiRunJob({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String inputJson,
    String? bearerToken,
    String? idempotencyKey,
    required String requesterScope,
    required _i1.UuidValue tenantPartyId,
    _i2.AiRunJobStatus? status,
    int? attemptCount,
    DateTime? claimedAt,
    DateTime? completedAt,
    String? lastErrorCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AiRunJobImpl;

  factory AiRunJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiRunJob(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
      inputJson: jsonSerialization['inputJson'] as String,
      bearerToken: jsonSerialization['bearerToken'] as String?,
      idempotencyKey: jsonSerialization['idempotencyKey'] as String?,
      requesterScope: jsonSerialization['requesterScope'] as String,
      tenantPartyId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantPartyId'],
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.AiRunJobStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      attemptCount: jsonSerialization['attemptCount'] as int?,
      claimedAt: jsonSerialization['claimedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['claimedAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      lastErrorCode: jsonSerialization['lastErrorCode'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AiRunJobTable();

  static const db = AiRunJobRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue runId;

  String inputJson;

  String? bearerToken;

  String? idempotencyKey;

  String requesterScope;

  _i1.UuidValue tenantPartyId;

  _i2.AiRunJobStatus status;

  int attemptCount;

  DateTime? claimedAt;

  DateTime? completedAt;

  String? lastErrorCode;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AiRunJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiRunJob copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? runId,
    String? inputJson,
    String? bearerToken,
    String? idempotencyKey,
    String? requesterScope,
    _i1.UuidValue? tenantPartyId,
    _i2.AiRunJobStatus? status,
    int? attemptCount,
    DateTime? claimedAt,
    DateTime? completedAt,
    String? lastErrorCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiRunJob',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'inputJson': inputJson,
      if (bearerToken != null) 'bearerToken': bearerToken,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      'requesterScope': requesterScope,
      'tenantPartyId': tenantPartyId.toJson(),
      'status': status.toJson(),
      'attemptCount': attemptCount,
      if (claimedAt != null) 'claimedAt': claimedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (lastErrorCode != null) 'lastErrorCode': lastErrorCode,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AiRunJobInclude include() {
    return AiRunJobInclude._();
  }

  static AiRunJobIncludeList includeList({
    _i1.WhereExpressionBuilder<AiRunJobTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiRunJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiRunJobTable>? orderByList,
    AiRunJobInclude? include,
  }) {
    return AiRunJobIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiRunJob.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AiRunJob.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiRunJobImpl extends AiRunJob {
  _AiRunJobImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String inputJson,
    String? bearerToken,
    String? idempotencyKey,
    required String requesterScope,
    required _i1.UuidValue tenantPartyId,
    _i2.AiRunJobStatus? status,
    int? attemptCount,
    DateTime? claimedAt,
    DateTime? completedAt,
    String? lastErrorCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         runId: runId,
         inputJson: inputJson,
         bearerToken: bearerToken,
         idempotencyKey: idempotencyKey,
         requesterScope: requesterScope,
         tenantPartyId: tenantPartyId,
         status: status,
         attemptCount: attemptCount,
         claimedAt: claimedAt,
         completedAt: completedAt,
         lastErrorCode: lastErrorCode,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AiRunJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiRunJob copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? runId,
    String? inputJson,
    Object? bearerToken = _Undefined,
    Object? idempotencyKey = _Undefined,
    String? requesterScope,
    _i1.UuidValue? tenantPartyId,
    _i2.AiRunJobStatus? status,
    int? attemptCount,
    Object? claimedAt = _Undefined,
    Object? completedAt = _Undefined,
    Object? lastErrorCode = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return AiRunJob(
      id: id is _i1.UuidValue? ? id : this.id,
      runId: runId ?? this.runId,
      inputJson: inputJson ?? this.inputJson,
      bearerToken: bearerToken is String? ? bearerToken : this.bearerToken,
      idempotencyKey: idempotencyKey is String?
          ? idempotencyKey
          : this.idempotencyKey,
      requesterScope: requesterScope ?? this.requesterScope,
      tenantPartyId: tenantPartyId ?? this.tenantPartyId,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      claimedAt: claimedAt is DateTime? ? claimedAt : this.claimedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      lastErrorCode: lastErrorCode is String?
          ? lastErrorCode
          : this.lastErrorCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class AiRunJobUpdateTable extends _i1.UpdateTable<AiRunJobTable> {
  AiRunJobUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> runId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.runId, value);

  _i1.ColumnValue<String, String> inputJson(String value) =>
      _i1.ColumnValue(table.inputJson, value);

  _i1.ColumnValue<String, String> bearerToken(String? value) =>
      _i1.ColumnValue(table.bearerToken, value);

  _i1.ColumnValue<String, String> idempotencyKey(String? value) =>
      _i1.ColumnValue(table.idempotencyKey, value);

  _i1.ColumnValue<String, String> requesterScope(String value) =>
      _i1.ColumnValue(table.requesterScope, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> tenantPartyId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(table.tenantPartyId, value);

  _i1.ColumnValue<_i2.AiRunJobStatus, _i2.AiRunJobStatus> status(
    _i2.AiRunJobStatus value,
  ) => _i1.ColumnValue(table.status, value);

  _i1.ColumnValue<int, int> attemptCount(int value) =>
      _i1.ColumnValue(table.attemptCount, value);

  _i1.ColumnValue<DateTime, DateTime> claimedAt(DateTime? value) =>
      _i1.ColumnValue(table.claimedAt, value);

  _i1.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _i1.ColumnValue(table.completedAt, value);

  _i1.ColumnValue<String, String> lastErrorCode(String? value) =>
      _i1.ColumnValue(table.lastErrorCode, value);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(table.createdAt, value);

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(table.updatedAt, value);
}

class AiRunJobTable extends _i1.Table<_i1.UuidValue?> {
  AiRunJobTable({super.tableRelation}) : super(tableName: 'ai_run_job') {
    updateTable = AiRunJobUpdateTable(this);
    runId = _i1.ColumnUuid('runId', this);
    inputJson = _i1.ColumnString('inputJson', this);
    bearerToken = _i1.ColumnString('bearerToken', this);
    idempotencyKey = _i1.ColumnString('idempotencyKey', this);
    requesterScope = _i1.ColumnString('requesterScope', this);
    tenantPartyId = _i1.ColumnUuid('tenantPartyId', this);
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    attemptCount = _i1.ColumnInt('attemptCount', this, hasDefault: true);
    claimedAt = _i1.ColumnDateTime('claimedAt', this);
    completedAt = _i1.ColumnDateTime('completedAt', this);
    lastErrorCode = _i1.ColumnString('lastErrorCode', this);
    createdAt = _i1.ColumnDateTime('createdAt', this, hasDefault: true);
    updatedAt = _i1.ColumnDateTime('updatedAt', this);
  }

  late final AiRunJobUpdateTable updateTable;

  late final _i1.ColumnUuid runId;

  late final _i1.ColumnString inputJson;

  late final _i1.ColumnString bearerToken;

  late final _i1.ColumnString idempotencyKey;

  late final _i1.ColumnString requesterScope;

  late final _i1.ColumnUuid tenantPartyId;

  late final _i1.ColumnEnum<_i2.AiRunJobStatus> status;

  late final _i1.ColumnInt attemptCount;

  late final _i1.ColumnDateTime claimedAt;

  late final _i1.ColumnDateTime completedAt;

  late final _i1.ColumnString lastErrorCode;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    runId,
    inputJson,
    bearerToken,
    idempotencyKey,
    requesterScope,
    tenantPartyId,
    status,
    attemptCount,
    claimedAt,
    completedAt,
    lastErrorCode,
    createdAt,
    updatedAt,
  ];
}

class AiRunJobInclude extends _i1.IncludeObject {
  AiRunJobInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiRunJob.t;
}

class AiRunJobIncludeList extends _i1.IncludeList {
  AiRunJobIncludeList._({
    _i1.WhereExpressionBuilder<AiRunJobTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AiRunJob.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiRunJob.t;
}

class AiRunJobRepository {
  const AiRunJobRepository._();

  /// Returns a list of [AiRunJob]s matching the given query parameters.
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
  Future<List<AiRunJob>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiRunJobTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiRunJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiRunJobTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AiRunJob>(
      where: where?.call(AiRunJob.t),
      orderBy: orderBy?.call(AiRunJob.t),
      orderByList: orderByList?.call(AiRunJob.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AiRunJob] matching the given query parameters.
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
  Future<AiRunJob?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiRunJobTable>? where,
    int? offset,
    _i1.OrderByBuilder<AiRunJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiRunJobTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AiRunJob>(
      where: where?.call(AiRunJob.t),
      orderBy: orderBy?.call(AiRunJob.t),
      orderByList: orderByList?.call(AiRunJob.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AiRunJob] by its [id] or null if no such row exists.
  Future<AiRunJob?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AiRunJob>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AiRunJob]s in the list and returns the inserted rows.
  ///
  /// The returned [AiRunJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AiRunJob>> insert(
    _i1.DatabaseSession session,
    List<AiRunJob> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AiRunJob>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AiRunJob] and returns the inserted row.
  ///
  /// The returned [AiRunJob] will have its `id` field set.
  Future<AiRunJob> insertRow(
    _i1.DatabaseSession session,
    AiRunJob row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AiRunJob>(row, transaction: transaction);
  }

  /// Updates all [AiRunJob]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AiRunJob>> update(
    _i1.DatabaseSession session,
    List<AiRunJob> rows, {
    _i1.ColumnSelections<AiRunJobTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AiRunJob>(
      rows,
      columns: columns?.call(AiRunJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiRunJob]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AiRunJob> updateRow(
    _i1.DatabaseSession session,
    AiRunJob row, {
    _i1.ColumnSelections<AiRunJobTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AiRunJob>(
      row,
      columns: columns?.call(AiRunJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiRunJob] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AiRunJob?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AiRunJobUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AiRunJob>(
      id,
      columnValues: columnValues(AiRunJob.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AiRunJob]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AiRunJob>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AiRunJobUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AiRunJobTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiRunJobTable>? orderBy,
    _i1.OrderByListBuilder<AiRunJobTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AiRunJob>(
      columnValues: columnValues(AiRunJob.t.updateTable),
      where: where(AiRunJob.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiRunJob.t),
      orderByList: orderByList?.call(AiRunJob.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AiRunJob]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AiRunJob>> delete(
    _i1.DatabaseSession session,
    List<AiRunJob> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AiRunJob>(rows, transaction: transaction);
  }

  /// Deletes a single [AiRunJob].
  Future<AiRunJob> deleteRow(
    _i1.DatabaseSession session,
    AiRunJob row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AiRunJob>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AiRunJob>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiRunJobTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AiRunJob>(
      where: where(AiRunJob.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiRunJobTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AiRunJob>(
      where: where?.call(AiRunJob.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AiRunJob] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiRunJobTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AiRunJob>(
      where: where(AiRunJob.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
