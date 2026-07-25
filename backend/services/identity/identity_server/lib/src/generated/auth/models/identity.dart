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
import '../../auth/models/identity_status.dart' as _i2;

/// Technical identity shared by every login method.
abstract class Identity
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Identity._({
    this.id,
    this.email,
    this.username,
    bool? emailVerified,
    _i2.IdentityStatus? status,
    DateTime? createdAt,
    this.updatedAt,
  }) : emailVerified = emailVerified ?? false,
       status = status ?? _i2.IdentityStatus.active,
       createdAt = createdAt ?? DateTime.now();

  factory Identity({
    _i1.UuidValue? id,
    String? email,
    String? username,
    bool? emailVerified,
    _i2.IdentityStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _IdentityImpl;

  factory Identity.fromJson(Map<String, dynamic> jsonSerialization) {
    return Identity(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      email: jsonSerialization['email'] as String?,
      username: jsonSerialization['username'] as String?,
      emailVerified: jsonSerialization['emailVerified'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['emailVerified']),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.IdentityStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = IdentityTable();

  static const db = IdentityRepository._();

  @override
  _i1.UuidValue? id;

  /// Primary email if known, stored normalized.
  String? email;

  /// Public/login username if reserved for this identity.
  String? username;

  bool emailVerified;

  _i2.IdentityStatus status;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Identity]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Identity copyWith({
    _i1.UuidValue? id,
    String? email,
    String? username,
    bool? emailVerified,
    _i2.IdentityStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Identity',
      if (id != null) 'id': id?.toJson(),
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      'emailVerified': emailVerified,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static IdentityInclude include() {
    return IdentityInclude._();
  }

  static IdentityIncludeList includeList({
    _i1.WhereExpressionBuilder<IdentityTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdentityTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdentityTable>? orderByList,
    IdentityInclude? include,
  }) {
    return IdentityIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Identity.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Identity.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdentityImpl extends Identity {
  _IdentityImpl({
    _i1.UuidValue? id,
    String? email,
    String? username,
    bool? emailVerified,
    _i2.IdentityStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         email: email,
         username: username,
         emailVerified: emailVerified,
         status: status,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Identity]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Identity copyWith({
    Object? id = _Undefined,
    Object? email = _Undefined,
    Object? username = _Undefined,
    bool? emailVerified,
    _i2.IdentityStatus? status,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return Identity(
      id: id is _i1.UuidValue? ? id : this.id,
      email: email is String? ? email : this.email,
      username: username is String? ? username : this.username,
      emailVerified: emailVerified ?? this.emailVerified,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class IdentityUpdateTable extends _i1.UpdateTable<IdentityTable> {
  IdentityUpdateTable(super.table);

  _i1.ColumnValue<String, String> email(String? value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> username(String? value) => _i1.ColumnValue(
    table.username,
    value,
  );

  _i1.ColumnValue<bool, bool> emailVerified(bool value) => _i1.ColumnValue(
    table.emailVerified,
    value,
  );

  _i1.ColumnValue<_i2.IdentityStatus, _i2.IdentityStatus> status(
    _i2.IdentityStatus value,
  ) => _i1.ColumnValue(
    table.status,
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

class IdentityTable extends _i1.Table<_i1.UuidValue?> {
  IdentityTable({super.tableRelation}) : super(tableName: 'identity') {
    updateTable = IdentityUpdateTable(this);
    email = _i1.ColumnString(
      'email',
      this,
    );
    username = _i1.ColumnString(
      'username',
      this,
    );
    emailVerified = _i1.ColumnBool(
      'emailVerified',
      this,
      hasDefault: true,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
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

  late final IdentityUpdateTable updateTable;

  /// Primary email if known, stored normalized.
  late final _i1.ColumnString email;

  /// Public/login username if reserved for this identity.
  late final _i1.ColumnString username;

  late final _i1.ColumnBool emailVerified;

  late final _i1.ColumnEnum<_i2.IdentityStatus> status;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    email,
    username,
    emailVerified,
    status,
    createdAt,
    updatedAt,
  ];
}

class IdentityInclude extends _i1.IncludeObject {
  IdentityInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Identity.t;
}

class IdentityIncludeList extends _i1.IncludeList {
  IdentityIncludeList._({
    _i1.WhereExpressionBuilder<IdentityTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Identity.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Identity.t;
}

class IdentityRepository {
  const IdentityRepository._();

  /// Returns a list of [Identity]s matching the given query parameters.
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
  Future<List<Identity>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdentityTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdentityTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdentityTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Identity>(
      where: where?.call(Identity.t),
      orderBy: orderBy?.call(Identity.t),
      orderByList: orderByList?.call(Identity.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Identity] matching the given query parameters.
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
  Future<Identity?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdentityTable>? where,
    int? offset,
    _i1.OrderByBuilder<IdentityTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdentityTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Identity>(
      where: where?.call(Identity.t),
      orderBy: orderBy?.call(Identity.t),
      orderByList: orderByList?.call(Identity.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Identity] by its [id] or null if no such row exists.
  Future<Identity?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Identity>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Identity]s in the list and returns the inserted rows.
  ///
  /// The returned [Identity]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Identity>> insert(
    _i1.DatabaseSession session,
    List<Identity> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Identity>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Identity] and returns the inserted row.
  ///
  /// The returned [Identity] will have its `id` field set.
  Future<Identity> insertRow(
    _i1.DatabaseSession session,
    Identity row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Identity>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Identity]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Identity>> update(
    _i1.DatabaseSession session,
    List<Identity> rows, {
    _i1.ColumnSelections<IdentityTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Identity>(
      rows,
      columns: columns?.call(Identity.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Identity]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Identity> updateRow(
    _i1.DatabaseSession session,
    Identity row, {
    _i1.ColumnSelections<IdentityTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Identity>(
      row,
      columns: columns?.call(Identity.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Identity] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Identity?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<IdentityUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Identity>(
      id,
      columnValues: columnValues(Identity.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Identity]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Identity>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<IdentityUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<IdentityTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdentityTable>? orderBy,
    _i1.OrderByListBuilder<IdentityTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Identity>(
      columnValues: columnValues(Identity.t.updateTable),
      where: where(Identity.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Identity.t),
      orderByList: orderByList?.call(Identity.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Identity]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Identity>> delete(
    _i1.DatabaseSession session,
    List<Identity> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Identity>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Identity].
  Future<Identity> deleteRow(
    _i1.DatabaseSession session,
    Identity row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Identity>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Identity>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IdentityTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Identity>(
      where: where(Identity.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdentityTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Identity>(
      where: where?.call(Identity.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Identity] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IdentityTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Identity>(
      where: where(Identity.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
