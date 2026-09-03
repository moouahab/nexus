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

/// Short-lived code used to verify an identity email address.
abstract class EmailVerificationCode
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  EmailVerificationCode._({
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

  factory EmailVerificationCode({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    required String email,
    required String codeHash,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? consumedAt,
    int? failedAttempts,
  }) = _EmailVerificationCodeImpl;

  factory EmailVerificationCode.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EmailVerificationCode(
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

  static final t = EmailVerificationCodeTable();

  static const db = EmailVerificationCodeRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue identityId;

  _i2.Identity? identity;

  String email;

  /// Hashed verification code. Never store the raw code.
  String codeHash;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? consumedAt;

  int failedAttempts;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [EmailVerificationCode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EmailVerificationCode copyWith({
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
      '__className__': 'EmailVerificationCode',
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

  static EmailVerificationCodeInclude include({_i2.IdentityInclude? identity}) {
    return EmailVerificationCodeInclude._(identity: identity);
  }

  static EmailVerificationCodeIncludeList includeList({
    _i1.WhereExpressionBuilder<EmailVerificationCodeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailVerificationCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailVerificationCodeTable>? orderByList,
    EmailVerificationCodeInclude? include,
  }) {
    return EmailVerificationCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmailVerificationCode.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EmailVerificationCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EmailVerificationCodeImpl extends EmailVerificationCode {
  _EmailVerificationCodeImpl({
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

  /// Returns a shallow copy of this [EmailVerificationCode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EmailVerificationCode copyWith({
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
    return EmailVerificationCode(
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

class EmailVerificationCodeUpdateTable
    extends _i1.UpdateTable<EmailVerificationCodeTable> {
  EmailVerificationCodeUpdateTable(super.table);

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

class EmailVerificationCodeTable extends _i1.Table<_i1.UuidValue?> {
  EmailVerificationCodeTable({super.tableRelation})
    : super(tableName: 'email_verification_code') {
    updateTable = EmailVerificationCodeUpdateTable(this);
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

  late final EmailVerificationCodeUpdateTable updateTable;

  late final _i1.ColumnUuid identityId;

  _i2.IdentityTable? _identity;

  late final _i1.ColumnString email;

  /// Hashed verification code. Never store the raw code.
  late final _i1.ColumnString codeHash;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime consumedAt;

  late final _i1.ColumnInt failedAttempts;

  _i2.IdentityTable get identity {
    if (_identity != null) return _identity!;
    _identity = _i1.createRelationTable(
      relationFieldName: 'identity',
      field: EmailVerificationCode.t.identityId,
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

class EmailVerificationCodeInclude extends _i1.IncludeObject {
  EmailVerificationCodeInclude._({_i2.IdentityInclude? identity}) {
    _identity = identity;
  }

  _i2.IdentityInclude? _identity;

  @override
  Map<String, _i1.Include?> get includes => {'identity': _identity};

  @override
  _i1.Table<_i1.UuidValue?> get table => EmailVerificationCode.t;
}

class EmailVerificationCodeIncludeList extends _i1.IncludeList {
  EmailVerificationCodeIncludeList._({
    _i1.WhereExpressionBuilder<EmailVerificationCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EmailVerificationCode.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => EmailVerificationCode.t;
}

class EmailVerificationCodeRepository {
  const EmailVerificationCodeRepository._();

  final attachRow = const EmailVerificationCodeAttachRowRepository._();

  /// Returns a list of [EmailVerificationCode]s matching the given query parameters.
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
  Future<List<EmailVerificationCode>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailVerificationCodeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailVerificationCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailVerificationCodeTable>? orderByList,
    _i1.Transaction? transaction,
    EmailVerificationCodeInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EmailVerificationCode>(
      where: where?.call(EmailVerificationCode.t),
      orderBy: orderBy?.call(EmailVerificationCode.t),
      orderByList: orderByList?.call(EmailVerificationCode.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EmailVerificationCode] matching the given query parameters.
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
  Future<EmailVerificationCode?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailVerificationCodeTable>? where,
    int? offset,
    _i1.OrderByBuilder<EmailVerificationCodeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailVerificationCodeTable>? orderByList,
    _i1.Transaction? transaction,
    EmailVerificationCodeInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EmailVerificationCode>(
      where: where?.call(EmailVerificationCode.t),
      orderBy: orderBy?.call(EmailVerificationCode.t),
      orderByList: orderByList?.call(EmailVerificationCode.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EmailVerificationCode] by its [id] or null if no such row exists.
  Future<EmailVerificationCode?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    EmailVerificationCodeInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EmailVerificationCode>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EmailVerificationCode]s in the list and returns the inserted rows.
  ///
  /// The returned [EmailVerificationCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EmailVerificationCode>> insert(
    _i1.DatabaseSession session,
    List<EmailVerificationCode> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EmailVerificationCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EmailVerificationCode] and returns the inserted row.
  ///
  /// The returned [EmailVerificationCode] will have its `id` field set.
  Future<EmailVerificationCode> insertRow(
    _i1.DatabaseSession session,
    EmailVerificationCode row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EmailVerificationCode>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EmailVerificationCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EmailVerificationCode>> update(
    _i1.DatabaseSession session,
    List<EmailVerificationCode> rows, {
    _i1.ColumnSelections<EmailVerificationCodeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EmailVerificationCode>(
      rows,
      columns: columns?.call(EmailVerificationCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmailVerificationCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EmailVerificationCode> updateRow(
    _i1.DatabaseSession session,
    EmailVerificationCode row, {
    _i1.ColumnSelections<EmailVerificationCodeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EmailVerificationCode>(
      row,
      columns: columns?.call(EmailVerificationCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmailVerificationCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EmailVerificationCode?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<EmailVerificationCodeUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EmailVerificationCode>(
      id,
      columnValues: columnValues(EmailVerificationCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EmailVerificationCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EmailVerificationCode>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EmailVerificationCodeUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<EmailVerificationCodeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailVerificationCodeTable>? orderBy,
    _i1.OrderByListBuilder<EmailVerificationCodeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EmailVerificationCode>(
      columnValues: columnValues(EmailVerificationCode.t.updateTable),
      where: where(EmailVerificationCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmailVerificationCode.t),
      orderByList: orderByList?.call(EmailVerificationCode.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EmailVerificationCode]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EmailVerificationCode>> delete(
    _i1.DatabaseSession session,
    List<EmailVerificationCode> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EmailVerificationCode>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EmailVerificationCode].
  Future<EmailVerificationCode> deleteRow(
    _i1.DatabaseSession session,
    EmailVerificationCode row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EmailVerificationCode>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EmailVerificationCode>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EmailVerificationCodeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EmailVerificationCode>(
      where: where(EmailVerificationCode.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailVerificationCodeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EmailVerificationCode>(
      where: where?.call(EmailVerificationCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EmailVerificationCode] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EmailVerificationCodeTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EmailVerificationCode>(
      where: where(EmailVerificationCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class EmailVerificationCodeAttachRowRepository {
  const EmailVerificationCodeAttachRowRepository._();

  /// Creates a relation between the given [EmailVerificationCode] and [Identity]
  /// by setting the [EmailVerificationCode]'s foreign key `identityId` to refer to the [Identity].
  Future<void> identity(
    _i1.DatabaseSession session,
    EmailVerificationCode emailVerificationCode,
    _i2.Identity identity, {
    _i1.Transaction? transaction,
  }) async {
    if (emailVerificationCode.id == null) {
      throw ArgumentError.notNull('emailVerificationCode.id');
    }
    if (identity.id == null) {
      throw ArgumentError.notNull('identity.id');
    }

    var $emailVerificationCode = emailVerificationCode.copyWith(
      identityId: identity.id,
    );
    await session.db.updateRow<EmailVerificationCode>(
      $emailVerificationCode,
      columns: [EmailVerificationCode.t.identityId],
      transaction: transaction,
    );
  }
}
