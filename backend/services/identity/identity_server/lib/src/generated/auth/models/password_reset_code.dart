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
import '../../auth/models/identity.dart' as _i2;
import 'package:identity_server/src/generated/protocol.dart' as _i3;

/// Short-lived code used to reset an identity password.
abstract class PasswordResetCode
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PasswordResetCode._({
    this.id,
    required this.identityId,
    this.identity,
    required this.email,
    required this.codeHash,
    DateTime? createdAt,
    required this.expiresAt,
    this.consumedAt,
    int? failedAttempts,
  }) : createdAt = createdAt ?? DateTime.now(),
       failedAttempts = failedAttempts ?? 0;

  factory PasswordResetCode({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    required String email,
    required String codeHash,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? consumedAt,
    int? failedAttempts,
  }) = _PasswordResetCodeImpl;

  factory PasswordResetCode.fromJson(Map<String, dynamic> jsonSerialization) {
    return PasswordResetCode(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      identityId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['identityId'],
      ),
      identity: jsonSerialization['identity'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Identity>(
              jsonSerialization['identity'],
            ),
      email: jsonSerialization['email'] as String,
      codeHash: jsonSerialization['codeHash'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
      failedAttempts: jsonSerialization['failedAttempts'] as int?,
    );
  }

  static final t = PasswordResetCodeTable();

  static const db = PasswordResetCodeRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue identityId;

  _i2.Identity? identity;

  String email;

  /// Hashed reset code. Never store the raw code.
  String codeHash;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? consumedAt;

  int failedAttempts;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PasswordResetCode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PasswordResetCode copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? identityId,
    _i2.Identity? identity,
    String? email,
    String? codeHash,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? consumedAt,
    int? failedAttempts,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PasswordResetCode',
      if (id != null) 'id': id?.toJson(),
      'identityId': identityId.toJson(),
      if (identity != null) 'identity': identity?.toJson(),
      'email': email,
      'codeHash': codeHash,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      'failedAttempts': failedAttempts,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PasswordResetCodeInclude include({_i2.IdentityInclude? identity}) {
    return PasswordResetCodeInclude._(identity: identity);
  }

  static PasswordResetCodeIncludeList includeList({
    _i1.WhereExpressionBuilder<PasswordResetCodeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordResetCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordResetCodeTable>? orderByList,
    PasswordResetCodeInclude? include,
  }) {
    return PasswordResetCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PasswordResetCode.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PasswordResetCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PasswordResetCodeImpl extends PasswordResetCode {
  _PasswordResetCodeImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    required String email,
    required String codeHash,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? consumedAt,
    int? failedAttempts,
  }) : super._(
         id: id,
         identityId: identityId,
         identity: identity,
         email: email,
         codeHash: codeHash,
         createdAt: createdAt,
         expiresAt: expiresAt,
         consumedAt: consumedAt,
         failedAttempts: failedAttempts,
       );

  /// Returns a shallow copy of this [PasswordResetCode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PasswordResetCode copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? identityId,
    Object? identity = _Undefined,
    String? email,
    String? codeHash,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? consumedAt = _Undefined,
    int? failedAttempts,
  }) {
    return PasswordResetCode(
      id: id is _i1.UuidValue? ? id : this.id,
      identityId: identityId ?? this.identityId,
      identity: identity is _i2.Identity?
          ? identity
          : this.identity?.copyWith(),
      email: email ?? this.email,
      codeHash: codeHash ?? this.codeHash,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}

class PasswordResetCodeUpdateTable
    extends _i1.UpdateTable<PasswordResetCodeTable> {
  PasswordResetCodeUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> identityId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.identityId,
    value,
  );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> codeHash(String value) => _i1.ColumnValue(
    table.codeHash,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> consumedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.consumedAt,
        value,
      );

  _i1.ColumnValue<int, int> failedAttempts(int value) => _i1.ColumnValue(
    table.failedAttempts,
    value,
  );
}

class PasswordResetCodeTable extends _i1.Table<_i1.UuidValue?> {
  PasswordResetCodeTable({super.tableRelation})
    : super(tableName: 'password_reset_code') {
    updateTable = PasswordResetCodeUpdateTable(this);
    identityId = _i1.ColumnUuid(
      'identityId',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    codeHash = _i1.ColumnString(
      'codeHash',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    consumedAt = _i1.ColumnDateTime(
      'consumedAt',
      this,
    );
    failedAttempts = _i1.ColumnInt(
      'failedAttempts',
      this,
      hasDefault: true,
    );
  }

  late final PasswordResetCodeUpdateTable updateTable;

  late final _i1.ColumnUuid identityId;

  _i2.IdentityTable? _identity;

  late final _i1.ColumnString email;

  /// Hashed reset code. Never store the raw code.
  late final _i1.ColumnString codeHash;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime consumedAt;

  late final _i1.ColumnInt failedAttempts;

  _i2.IdentityTable get identity {
    if (_identity != null) return _identity!;
    _identity = _i1.createRelationTable(
      relationFieldName: 'identity',
      field: PasswordResetCode.t.identityId,
      foreignField: _i2.Identity.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.IdentityTable(tableRelation: foreignTableRelation),
    );
    return _identity!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    identityId,
    email,
    codeHash,
    createdAt,
    expiresAt,
    consumedAt,
    failedAttempts,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'identity') {
      return identity;
    }
    return null;
  }
}

class PasswordResetCodeInclude extends _i1.IncludeObject {
  PasswordResetCodeInclude._({_i2.IdentityInclude? identity}) {
    _identity = identity;
  }

