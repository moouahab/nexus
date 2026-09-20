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

/// Immutable reference to evidence used by a reasoning run.
/// The source payload is not duplicated; `summary` is a bounded normalized view.
abstract class AiEvidence
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  AiEvidence._({
    this.id,
    required this.runId,
    required this.sourceService,
    required this.resourceType,
    required this.resourceId,
    this.summary,
    required this.reliability,
    required this.freshness,
    this.observedAt,
    DateTime? collectedAt,
  }) : collectedAt = collectedAt ?? DateTime.now();

  factory AiEvidence({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String sourceService,
    required String resourceType,
    required String resourceId,
    String? summary,
    required double reliability,
    required double freshness,
    DateTime? observedAt,
    DateTime? collectedAt,
  }) = _AiEvidenceImpl;

  factory AiEvidence.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiEvidence(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      runId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['runId']),
      sourceService: jsonSerialization['sourceService'] as String,
      resourceType: jsonSerialization['resourceType'] as String,
      resourceId: jsonSerialization['resourceId'] as String,
      summary: jsonSerialization['summary'] as String?,
      reliability: (jsonSerialization['reliability'] as num).toDouble(),
      freshness: (jsonSerialization['freshness'] as num).toDouble(),
      observedAt: jsonSerialization['observedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['observedAt']),
      collectedAt: jsonSerialization['collectedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['collectedAt'],
            ),
    );
  }

  static final t = AiEvidenceTable();

  static const db = AiEvidenceRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue runId;

  String sourceService;

  String resourceType;

  String resourceId;

  String? summary;

  double reliability;

  double freshness;

  DateTime? observedAt;

  DateTime collectedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AiEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiEvidence copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? runId,
    String? sourceService,
    String? resourceType,
    String? resourceId,
    String? summary,
    double? reliability,
    double? freshness,
    DateTime? observedAt,
    DateTime? collectedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiEvidence',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'sourceService': sourceService,
      'resourceType': resourceType,
      'resourceId': resourceId,
      if (summary != null) 'summary': summary,
      'reliability': reliability,
      'freshness': freshness,
      if (observedAt != null) 'observedAt': observedAt?.toJson(),
      'collectedAt': collectedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AiEvidence',
      if (id != null) 'id': id?.toJson(),
      'runId': runId.toJson(),
      'sourceService': sourceService,
      'resourceType': resourceType,
      'resourceId': resourceId,
      if (summary != null) 'summary': summary,
      'reliability': reliability,
      'freshness': freshness,
      if (observedAt != null) 'observedAt': observedAt?.toJson(),
      'collectedAt': collectedAt.toJson(),
    };
  }

  static AiEvidenceInclude include() {
    return AiEvidenceInclude._();
  }

  static AiEvidenceIncludeList includeList({
    _i1.WhereExpressionBuilder<AiEvidenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiEvidenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiEvidenceTable>? orderByList,
    AiEvidenceInclude? include,
  }) {
    return AiEvidenceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiEvidence.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AiEvidence.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiEvidenceImpl extends AiEvidence {
  _AiEvidenceImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue runId,
    required String sourceService,
    required String resourceType,
    required String resourceId,
    String? summary,
    required double reliability,
    required double freshness,
    DateTime? observedAt,
    DateTime? collectedAt,
  }) : super._(
         id: id,
         runId: runId,
         sourceService: sourceService,
         resourceType: resourceType,
         resourceId: resourceId,
         summary: summary,
         reliability: reliability,
         freshness: freshness,
         observedAt: observedAt,
         collectedAt: collectedAt,
       );

  /// Returns a shallow copy of this [AiEvidence]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiEvidence copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? runId,
    String? sourceService,
    String? resourceType,
    String? resourceId,
    Object? summary = _Undefined,
    double? reliability,
    double? freshness,
    Object? observedAt = _Undefined,
    DateTime? collectedAt,
  }) {
    return AiEvidence(
      id: id is _i1.UuidValue? ? id : this.id,
      runId: runId ?? this.runId,
      sourceService: sourceService ?? this.sourceService,
      resourceType: resourceType ?? this.resourceType,
      resourceId: resourceId ?? this.resourceId,
      summary: summary is String? ? summary : this.summary,
      reliability: reliability ?? this.reliability,
      freshness: freshness ?? this.freshness,
      observedAt: observedAt is DateTime? ? observedAt : this.observedAt,
      collectedAt: collectedAt ?? this.collectedAt,
    );
  }
}

class AiEvidenceUpdateTable extends _i1.UpdateTable<AiEvidenceTable> {
  AiEvidenceUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> runId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.runId,
        value,
      );

  _i1.ColumnValue<String, String> sourceService(String value) =>
      _i1.ColumnValue(
        table.sourceService,
        value,
      );

  _i1.ColumnValue<String, String> resourceType(String value) => _i1.ColumnValue(
    table.resourceType,
    value,
  );

  _i1.ColumnValue<String, String> resourceId(String value) => _i1.ColumnValue(
    table.resourceId,
    value,
  );

  _i1.ColumnValue<String, String> summary(String? value) => _i1.ColumnValue(
    table.summary,
    value,
  );

  _i1.ColumnValue<double, double> reliability(double value) => _i1.ColumnValue(
    table.reliability,
    value,
  );

  _i1.ColumnValue<double, double> freshness(double value) => _i1.ColumnValue(
    table.freshness,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> observedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.observedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> collectedAt(DateTime value) =>
      _i1.ColumnValue(
        table.collectedAt,
        value,
      );
}

