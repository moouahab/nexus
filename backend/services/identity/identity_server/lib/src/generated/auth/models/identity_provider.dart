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

/// External or federated login provider linked to one identity.
abstract class IdentityProvider
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  IdentityProvider._({
    this.id,
    required this.identityId,
    this.identity,
    required this.provider,
    required this.providerUserId,
    this.email,
    bool? emailVerified,
    DateTime? createdAt,
    this.lastUsedAt,
  }) : emailVerified = emailVerified ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory IdentityProvider({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    required _i3.AuthProvider provider,
    required String providerUserId,
    String? email,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) = _IdentityProviderImpl;

  factory IdentityProvider.fromJson(Map<String, dynamic> jsonSerialization) {
    return IdentityProvider(
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
      provider: _i3.AuthProvider.fromJson(
        (jsonSerialization['provider'] as String),
      ),
      providerUserId: jsonSerialization['providerUserId'] as String,
      email: jsonSerialization['email'] as String?,
      emailVerified: jsonSerialization['emailVerified'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['emailVerified']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
    );
  }

  static final t = IdentityProviderTable();

  static const db = IdentityProviderRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue identityId;

  /// The identity this provider belongs to.
  _i2.Identity? identity;

  _i3.AuthProvider provider;

  /// Stable user id returned by the provider, for example Google sub or GitHub id.
  String providerUserId;

  /// Email returned by the provider, if available, stored normalized.
  String? email;

  bool emailVerified;

  DateTime createdAt;

  DateTime? lastUsedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [IdentityProvider]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IdentityProvider copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? identityId,
    _i2.Identity? identity,
    _i3.AuthProvider? provider,
    String? providerUserId,
    String? email,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IdentityProvider',
      if (id != null) 'id': id?.toJson(),
      'identityId': identityId.toJson(),
      if (identity != null) 'identity': identity?.toJson(),
      'provider': provider.toJson(),
      'providerUserId': providerUserId,
      if (email != null) 'email': email,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static IdentityProviderInclude include({_i2.IdentityInclude? identity}) {
    return IdentityProviderInclude._(identity: identity);
  }

  static IdentityProviderIncludeList includeList({
    _i1.WhereExpressionBuilder<IdentityProviderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdentityProviderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdentityProviderTable>? orderByList,
    IdentityProviderInclude? include,
  }) {
    return IdentityProviderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IdentityProvider.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(IdentityProvider.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdentityProviderImpl extends IdentityProvider {
  _IdentityProviderImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue identityId,
    _i2.Identity? identity,
    required _i3.AuthProvider provider,
    required String providerUserId,
    String? email,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) : super._(
         id: id,
         identityId: identityId,
         identity: identity,
         provider: provider,
         providerUserId: providerUserId,
         email: email,
         emailVerified: emailVerified,
         createdAt: createdAt,
         lastUsedAt: lastUsedAt,
       );

  /// Returns a shallow copy of this [IdentityProvider]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IdentityProvider copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? identityId,
    Object? identity = _Undefined,
    _i3.AuthProvider? provider,
    String? providerUserId,
    Object? email = _Undefined,
    bool? emailVerified,
    DateTime? createdAt,
    Object? lastUsedAt = _Undefined,
  }) {
    return IdentityProvider(
      id: id is _i1.UuidValue? ? id : this.id,
      identityId: identityId ?? this.identityId,
      identity: identity is _i2.Identity?
          ? identity
          : this.identity?.copyWith(),
      provider: provider ?? this.provider,
      providerUserId: providerUserId ?? this.providerUserId,
      email: email is String? ? email : this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
    );
  }
}

class IdentityProviderUpdateTable
    extends _i1.UpdateTable<IdentityProviderTable> {
  IdentityProviderUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> identityId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.identityId,
    value,
  );

  _i1.ColumnValue<_i3.AuthProvider, _i3.AuthProvider> provider(
    _i3.AuthProvider value,
  ) => _i1.ColumnValue(
    table.provider,
    value,
  );

  _i1.ColumnValue<String, String> providerUserId(String value) =>
      _i1.ColumnValue(
        table.providerUserId,
        value,
      );

  _i1.ColumnValue<String, String> email(String? value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<bool, bool> emailVerified(bool value) => _i1.ColumnValue(
    table.emailVerified,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastUsedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastUsedAt,
        value,
      );
}

class IdentityProviderTable extends _i1.Table<_i1.UuidValue?> {
  IdentityProviderTable({super.tableRelation})
    : super(tableName: 'identity_provider') {
    updateTable = IdentityProviderUpdateTable(this);
    identityId = _i1.ColumnUuid(
      'identityId',
      this,
    );
    provider = _i1.ColumnEnum(
      'provider',
      this,
      _i1.EnumSerialization.byName,
    );
    providerUserId = _i1.ColumnString(
      'providerUserId',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    emailVerified = _i1.ColumnBool(
      'emailVerified',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    lastUsedAt = _i1.ColumnDateTime(
      'lastUsedAt',
      this,
    );
  }

  late final IdentityProviderUpdateTable updateTable;

  late final _i1.ColumnUuid identityId;

  /// The identity this provider belongs to.
  _i2.IdentityTable? _identity;

  late final _i1.ColumnEnum<_i3.AuthProvider> provider;

  /// Stable user id returned by the provider, for example Google sub or GitHub id.
  late final _i1.ColumnString providerUserId;

  /// Email returned by the provider, if available, stored normalized.
  late final _i1.ColumnString email;

  late final _i1.ColumnBool emailVerified;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime lastUsedAt;

  _i2.IdentityTable get identity {
    if (_identity != null) return _identity!;
    _identity = _i1.createRelationTable(
      relationFieldName: 'identity',
      field: IdentityProvider.t.identityId,
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
    provider,
    providerUserId,
    email,
    emailVerified,
    createdAt,
    lastUsedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'identity') {
      return identity;
    }
    return null;
  }
}

class IdentityProviderInclude extends _i1.IncludeObject {
  IdentityProviderInclude._({_i2.IdentityInclude? identity}) {
    _identity = identity;
  }

  _i2.IdentityInclude? _identity;

  @override
  Map<String, _i1.Include?> get includes => {'identity': _identity};

  @override
  _i1.Table<_i1.UuidValue?> get table => IdentityProvider.t;
}

class IdentityProviderIncludeList extends _i1.IncludeList {
  IdentityProviderIncludeList._({
    _i1.WhereExpressionBuilder<IdentityProviderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IdentityProvider.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => IdentityProvider.t;
}

class IdentityProviderRepository {
  const IdentityProviderRepository._();

  final attachRow = const IdentityProviderAttachRowRepository._();

  /// Returns a list of [IdentityProvider]s matching the given query parameters.
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
  Future<List<IdentityProvider>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdentityProviderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdentityProviderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdentityProviderTable>? orderByList,
    _i1.Transaction? transaction,
    IdentityProviderInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IdentityProvider>(
      where: where?.call(IdentityProvider.t),
      orderBy: orderBy?.call(IdentityProvider.t),
      orderByList: orderByList?.call(IdentityProvider.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [IdentityProvider] matching the given query parameters.
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
  Future<IdentityProvider?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdentityProviderTable>? where,
    int? offset,
    _i1.OrderByBuilder<IdentityProviderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdentityProviderTable>? orderByList,
    _i1.Transaction? transaction,
    IdentityProviderInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IdentityProvider>(
      where: where?.call(IdentityProvider.t),
      orderBy: orderBy?.call(IdentityProvider.t),
      orderByList: orderByList?.call(IdentityProvider.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IdentityProvider] by its [id] or null if no such row exists.
  Future<IdentityProvider?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    IdentityProviderInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IdentityProvider>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IdentityProvider]s in the list and returns the inserted rows.
  ///
  /// The returned [IdentityProvider]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<IdentityProvider>> insert(
    _i1.DatabaseSession session,
    List<IdentityProvider> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<IdentityProvider>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [IdentityProvider] and returns the inserted row.
  ///
  /// The returned [IdentityProvider] will have its `id` field set.
  Future<IdentityProvider> insertRow(
    _i1.DatabaseSession session,
    IdentityProvider row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<IdentityProvider>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [IdentityProvider]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<IdentityProvider>> update(
    _i1.DatabaseSession session,
    List<IdentityProvider> rows, {
    _i1.ColumnSelections<IdentityProviderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<IdentityProvider>(
      rows,
      columns: columns?.call(IdentityProvider.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IdentityProvider]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IdentityProvider> updateRow(
    _i1.DatabaseSession session,
    IdentityProvider row, {
    _i1.ColumnSelections<IdentityProviderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<IdentityProvider>(
      row,
      columns: columns?.call(IdentityProvider.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IdentityProvider] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IdentityProvider?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<IdentityProviderUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<IdentityProvider>(
      id,
      columnValues: columnValues(IdentityProvider.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IdentityProvider]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<IdentityProvider>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<IdentityProviderUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<IdentityProviderTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdentityProviderTable>? orderBy,
    _i1.OrderByListBuilder<IdentityProviderTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<IdentityProvider>(
      columnValues: columnValues(IdentityProvider.t.updateTable),
      where: where(IdentityProvider.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IdentityProvider.t),
      orderByList: orderByList?.call(IdentityProvider.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [IdentityProvider]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<IdentityProvider>> delete(
    _i1.DatabaseSession session,
    List<IdentityProvider> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<IdentityProvider>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [IdentityProvider].
  Future<IdentityProvider> deleteRow(
    _i1.DatabaseSession session,
    IdentityProvider row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IdentityProvider>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<IdentityProvider>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IdentityProviderTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<IdentityProvider>(
      where: where(IdentityProvider.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdentityProviderTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<IdentityProvider>(
      where: where?.call(IdentityProvider.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IdentityProvider] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IdentityProviderTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IdentityProvider>(
      where: where(IdentityProvider.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class IdentityProviderAttachRowRepository {
  const IdentityProviderAttachRowRepository._();

  /// Creates a relation between the given [IdentityProvider] and [Identity]
  /// by setting the [IdentityProvider]'s foreign key `identityId` to refer to the [Identity].
  Future<void> identity(
    _i1.DatabaseSession session,
    IdentityProvider identityProvider,
    _i2.Identity identity, {
    _i1.Transaction? transaction,
  }) async {
    if (identityProvider.id == null) {
      throw ArgumentError.notNull('identityProvider.id');
    }
    if (identity.id == null) {
      throw ArgumentError.notNull('identity.id');
    }

    var $identityProvider = identityProvider.copyWith(identityId: identity.id);
    await session.db.updateRow<IdentityProvider>(
      $identityProvider,
      columns: [IdentityProvider.t.identityId],
      transaction: transaction,
    );
  }
}