  _i2.IdentityInclude? _identity;

  @override
  Map<String, _i1.Include?> get includes => {'identity': _identity};

  @override
  _i1.Table<_i1.UuidValue?> get table => PasswordResetCode.t;
}

class PasswordResetCodeIncludeList extends _i1.IncludeList {
  PasswordResetCodeIncludeList._({
    _i1.WhereExpressionBuilder<PasswordResetCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PasswordResetCode.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PasswordResetCode.t;
}

class PasswordResetCodeRepository {
  const PasswordResetCodeRepository._();

  final attachRow = const PasswordResetCodeAttachRowRepository._();

  /// Returns a list of [PasswordResetCode]s matching the given query parameters.
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
  Future<List<PasswordResetCode>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordResetCodeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordResetCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordResetCodeTable>? orderByList,
    _i1.Transaction? transaction,
    PasswordResetCodeInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PasswordResetCode>(
      where: where?.call(PasswordResetCode.t),
      orderBy: orderBy?.call(PasswordResetCode.t),
      orderByList: orderByList?.call(PasswordResetCode.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PasswordResetCode] matching the given query parameters.
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
  Future<PasswordResetCode?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordResetCodeTable>? where,
    int? offset,
    _i1.OrderByBuilder<PasswordResetCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordResetCodeTable>? orderByList,
    _i1.Transaction? transaction,
    PasswordResetCodeInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PasswordResetCode>(
      where: where?.call(PasswordResetCode.t),
      orderBy: orderBy?.call(PasswordResetCode.t),
      orderByList: orderByList?.call(PasswordResetCode.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PasswordResetCode] by its [id] or null if no such row exists.
  Future<PasswordResetCode?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    PasswordResetCodeInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PasswordResetCode>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PasswordResetCode]s in the list and returns the inserted rows.
  ///
  /// The returned [PasswordResetCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PasswordResetCode>> insert(
    _i1.DatabaseSession session,
    List<PasswordResetCode> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PasswordResetCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PasswordResetCode] and returns the inserted row.
  ///
  /// The returned [PasswordResetCode] will have its `id` field set.
  Future<PasswordResetCode> insertRow(
    _i1.DatabaseSession session,
    PasswordResetCode row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PasswordResetCode>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PasswordResetCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PasswordResetCode>> update(
    _i1.DatabaseSession session,
    List<PasswordResetCode> rows, {
    _i1.ColumnSelections<PasswordResetCodeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PasswordResetCode>(
      rows,
      columns: columns?.call(PasswordResetCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PasswordResetCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PasswordResetCode> updateRow(
    _i1.DatabaseSession session,
    PasswordResetCode row, {
    _i1.ColumnSelections<PasswordResetCodeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PasswordResetCode>(
      row,
      columns: columns?.call(PasswordResetCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PasswordResetCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PasswordResetCode?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PasswordResetCodeUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PasswordResetCode>(
      id,
      columnValues: columnValues(PasswordResetCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PasswordResetCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PasswordResetCode>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PasswordResetCodeUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PasswordResetCodeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordResetCodeTable>? orderBy,
    _i1.OrderByListBuilder<PasswordResetCodeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PasswordResetCode>(
      columnValues: columnValues(PasswordResetCode.t.updateTable),
      where: where(PasswordResetCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PasswordResetCode.t),
      orderByList: orderByList?.call(PasswordResetCode.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PasswordResetCode]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PasswordResetCode>> delete(
    _i1.DatabaseSession session,
    List<PasswordResetCode> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PasswordResetCode>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PasswordResetCode].
  Future<PasswordResetCode> deleteRow(
    _i1.DatabaseSession session,
    PasswordResetCode row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PasswordResetCode>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PasswordResetCode>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PasswordResetCodeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PasswordResetCode>(
      where: where(PasswordResetCode.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordResetCodeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PasswordResetCode>(
      where: where?.call(PasswordResetCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PasswordResetCode] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PasswordResetCodeTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PasswordResetCode>(
      where: where(PasswordResetCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class PasswordResetCodeAttachRowRepository {
  const PasswordResetCodeAttachRowRepository._();

  /// Creates a relation between the given [PasswordResetCode] and [Identity]
  /// by setting the [PasswordResetCode]'s foreign key `identityId` to refer to the [Identity].
  Future<void> identity(
    _i1.DatabaseSession session,
    PasswordResetCode passwordResetCode,
    _i2.Identity identity, {
    _i1.Transaction? transaction,
  }) async {
    if (passwordResetCode.id == null) {
      throw ArgumentError.notNull('passwordResetCode.id');
    }
    if (identity.id == null) {
      throw ArgumentError.notNull('identity.id');
    }

    var $passwordResetCode = passwordResetCode.copyWith(
      identityId: identity.id,
    );
    await session.db.updateRow<PasswordResetCode>(
      $passwordResetCode,
      columns: [PasswordResetCode.t.identityId],
      transaction: transaction,
    );
  }
}