class AiEvidenceTable extends _i1.Table<_i1.UuidValue?> {
  AiEvidenceTable({super.tableRelation}) : super(tableName: 'ai_evidence') {
    updateTable = AiEvidenceUpdateTable(this);
    runId = _i1.ColumnUuid(
      'runId',
      this,
    );
    sourceService = _i1.ColumnString(
      'sourceService',
      this,
    );
    resourceType = _i1.ColumnString(
      'resourceType',
      this,
    );
    resourceId = _i1.ColumnString(
      'resourceId',
      this,
    );
    summary = _i1.ColumnString(
      'summary',
      this,
    );
    reliability = _i1.ColumnDouble(
      'reliability',
      this,
    );
    freshness = _i1.ColumnDouble(
      'freshness',
      this,
    );
    observedAt = _i1.ColumnDateTime(
      'observedAt',
      this,
    );
    collectedAt = _i1.ColumnDateTime(
      'collectedAt',
      this,
      hasDefault: true,
    );
  }

  late final AiEvidenceUpdateTable updateTable;

  late final _i1.ColumnUuid runId;

  late final _i1.ColumnString sourceService;

  late final _i1.ColumnString resourceType;

  late final _i1.ColumnString resourceId;

  late final _i1.ColumnString summary;

  late final _i1.ColumnDouble reliability;

  late final _i1.ColumnDouble freshness;

  late final _i1.ColumnDateTime observedAt;

  late final _i1.ColumnDateTime collectedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    runId,
    sourceService,
    resourceType,
    resourceId,
    summary,
    reliability,
    freshness,
    observedAt,
    collectedAt,
  ];
}

class AiEvidenceInclude extends _i1.IncludeObject {
  AiEvidenceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiEvidence.t;
}

class AiEvidenceIncludeList extends _i1.IncludeList {
  AiEvidenceIncludeList._({
    _i1.WhereExpressionBuilder<AiEvidenceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AiEvidence.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiEvidence.t;
}

class AiEvidenceRepository {
  const AiEvidenceRepository._();

  /// Returns a list of [AiEvidence]s matching the given query parameters.
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
  Future<List<AiEvidence>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiEvidenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiEvidenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiEvidenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AiEvidence>(
      where: where?.call(AiEvidence.t),
      orderBy: orderBy?.call(AiEvidence.t),
      orderByList: orderByList?.call(AiEvidence.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AiEvidence] matching the given query parameters.
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
  Future<AiEvidence?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiEvidenceTable>? where,
    int? offset,
    _i1.OrderByBuilder<AiEvidenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiEvidenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AiEvidence>(
      where: where?.call(AiEvidence.t),
      orderBy: orderBy?.call(AiEvidence.t),
      orderByList: orderByList?.call(AiEvidence.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AiEvidence] by its [id] or null if no such row exists.
  Future<AiEvidence?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AiEvidence>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AiEvidence]s in the list and returns the inserted rows.
  ///
  /// The returned [AiEvidence]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AiEvidence>> insert(
    _i1.DatabaseSession session,
    List<AiEvidence> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AiEvidence>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AiEvidence] and returns the inserted row.
  ///
  /// The returned [AiEvidence] will have its `id` field set.
  Future<AiEvidence> insertRow(
    _i1.DatabaseSession session,
    AiEvidence row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AiEvidence>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AiEvidence]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AiEvidence>> update(
    _i1.DatabaseSession session,
    List<AiEvidence> rows, {
    _i1.ColumnSelections<AiEvidenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AiEvidence>(
      rows,
      columns: columns?.call(AiEvidence.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiEvidence]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AiEvidence> updateRow(
    _i1.DatabaseSession session,
    AiEvidence row, {
    _i1.ColumnSelections<AiEvidenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AiEvidence>(
      row,
      columns: columns?.call(AiEvidence.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiEvidence] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AiEvidence?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AiEvidenceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AiEvidence>(
      id,
      columnValues: columnValues(AiEvidence.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AiEvidence]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AiEvidence>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AiEvidenceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AiEvidenceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiEvidenceTable>? orderBy,
    _i1.OrderByListBuilder<AiEvidenceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AiEvidence>(
      columnValues: columnValues(AiEvidence.t.updateTable),
      where: where(AiEvidence.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiEvidence.t),
      orderByList: orderByList?.call(AiEvidence.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AiEvidence]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AiEvidence>> delete(
    _i1.DatabaseSession session,
    List<AiEvidence> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AiEvidence>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AiEvidence].
  Future<AiEvidence> deleteRow(
    _i1.DatabaseSession session,
    AiEvidence row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AiEvidence>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AiEvidence>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiEvidenceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AiEvidence>(
      where: where(AiEvidence.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiEvidenceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AiEvidence>(
      where: where?.call(AiEvidence.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AiEvidence] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiEvidenceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AiEvidence>(
      where: where(AiEvidence.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
