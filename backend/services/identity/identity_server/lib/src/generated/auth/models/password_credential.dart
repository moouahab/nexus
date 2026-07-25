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

/// Username/password credential linked to one technical identity.
abstract class PasswordCredential
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PasswordCredential._({
    this.id,
    required this.identityId,
    this.identity,
    required this.username,
    required this.passwordHash,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PasswordCredential({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    required String username,
    required String passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PasswordCredentialImpl;

  factory PasswordCredential.fromJson(Map<String, dynamic> jsonSerialization) {
    return PasswordCredential(
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
      username: jsonSerialization['username'] as String,
      passwordHash: jsonSerialization['passwordHash'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PasswordCredentialTable();

  static const db = PasswordCredentialRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue identityId;

  /// The identity this credential belongs to.
  _i2.Identity? identity;

  /// Login username, stored normalized.
  String username;

  /// Password hash, stored in PHC format by the password hasher.
  String passwordHash;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PasswordCredential]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PasswordCredential copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? identityId,
    _i2.Identity? identity,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PasswordCredential',
      if (id != null) 'id': id?.toJson(),
      'identityId': identityId.toJson(),
      if (identity != null) 'identity': identity?.toJson(),
      'username': username,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PasswordCredentialInclude include({_i2.IdentityInclude? identity}) {
    return PasswordCredentialInclude._(identity: identity);
  }

  static PasswordCredentialIncludeList includeList({
    _i1.WhereExpressionBuilder<PasswordCredentialTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordCredentialTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordCredentialTable>? orderByList,
    PasswordCredentialInclude? include,
  }) {
    return PasswordCredentialIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PasswordCredential.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PasswordCredential.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PasswordCredentialImpl extends PasswordCredential {
  _PasswordCredentialImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    required String username,
    required String passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         identityId: identityId,
         identity: identity,
         username: username,
         passwordHash: passwordHash,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PasswordCredential]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PasswordCredential copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? identityId,
    Object? identity = _Undefined,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return PasswordCredential(
      id: id is _i1.UuidValue? ? id : this.id,
      identityId: identityId ?? this.identityId,
      identity: identity is _i2.Identity?
          ? identity
          : this.identity?.copyWith(),
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class PasswordCredentialUpdateTable
    extends _i1.UpdateTable<PasswordCredentialTable> {
  PasswordCredentialUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> identityId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.identityId,
    value,
  );

  _i1.ColumnValue<String, String> username(String value) => _i1.ColumnValue(
    table.username,
    value,
  );

  _i1.ColumnValue<String, String> passwordHash(String value) => _i1.ColumnValue(
    table.passwordHash,
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

class PasswordCredentialTable extends _i1.Table<_i1.UuidValue?> {
  PasswordCredentialTable({super.tableRelation})
    : super(tableName: 'password_credential') {
    updateTable = PasswordCredentialUpdateTable(this);
    identityId = _i1.ColumnUuid(
      'identityId',
      this,
    );
    username = _i1.ColumnString(
      'username',
      this,
    );
    passwordHash = _i1.ColumnString(
      'passwordHash',
      this,
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

  late final PasswordCredentialUpdateTable updateTable;

  late final _i1.ColumnUuid identityId;

  /// The identity this credential belongs to.
  _i2.IdentityTable? _identity;

  /// Login username, stored normalized.
  late final _i1.ColumnString username;

  /// Password hash, stored in PHC format by the password hasher.
  late final _i1.ColumnString passwordHash;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  _i2.IdentityTable get identity {
    if (_identity != null) return _identity!;
    _identity = _i1.createRelationTable(
      relationFieldName: 'identity',
      field: PasswordCredential.t.identityId,
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
    username,
    passwordHash,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'identity') {
      return identity;
    }
    return null;
  }
}

class PasswordCredentialInclude extends _i1.IncludeObject {
  PasswordCredentialInclude._({_i2.IdentityInclude? identity}) {
    _identity = identity;
  }

  _i2.IdentityInclude? _identity;

  @override
  Map<String, _i1.Include?> get includes => {'identity': _identity};

  @override
  _i1.Table<_i1.UuidValue?> get table => PasswordCredential.t;
}

class PasswordCredentialIncludeList extends _i1.IncludeList {
  PasswordCredentialIncludeList._({
    _i1.WhereExpressionBuilder<PasswordCredentialTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PasswordCredential.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PasswordCredential.t;
}

class PasswordCredentialRepository {
  const PasswordCredentialRepository._();

  final attachRow = const PasswordCredentialAttachRowRepository._();

  /// Returns a list of [PasswordCredential]s matching the given query parameters.
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
  Future<List<PasswordCredential>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordCredentialTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordCredentialTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordCredentialTable>? orderByList,
    _i1.Transaction? transaction,
    PasswordCredentialInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PasswordCredential>(
      where: where?.call(PasswordCredential.t),
      orderBy: orderBy?.call(PasswordCredential.t),
      orderByList: orderByList?.call(PasswordCredential.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PasswordCredential] matching the given query parameters.
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
  Future<PasswordCredential?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordCredentialTable>? where,
    int? offset,
    _i1.OrderByBuilder<PasswordCredentialTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordCredentialTable>? orderByList,
    _i1.Transaction? transaction,
    PasswordCredentialInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PasswordCredential>(
      where: where?.call(PasswordCredential.t),
      orderBy: orderBy?.call(PasswordCredential.t),
      orderByList: orderByList?.call(PasswordCredential.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PasswordCredential] by its [id] or null if no such row exists.
  Future<PasswordCredential?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    PasswordCredentialInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PasswordCredential>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PasswordCredential]s in the list and returns the inserted rows.
  ///
  /// The returned [PasswordCredential]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PasswordCredential>> insert(
    _i1.DatabaseSession session,
    List<PasswordCredential> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PasswordCredential>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PasswordCredential] and returns the inserted row.
  ///
  /// The returned [PasswordCredential] will have its `id` field set.
  Future<PasswordCredential> insertRow(
    _i1.DatabaseSession session,
    PasswordCredential row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PasswordCredential>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PasswordCredential]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PasswordCredential>> update(
    _i1.DatabaseSession session,
    List<PasswordCredential> rows, {
    _i1.ColumnSelections<PasswordCredentialTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PasswordCredential>(
      rows,
      columns: columns?.call(PasswordCredential.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PasswordCredential]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PasswordCredential> updateRow(
    _i1.DatabaseSession session,
    PasswordCredential row, {
    _i1.ColumnSelections<PasswordCredentialTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PasswordCredential>(
      row,
      columns: columns?.call(PasswordCredential.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PasswordCredential] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PasswordCredential?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PasswordCredentialUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PasswordCredential>(
      id,
      columnValues: columnValues(PasswordCredential.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PasswordCredential]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PasswordCredential>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PasswordCredentialUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PasswordCredentialTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordCredentialTable>? orderBy,
    _i1.OrderByListBuilder<PasswordCredentialTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PasswordCredential>(
      columnValues: columnValues(PasswordCredential.t.updateTable),
      where: where(PasswordCredential.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PasswordCredential.t),
      orderByList: orderByList?.call(PasswordCredential.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PasswordCredential]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PasswordCredential>> delete(
    _i1.DatabaseSession session,
    List<PasswordCredential> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PasswordCredential>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PasswordCredential].
  Future<PasswordCredential> deleteRow(
    _i1.DatabaseSession session,
    PasswordCredential row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PasswordCredential>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PasswordCredential>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PasswordCredentialTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PasswordCredential>(
      where: where(PasswordCredential.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordCredentialTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PasswordCredential>(
      where: where?.call(PasswordCredential.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PasswordCredential] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PasswordCredentialTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PasswordCredential>(
      where: where(PasswordCredential.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class PasswordCredentialAttachRowRepository {
  const PasswordCredentialAttachRowRepository._();

  /// Creates a relation between the given [PasswordCredential] and [Identity]
  /// by setting the [PasswordCredential]'s foreign key `identityId` to refer to the [Identity].
  Future<void> identity(
    _i1.DatabaseSession session,
    PasswordCredential passwordCredential,
    _i2.Identity identity, {
    _i1.Transaction? transaction,
  }) async {
    if (passwordCredential.id == null) {
      throw ArgumentError.notNull('passwordCredential.id');
    }
    if (identity.id == null) {
      throw ArgumentError.notNull('identity.id');
    }

    var $passwordCredential = passwordCredential.copyWith(
      identityId: identity.id,
    );
    await session.db.updateRow<PasswordCredential>(
      $passwordCredential,
      columns: [PasswordCredential.t.identityId],
      transaction: transaction,
    );
  }
}
