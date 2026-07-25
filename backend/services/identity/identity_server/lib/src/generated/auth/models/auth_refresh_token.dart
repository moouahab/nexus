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
import '../../auth/models/auth_session.dart' as _i2;
import 'package:identity_server/src/generated/protocol.dart' as _i3;

/// Refresh token persisted for rotation and revocation.
abstract class AuthRefreshToken
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  AuthRefreshToken._({
    this.id,
    required this.authSessionId,
    this.authSession,
    required this.tokenHash,
    DateTime? createdAt,
    required this.expiresAt,
    this.revokedAt,
    this.rotatedAt,
    this.replacedByTokenId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AuthRefreshToken({
    _i1.UuidValue? id,
    required _i1.UuidValue authSessionId,
    _i2.AuthSession? authSession,
    required String tokenHash,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? revokedAt,
    DateTime? rotatedAt,
    _i1.UuidValue? replacedByTokenId,
  }) = _AuthRefreshTokenImpl;

  factory AuthRefreshToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuthRefreshToken(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authSessionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authSessionId'],
      ),
      authSession: jsonSerialization['authSession'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthSession>(
              jsonSerialization['authSession'],
            ),
      tokenHash: jsonSerialization['tokenHash'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      rotatedAt: jsonSerialization['rotatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['rotatedAt']),
      replacedByTokenId: jsonSerialization['replacedByTokenId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['replacedByTokenId'],
            ),
    );
  }

  static final t = AuthRefreshTokenTable();

  static const db = AuthRefreshTokenRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue authSessionId;

  /// The session this refresh token belongs to.
  _i2.AuthSession? authSession;

  /// Hashed refresh token secret. Never store the raw token.
  String tokenHash;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? revokedAt;

  DateTime? rotatedAt;

  _i1.UuidValue? replacedByTokenId;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AuthRefreshToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthRefreshToken copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authSessionId,
    _i2.AuthSession? authSession,
    String? tokenHash,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? revokedAt,
    DateTime? rotatedAt,
    _i1.UuidValue? replacedByTokenId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuthRefreshToken',
      if (id != null) 'id': id?.toJson(),
      'authSessionId': authSessionId.toJson(),
      if (authSession != null) 'authSession': authSession?.toJson(),
      'tokenHash': tokenHash,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      if (rotatedAt != null) 'rotatedAt': rotatedAt?.toJson(),
      if (replacedByTokenId != null)
        'replacedByTokenId': replacedByTokenId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AuthRefreshTokenInclude include({
    _i2.AuthSessionInclude? authSession,
  }) {
    return AuthRefreshTokenInclude._(authSession: authSession);
  }

  static AuthRefreshTokenIncludeList includeList({
    _i1.WhereExpressionBuilder<AuthRefreshTokenTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AuthRefreshTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AuthRefreshTokenTable>? orderByList,
    AuthRefreshTokenInclude? include,
  }) {
    return AuthRefreshTokenIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuthRefreshToken.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AuthRefreshToken.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuthRefreshTokenImpl extends AuthRefreshToken {
  _AuthRefreshTokenImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authSessionId,
    _i2.AuthSession? authSession,
    required String tokenHash,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? revokedAt,
    DateTime? rotatedAt,
    _i1.UuidValue? replacedByTokenId,
  }) : super._(
         id: id,
         authSessionId: authSessionId,
         authSession: authSession,
         tokenHash: tokenHash,
         createdAt: createdAt,
         expiresAt: expiresAt,
         revokedAt: revokedAt,
         rotatedAt: rotatedAt,
         replacedByTokenId: replacedByTokenId,
       );

  /// Returns a shallow copy of this [AuthRefreshToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthRefreshToken copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authSessionId,
    Object? authSession = _Undefined,
    String? tokenHash,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? revokedAt = _Undefined,
    Object? rotatedAt = _Undefined,
    Object? replacedByTokenId = _Undefined,
  }) {
    return AuthRefreshToken(
      id: id is _i1.UuidValue? ? id : this.id,
      authSessionId: authSessionId ?? this.authSessionId,
      authSession: authSession is _i2.AuthSession?
          ? authSession
          : this.authSession?.copyWith(),
      tokenHash: tokenHash ?? this.tokenHash,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      rotatedAt: rotatedAt is DateTime? ? rotatedAt : this.rotatedAt,
      replacedByTokenId: replacedByTokenId is _i1.UuidValue?
          ? replacedByTokenId
          : this.replacedByTokenId,
    );
  }
}

