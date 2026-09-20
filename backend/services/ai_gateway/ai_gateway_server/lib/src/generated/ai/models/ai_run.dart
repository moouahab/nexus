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
import '../../ai/models/ai_run_status.dart' as _i2;

/// Audit-safe run metadata. Prompt and provider credentials are deliberately not stored.
abstract class AiRun
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  AiRun._({
    this.id,
    required this.requestId,
    required this.projectId,
    required this.tenantPartyId,
    this.missionId,
    required this.capability,
    _i2.AiRunStatus? status,
    this.requesterIdentityId,
    this.requesterService,
    this.failureCode,
    this.provider,
    this.model,
    this.outputText,
    this.reasoningLevel,
    this.currentIteration,
    this.maxIterations,
    bool? validated,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.AiRunStatus.queued,
       validated = validated ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory AiRun({
    _i1.UuidValue? id,
    required _i1.UuidValue requestId,
    required _i1.UuidValue projectId,
    required _i1.UuidValue tenantPartyId,
    _i1.UuidValue? missionId,
    required String capability,
    _i2.AiRunStatus? status,
    _i1.UuidValue? requesterIdentityId,
    String? requesterService,
    String? failureCode,
    String? provider,
    String? model,
    String? outputText,
    String? reasoningLevel,
    int? currentIteration,
    int? maxIterations,
    bool? validated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AiRunImpl;

  factory AiRun.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiRun(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      requestId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      tenantPartyId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantPartyId'],
      ),
      missionId: jsonSerialization['missionId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['missionId']),
      capability: jsonSerialization['capability'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.AiRunStatus.fromJson((jsonSerialization['status'] as String)),
      requesterIdentityId: jsonSerialization['requesterIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['requesterIdentityId'],
            ),
      requesterService: jsonSerialization['requesterService'] as String?,
      failureCode: jsonSerialization['failureCode'] as String?,
      provider: jsonSerialization['provider'] as String?,
      model: jsonSerialization['model'] as String?,
      outputText: jsonSerialization['outputText'] as String?,
      reasoningLevel: jsonSerialization['reasoningLevel'] as String?,
      currentIteration: jsonSerialization['currentIteration'] as int?,
      maxIterations: jsonSerialization['maxIterations'] as int?,
      validated: jsonSerialization['validated'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['validated']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AiRunTable();

  static const db = AiRunRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue requestId;

  _i1.UuidValue projectId;

  _i1.UuidValue tenantPartyId;

  _i1.UuidValue? missionId;

  String capability;

  _i2.AiRunStatus status;

  _i1.UuidValue? requesterIdentityId;

  String? requesterService;

  String? failureCode;

  String? provider;

  String? model;

  String? outputText;

  String? reasoningLevel;

  int? currentIteration;

  int? maxIterations;

  bool? validated;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AiRun]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiRun copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? requestId,
    _i1.UuidValue? projectId,
    _i1.UuidValue? tenantPartyId,
    _i1.UuidValue? missionId,
    String? capability,
    _i2.AiRunStatus? status,
    _i1.UuidValue? requesterIdentityId,
    String? requesterService,
    String? failureCode,
    String? provider,
    String? model,
    String? outputText,
    String? reasoningLevel,
    int? currentIteration,
    int? maxIterations,
    bool? validated,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiRun',
      if (id != null) 'id': id?.toJson(),
      'requestId': requestId.toJson(),
      'projectId': projectId.toJson(),
      'tenantPartyId': tenantPartyId.toJson(),
      if (missionId != null) 'missionId': missionId?.toJson(),
      'capability': capability,
      'status': status.toJson(),
      if (requesterIdentityId != null)
        'requesterIdentityId': requesterIdentityId?.toJson(),
      if (requesterService != null) 'requesterService': requesterService,
      if (failureCode != null) 'failureCode': failureCode,
      if (provider != null) 'provider': provider,
      if (model != null) 'model': model,
      if (outputText != null) 'outputText': outputText,
      if (reasoningLevel != null) 'reasoningLevel': reasoningLevel,
      if (currentIteration != null) 'currentIteration': currentIteration,
      if (maxIterations != null) 'maxIterations': maxIterations,
      if (validated != null) 'validated': validated,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AiRun',
      if (id != null) 'id': id?.toJson(),
      'requestId': requestId.toJson(),
      'projectId': projectId.toJson(),
      'tenantPartyId': tenantPartyId.toJson(),
      if (missionId != null) 'missionId': missionId?.toJson(),
      'capability': capability,
      'status': status.toJson(),
      if (requesterIdentityId != null)
        'requesterIdentityId': requesterIdentityId?.toJson(),
      if (requesterService != null) 'requesterService': requesterService,
      if (failureCode != null) 'failureCode': failureCode,
      if (provider != null) 'provider': provider,
      if (model != null) 'model': model,
      if (outputText != null) 'outputText': outputText,
      if (reasoningLevel != null) 'reasoningLevel': reasoningLevel,
      if (currentIteration != null) 'currentIteration': currentIteration,
      if (maxIterations != null) 'maxIterations': maxIterations,
      if (validated != null) 'validated': validated,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static AiRunInclude include() {
    return AiRunInclude._();
  }

  static AiRunIncludeList includeList({
    _i1.WhereExpressionBuilder<AiRunTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiRunTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiRunTable>? orderByList,
    AiRunInclude? include,
  }) {
    return AiRunIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiRun.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AiRun.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiRunImpl extends AiRun {
  _AiRunImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue requestId,
    required _i1.UuidValue projectId,
    required _i1.UuidValue tenantPartyId,
    _i1.UuidValue? missionId,
    required String capability,
    _i2.AiRunStatus? status,
    _i1.UuidValue? requesterIdentityId,
    String? requesterService,
    String? failureCode,
    String? provider,
    String? model,
    String? outputText,
    String? reasoningLevel,
    int? currentIteration,
    int? maxIterations,
    bool? validated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         requestId: requestId,
         projectId: projectId,
         tenantPartyId: tenantPartyId,
         missionId: missionId,
         capability: capability,
         status: status,
         requesterIdentityId: requesterIdentityId,
         requesterService: requesterService,
         failureCode: failureCode,
         provider: provider,
         model: model,
         outputText: outputText,
         reasoningLevel: reasoningLevel,
         currentIteration: currentIteration,
         maxIterations: maxIterations,
         validated: validated,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AiRun]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiRun copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? requestId,
    _i1.UuidValue? projectId,
    _i1.UuidValue? tenantPartyId,
    Object? missionId = _Undefined,
    String? capability,
    _i2.AiRunStatus? status,
    Object? requesterIdentityId = _Undefined,
    Object? requesterService = _Undefined,
    Object? failureCode = _Undefined,
    Object? provider = _Undefined,
    Object? model = _Undefined,
    Object? outputText = _Undefined,
    Object? reasoningLevel = _Undefined,
    Object? currentIteration = _Undefined,
    Object? maxIterations = _Undefined,
    Object? validated = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return AiRun(
      id: id is _i1.UuidValue? ? id : this.id,
      requestId: requestId ?? this.requestId,
      projectId: projectId ?? this.projectId,
      tenantPartyId: tenantPartyId ?? this.tenantPartyId,
      missionId: missionId is _i1.UuidValue? ? missionId : this.missionId,
      capability: capability ?? this.capability,
      status: status ?? this.status,
      requesterIdentityId: requesterIdentityId is _i1.UuidValue?
          ? requesterIdentityId
          : this.requesterIdentityId,
      requesterService: requesterService is String?
          ? requesterService
          : this.requesterService,
      failureCode: failureCode is String? ? failureCode : this.failureCode,
      provider: provider is String? ? provider : this.provider,
      model: model is String? ? model : this.model,
      outputText: outputText is String? ? outputText : this.outputText,
      reasoningLevel: reasoningLevel is String?
          ? reasoningLevel
          : this.reasoningLevel,
      currentIteration: currentIteration is int?
          ? currentIteration
          : this.currentIteration,
      maxIterations: maxIterations is int? ? maxIterations : this.maxIterations,
      validated: validated is bool? ? validated : this.validated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class AiRunUpdateTable extends _i1.UpdateTable<AiRunTable> {
  AiRunUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> requestId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.requestId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> tenantPartyId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.tenantPartyId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> missionId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.missionId,
    value,
  );

  _i1.ColumnValue<String, String> capability(String value) => _i1.ColumnValue(
    table.capability,
    value,
  );

  _i1.ColumnValue<_i2.AiRunStatus, _i2.AiRunStatus> status(
    _i2.AiRunStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> requesterIdentityId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.requesterIdentityId,
    value,
  );

  _i1.ColumnValue<String, String> requesterService(String? value) =>
      _i1.ColumnValue(
        table.requesterService,
        value,
      );

  _i1.ColumnValue<String, String> failureCode(String? value) => _i1.ColumnValue(
    table.failureCode,
    value,
  );

  _i1.ColumnValue<String, String> provider(String? value) => _i1.ColumnValue(
    table.provider,
    value,
  );

  _i1.ColumnValue<String, String> model(String? value) => _i1.ColumnValue(
    table.model,
    value,
  );

  _i1.ColumnValue<String, String> outputText(String? value) => _i1.ColumnValue(
    table.outputText,
    value,
  );

  _i1.ColumnValue<String, String> reasoningLevel(String? value) =>
      _i1.ColumnValue(
        table.reasoningLevel,
        value,
      );

  _i1.ColumnValue<int, int> currentIteration(int? value) => _i1.ColumnValue(
    table.currentIteration,
    value,
  );

  _i1.ColumnValue<int, int> maxIterations(int? value) => _i1.ColumnValue(
    table.maxIterations,
    value,
  );

  _i1.ColumnValue<bool, bool> validated(bool? value) => _i1.ColumnValue(
    table.validated,
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

class AiRunTable extends _i1.Table<_i1.UuidValue?> {
  AiRunTable({super.tableRelation}) : super(tableName: 'ai_run') {
    updateTable = AiRunUpdateTable(this);
    requestId = _i1.ColumnUuid(
      'requestId',
      this,
    );
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    tenantPartyId = _i1.ColumnUuid(
      'tenantPartyId',
      this,
    );
    missionId = _i1.ColumnUuid(
      'missionId',
      this,
    );
    capability = _i1.ColumnString(
      'capability',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    requesterIdentityId = _i1.ColumnUuid(
      'requesterIdentityId',
      this,
    );
    requesterService = _i1.ColumnString(
      'requesterService',
      this,
    );
    failureCode = _i1.ColumnString(
      'failureCode',
      this,
    );
    provider = _i1.ColumnString(
      'provider',
      this,
    );
    model = _i1.ColumnString(
      'model',
      this,
    );
    outputText = _i1.ColumnString(
      'outputText',
      this,
    );
    reasoningLevel = _i1.ColumnString(
      'reasoningLevel',
      this,
    );
    currentIteration = _i1.ColumnInt(
      'currentIteration',
      this,
    );
    maxIterations = _i1.ColumnInt(
      'maxIterations',
      this,
    );
    validated = _i1.ColumnBool(
      'validated',
      this,
      hasDefault: true,
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

  late final AiRunUpdateTable updateTable;

  late final _i1.ColumnUuid requestId;

  late final _i1.ColumnUuid projectId;

  late final _i1.ColumnUuid tenantPartyId;

  late final _i1.ColumnUuid missionId;

  late final _i1.ColumnString capability;

  late final _i1.ColumnEnum<_i2.AiRunStatus> status;

  late final _i1.ColumnUuid requesterIdentityId;

  late final _i1.ColumnString requesterService;

  late final _i1.ColumnString failureCode;

  late final _i1.ColumnString provider;

  late final _i1.ColumnString model;

  late final _i1.ColumnString outputText;

  late final _i1.ColumnString reasoningLevel;

  late final _i1.ColumnInt currentIteration;

  late final _i1.ColumnInt maxIterations;

  late final _i1.ColumnBool validated;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    requestId,
    projectId,
    tenantPartyId,
    missionId,
    capability,
    status,
    requesterIdentityId,
    requesterService,
    failureCode,
    provider,
    model,
    outputText,
    reasoningLevel,
    currentIteration,
    maxIterations,
    validated,
    createdAt,
    updatedAt,
  ];
}

class AiRunInclude extends _i1.IncludeObject {
  AiRunInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiRun.t;
}

class AiRunIncludeList extends _i1.IncludeList {
  AiRunIncludeList._({
    _i1.WhereExpressionBuilder<AiRunTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AiRun.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AiRun.t;
}

class AiRunRepository {
  const AiRunRepository._();

  /// Returns a list of [AiRun]s matching the given query parameters.
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
  Future<List<AiRun>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiRunTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiRunTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiRunTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AiRun>(
      where: where?.call(AiRun.t),
      orderBy: orderBy?.call(AiRun.t),
      orderByList: orderByList?.call(AiRun.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AiRun] matching the given query parameters.
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
  Future<AiRun?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiRunTable>? where,
    int? offset,
    _i1.OrderByBuilder<AiRunTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AiRunTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AiRun>(
      where: where?.call(AiRun.t),
      orderBy: orderBy?.call(AiRun.t),
      orderByList: orderByList?.call(AiRun.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AiRun] by its [id] or null if no such row exists.
  Future<AiRun?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AiRun>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AiRun]s in the list and returns the inserted rows.
  ///
  /// The returned [AiRun]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AiRun>> insert(
    _i1.DatabaseSession session,
    List<AiRun> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AiRun>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AiRun] and returns the inserted row.
  ///
  /// The returned [AiRun] will have its `id` field set.
  Future<AiRun> insertRow(
    _i1.DatabaseSession session,
    AiRun row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AiRun>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AiRun]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AiRun>> update(
    _i1.DatabaseSession session,
    List<AiRun> rows, {
    _i1.ColumnSelections<AiRunTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AiRun>(
      rows,
      columns: columns?.call(AiRun.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiRun]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AiRun> updateRow(
    _i1.DatabaseSession session,
    AiRun row, {
    _i1.ColumnSelections<AiRunTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AiRun>(
      row,
      columns: columns?.call(AiRun.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AiRun] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AiRun?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AiRunUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AiRun>(
      id,
      columnValues: columnValues(AiRun.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AiRun]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AiRun>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AiRunUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AiRunTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AiRunTable>? orderBy,
    _i1.OrderByListBuilder<AiRunTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AiRun>(
      columnValues: columnValues(AiRun.t.updateTable),
      where: where(AiRun.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AiRun.t),
      orderByList: orderByList?.call(AiRun.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AiRun]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AiRun>> delete(
    _i1.DatabaseSession session,
    List<AiRun> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AiRun>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AiRun].
  Future<AiRun> deleteRow(
    _i1.DatabaseSession session,
    AiRun row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AiRun>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AiRun>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiRunTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AiRun>(
      where: where(AiRun.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AiRunTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AiRun>(
      where: where?.call(AiRun.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AiRun] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AiRunTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AiRun>(
      where: where(AiRun.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
