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
import '../../auth/models/auth_provider.dart' as _i3;
import 'package:identity_server/src/generated/protocol.dart' as _i4;

/// Login session used as the sid claim in access tokens.
abstract class AuthSession
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  AuthSession._({
    this.id,
    required this.identityId,
    this.identity,
    DateTime? createdAt,
    required this.expiresAt,
    this.lastUsedAt,
    this.revokedAt,
    required this.authMethod,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AuthSession({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
    required _i3.AuthProvider authMethod,
  }) = _AuthSessionImpl;

  factory AuthSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuthSession(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      identityId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['identityId'],
      ),
      identity: jsonSerialization['identity'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Identity>(
              jsonSerialization['identity'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      authMethod: _i3.AuthProvider.fromJson(
        (jsonSerialization['authMethod'] as String),
      ),
    );
  }

  static final t = AuthSessionTable();

  static const db = AuthSessionRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue identityId;

  /// The identity this session belongs to.
  _i2.Identity? identity;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? lastUsedAt;

  DateTime? revokedAt;

  _i3.AuthProvider authMethod;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AuthSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuthSession copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? identityId,
    _i2.Identity? identity,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
    _i3.AuthProvider? authMethod,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuthSession',
      if (id != null) 'id': id?.toJson(),
      'identityId': identityId.toJson(),
      if (identity != null) 'identity': identity?.toJson(),
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'authMethod': authMethod.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AuthSessionInclude include({_i2.IdentityInclude? identity}) {
    return AuthSessionInclude._(identity: identity);
  }

  static AuthSessionIncludeList includeList({
    _i1.WhereExpressionBuilder<AuthSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AuthSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AuthSessionTable>? orderByList,
    AuthSessionInclude? include,
  }) {
    return AuthSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuthSession.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AuthSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuthSessionImpl extends AuthSession {
  _AuthSessionImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
    required _i3.AuthProvider authMethod,
  }) : super._(
         id: id,
         identityId: identityId,
         identity: identity,
         createdAt: createdAt,
         expiresAt: expiresAt,
         lastUsedAt: lastUsedAt,
         revokedAt: revokedAt,
         authMethod: authMethod,
       );

  /// Returns a shallow copy of this [AuthSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuthSession copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? identityId,
    Object? identity = _Undefined,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? lastUsedAt = _Undefined,
    Object? revokedAt = _Undefined,
    _i3.AuthProvider? authMethod,
  }) {
    return AuthSession(
      id: id is _i1.UuidValue? ? id : this.id,
      identityId: identityId ?? this.identityId,
      identity: identity is _i2.Identity?
          ? identity
          : this.identity?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}

class AuthSessionUpdateTable extends _i1.UpdateTable<AuthSessionTable> {
  AuthSessionUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> identityId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.identityId,
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

  _i1.ColumnValue<DateTime, DateTime> lastUsedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastUsedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.revokedAt,
        value,
      );

  _i1.ColumnValue<_i3.AuthProvider, _i3.AuthProvider> authMethod(
    _i3.AuthProvider value,
  ) => _i1.ColumnValue(
    table.authMethod,
    value,
  );
}

class AuthSessionTable extends _i1.Table<_i1.UuidValue?> {
  AuthSessionTable({super.tableRelation}) : super(tableName: 'auth_session') {
    updateTable = AuthSessionUpdateTable(this);
    identityId = _i1.ColumnUuid(
      'identityId',
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
    lastUsedAt = _i1.ColumnDateTime(
      'lastUsedAt',
      this,
    );
    revokedAt = _i1.ColumnDateTime(
      'revokedAt',
      this,
    );
    authMethod = _i1.ColumnEnum(
      'authMethod',
      this,
      _i1.EnumSerialization.byName,
    );
  }

  late final AuthSessionUpdateTable updateTable;

  late final _i1.ColumnUuid identityId;

  /// The identity this session belongs to.
  _i2.IdentityTable? _identity;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime lastUsedAt;

  late final _i1.ColumnDateTime revokedAt;

  late final _i1.ColumnEnum<_i3.AuthProvider> authMethod;

  _i2.IdentityTable get identity {
    if (_identity != null) return _identity!;
    _identity = _i1.createRelationTable(
      relationFieldName: 'identity',
      field: AuthSession.t.identityId,
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
    createdAt,
    expiresAt,
    lastUsedAt,
    revokedAt,
    authMethod,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'identity') {
      return identity;
    }
    return null;
  }
}

class AuthSessionInclude extends _i1.IncludeObject {
  AuthSessionInclude._({_i2.IdentityInclude? identity}) {
    _identity = identity;
  }

  _i2.IdentityInclude? _identity;

  @override
  Map<String, _i1.Include?> get includes => {'identity': _identity};

  @override
  _i1.Table<_i1.UuidValue?> get table => AuthSession.t;
}

class AuthSessionIncludeList extends _i1.IncludeList {
  AuthSessionIncludeList._({
    _i1.WhereExpressionBuilder<AuthSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AuthSession.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AuthSession.t;
}

class AuthSessionRepository {
  const AuthSessionRepository._();

  final attachRow = const AuthSessionAttachRowRepository._();

  /// Returns a list of [AuthSession]s matching the given query parameters.
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
  Future<List<AuthSession>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AuthSessionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AuthSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AuthSessionTable>? orderByList,
    _i1.Transaction? transaction,
    AuthSessionInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AuthSession>(
      where: where?.call(AuthSession.t),
      orderBy: orderBy?.call(AuthSession.t),
      orderByList: orderByList?.call(AuthSession.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AuthSession] matching the given query parameters.
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
  Future<AuthSession?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AuthSessionTable>? where,
    int? offset,
    _i1.OrderByBuilder<AuthSessionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AuthSessionTable>? orderByList,
    _i1.Transaction? transaction,
    AuthSessionInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AuthSession>(
      where: where?.call(AuthSession.t),
      orderBy: orderBy?.call(AuthSession.t),
      orderByList: orderByList?.call(AuthSession.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AuthSession] by its [id] or null if no such row exists.
  Future<AuthSession?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    AuthSessionInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AuthSession>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AuthSession]s in the list and returns the inserted rows.
  ///
  /// The returned [AuthSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<AuthSession>> insert(
    _i1.DatabaseSession session,
    List<AuthSession> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AuthSession>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AuthSession] and returns the inserted row.
  ///
  /// The returned [AuthSession] will have its `id` field set.
  Future<AuthSession> insertRow(
    _i1.DatabaseSession session,
    AuthSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AuthSession>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AuthSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AuthSession>> update(
    _i1.DatabaseSession session,
    List<AuthSession> rows, {
    _i1.ColumnSelections<AuthSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AuthSession>(
      rows,
      columns: columns?.call(AuthSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AuthSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AuthSession> updateRow(
    _i1.DatabaseSession session,
    AuthSession row, {
    _i1.ColumnSelections<AuthSessionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AuthSession>(
      row,
      columns: columns?.call(AuthSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AuthSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AuthSession?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AuthSessionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AuthSession>(
      id,
      columnValues: columnValues(AuthSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AuthSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AuthSession>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AuthSessionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AuthSessionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AuthSessionTable>? orderBy,
    _i1.OrderByListBuilder<AuthSessionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AuthSession>(
      columnValues: columnValues(AuthSession.t.updateTable),
      where: where(AuthSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuthSession.t),
      orderByList: orderByList?.call(AuthSession.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AuthSession]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AuthSession>> delete(
    _i1.DatabaseSession session,
    List<AuthSession> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AuthSession>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AuthSession].
  Future<AuthSession> deleteRow(
    _i1.DatabaseSession session,
    AuthSession row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AuthSession>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AuthSession>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AuthSessionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AuthSession>(
      where: where(AuthSession.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AuthSessionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AuthSession>(
      where: where?.call(AuthSession.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AuthSession] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AuthSessionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AuthSession>(
      where: where(AuthSession.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class AuthSessionAttachRowRepository {
  const AuthSessionAttachRowRepository._();

  /// Creates a relation between the given [AuthSession] and [Identity]
  /// by setting the [AuthSession]'s foreign key `identityId` to refer to the [Identity].
  Future<void> identity(
    _i1.DatabaseSession session,
    AuthSession authSession,
    _i2.Identity identity, {
    _i1.Transaction? transaction,
  }) async {
    if (authSession.id == null) {
      throw ArgumentError.notNull('authSession.id');
    }
    if (identity.id == null) {
      throw ArgumentError.notNull('identity.id');
    }

    var $authSession = authSession.copyWith(identityId: identity.id);
    await session.db.updateRow<AuthSession>(
      $authSession,
      columns: [AuthSession.t.identityId],
      transaction: transaction,
    );
  }
}