class AuthRefreshTokenUpdateTable
    extends _i1.UpdateTable<AuthRefreshTokenTable> {
  AuthRefreshTokenUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authSessionId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authSessionId,
    value,
  );

  _i1.ColumnValue<String, String> tokenHash(String value) => _i1.ColumnValue(
    table.tokenHash,
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

  _i1.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.revokedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> rotatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.rotatedAt,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> replacedByTokenId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.replacedByTokenId,
    value,
  );
}

class AuthRefreshTokenTable extends _i1.Table<_i1.UuidValue?> {
  AuthRefreshTokenTable({super.tableRelation})
    : super(tableName: 'auth_refresh_token') {
    updateTable = AuthRefreshTokenUpdateTable(this);
    authSessionId = _i1.ColumnUuid(
      'authSessionId',
      this,
    );
    tokenHash = _i1.ColumnString(
      'tokenHash',
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
    revokedAt = _i1.ColumnDateTime(
      'revokedAt',
      this,
    );
    rotatedAt = _i1.ColumnDateTime(
      'rotatedAt',
      this,
    );
    replacedByTokenId = _i1.ColumnUuid(
      'replacedByTokenId',
      this,
    );
  }

  late final AuthRefreshTokenUpdateTable updateTable;

  late final _i1.ColumnUuid authSessionId;

  /// The session this refresh token belongs to.
  _i2.AuthSessionTable? _authSession;

  /// Hashed refresh token secret. Never store the raw token.
  late final _i1.ColumnString tokenHash;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime revokedAt;

  late final _i1.ColumnDateTime rotatedAt;

  late final _i1.ColumnUuid replacedByTokenId;

  _i2.AuthSessionTable get authSession {
    if (_authSession != null) return _authSession!;
    _authSession = _i1.createRelationTable(
      relationFieldName: 'authSession',
      field: AuthRefreshToken.t.authSessionId,
      foreignField: _i2.AuthSession.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthSessionTable(tableRelation: foreignTableRelation),
    );
    return _authSession!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    authSessionId,
    tokenHash,
    createdAt,
    expiresAt,
    revokedAt,
    rotatedAt,
    replacedByTokenId,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'authSession') {
      return authSession;
    }
    return null;
  }
}

class AuthRefreshTokenInclude extends _i1.IncludeObject {
  AuthRefreshTokenInclude._({_i2.AuthSessionInclude? authSession}) {
    _authSession = authSession;
  }

  _i2.AuthSessionInclude? _authSession;

  @override
  Map<String, _i1.Include?> get includes => {'authSession': _authSession};

  @override
  _i1.Table<_i1.UuidValue?> get table => AuthRefreshToken.t;
}

class AuthRefreshTokenIncludeList extends _i1.IncludeList {
  AuthRefreshTokenIncludeList._({
    _i1.WhereExpressionBuilder<AuthRefreshTokenTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AuthRefreshToken.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AuthRefreshToken.t;
}

class AuthRefreshTokenRepository {
  const AuthRefreshTokenRepository._();

  final attachRow = const AuthRefreshTokenAttachRowRepository._();

  /// Returns a list of [AuthRefreshToken]s matching the given query parameters.
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
  Future<List<AuthRefreshToken>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AuthRefreshTokenTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AuthRefreshTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AuthRefreshTokenTable>? orderByList,
    _i1.Transaction? transaction,
    AuthRefreshTokenInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AuthRefreshToken>(
      where: where?.call(AuthRefreshToken.t),
      orderBy: orderBy?.call(AuthRefreshToken.t),
      orderByList: orderByList?.call(AuthRefreshToken.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AuthRefreshToken] matching the given query parameters.
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
  Future<AuthRefreshToken?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AuthRefreshTokenTable>? where,
    int? offset,
    _i1.OrderByBuilder<AuthRefreshTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AuthRefreshTokenTable>? orderByList,
    _i1.Transaction? transaction,
    AuthRefreshTokenInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AuthRefreshToken>(
      where: where?.call(AuthRefreshToken.t),
      orderBy: orderBy?.call(AuthRefreshToken.t),
      orderByList: orderByList?.call(AuthRefreshToken.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AuthRefreshToken] by its [id] or null if no such row exists.
  Future<AuthRefreshToken?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    AuthRefreshTokenInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AuthRefreshToken>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AuthRefreshToken]s in the list and returns the inserted rows.
  ///
  /// The returned [AuthRefreshToken]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AuthRefreshToken>> insert(
    _i1.DatabaseSession session,
    List<AuthRefreshToken> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AuthRefreshToken>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AuthRefreshToken] and returns the inserted row.
  ///
  /// The returned [AuthRefreshToken] will have its `id` field set.
  Future<AuthRefreshToken> insertRow(
    _i1.DatabaseSession session,
    AuthRefreshToken row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AuthRefreshToken>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AuthRefreshToken]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AuthRefreshToken>> update(
    _i1.DatabaseSession session,
    List<AuthRefreshToken> rows, {
    _i1.ColumnSelections<AuthRefreshTokenTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AuthRefreshToken>(
      rows,
      columns: columns?.call(AuthRefreshToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AuthRefreshToken]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AuthRefreshToken> updateRow(
    _i1.DatabaseSession session,
    AuthRefreshToken row, {
    _i1.ColumnSelections<AuthRefreshTokenTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AuthRefreshToken>(
      row,
      columns: columns?.call(AuthRefreshToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AuthRefreshToken] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AuthRefreshToken?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AuthRefreshTokenUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AuthRefreshToken>(
      id,
      columnValues: columnValues(AuthRefreshToken.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AuthRefreshToken]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AuthRefreshToken>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AuthRefreshTokenUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<AuthRefreshTokenTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AuthRefreshTokenTable>? orderBy,
    _i1.OrderByListBuilder<AuthRefreshTokenTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AuthRefreshToken>(
      columnValues: columnValues(AuthRefreshToken.t.updateTable),
      where: where(AuthRefreshToken.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuthRefreshToken.t),
      orderByList: orderByList?.call(AuthRefreshToken.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AuthRefreshToken]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AuthRefreshToken>> delete(
    _i1.DatabaseSession session,
    List<AuthRefreshToken> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AuthRefreshToken>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AuthRefreshToken].
  Future<AuthRefreshToken> deleteRow(
    _i1.DatabaseSession session,
    AuthRefreshToken row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AuthRefreshToken>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AuthRefreshToken>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AuthRefreshTokenTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AuthRefreshToken>(
      where: where(AuthRefreshToken.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AuthRefreshTokenTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AuthRefreshToken>(
      where: where?.call(AuthRefreshToken.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AuthRefreshToken] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AuthRefreshTokenTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AuthRefreshToken>(
      where: where(AuthRefreshToken.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class AuthRefreshTokenAttachRowRepository {
  const AuthRefreshTokenAttachRowRepository._();

  /// Creates a relation between the given [AuthRefreshToken] and [AuthSession]
  /// by setting the [AuthRefreshToken]'s foreign key `authSessionId` to refer to the [AuthSession].
  Future<void> authSession(
    _i1.DatabaseSession session,
    AuthRefreshToken authRefreshToken,
    _i2.AuthSession authSession, {
    _i1.Transaction? transaction,
  }) async {
    if (authRefreshToken.id == null) {
      throw ArgumentError.notNull('authRefreshToken.id');
    }
    if (authSession.id == null) {
      throw ArgumentError.notNull('authSession.id');
    }

    var $authRefreshToken = authRefreshToken.copyWith(
      authSessionId: authSession.id,
    );
    await session.db.updateRow<AuthRefreshToken>(
      $authRefreshToken,
      columns: [AuthRefreshToken.t.authSessionId],
      transaction: transaction,
    );
  }
}
