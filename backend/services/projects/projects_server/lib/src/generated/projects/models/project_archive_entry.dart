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
import '../../projects/models/project.dart' as _i2;
import 'package:projects_server/src/generated/protocol.dart' as _i3;

/// Archive lifecycle record for a project.
abstract class ProjectArchiveEntry
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  ProjectArchiveEntry._({
    this.id,
    required this.projectId,
    this.project,
    this.archivePath,
    this.reason,
    this.archivedByIdentityId,
    DateTime? archivedAt,
    this.restoredAt,
    this.restoredByIdentityId,
    this.metadata,
  }) : archivedAt = archivedAt ?? DateTime.now();

  factory ProjectArchiveEntry({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    String? archivePath,
    String? reason,
    _i1.UuidValue? archivedByIdentityId,
    DateTime? archivedAt,
    DateTime? restoredAt,
    _i1.UuidValue? restoredByIdentityId,
    Map<String, String>? metadata,
  }) = _ProjectArchiveEntryImpl;

  factory ProjectArchiveEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectArchiveEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      project: jsonSerialization['project'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Project>(
              jsonSerialization['project'],
            ),
      archivePath: jsonSerialization['archivePath'] as String?,
      reason: jsonSerialization['reason'] as String?,
      archivedByIdentityId: jsonSerialization['archivedByIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['archivedByIdentityId'],
            ),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      restoredAt: jsonSerialization['restoredAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['restoredAt']),
      restoredByIdentityId: jsonSerialization['restoredByIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['restoredByIdentityId'],
            ),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _i3.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['metadata'],
            ),
    );
  }

  static final t = ProjectArchiveEntryTable();

  static const db = ProjectArchiveEntryRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue projectId;

  _i2.Project? project;

  String? archivePath;

  String? reason;

  /// Identity service UUID of the actor that archived the project.
  _i1.UuidValue? archivedByIdentityId;

  DateTime archivedAt;

  DateTime? restoredAt;

  _i1.UuidValue? restoredByIdentityId;

  Map<String, String>? metadata;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ProjectArchiveEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectArchiveEntry copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i2.Project? project,
    String? archivePath,
    String? reason,
    _i1.UuidValue? archivedByIdentityId,
    DateTime? archivedAt,
    DateTime? restoredAt,
    _i1.UuidValue? restoredByIdentityId,
    Map<String, String>? metadata,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectArchiveEntry',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      if (archivePath != null) 'archivePath': archivePath,
      if (reason != null) 'reason': reason,
      if (archivedByIdentityId != null)
        'archivedByIdentityId': archivedByIdentityId?.toJson(),
      'archivedAt': archivedAt.toJson(),
      if (restoredAt != null) 'restoredAt': restoredAt?.toJson(),
      if (restoredByIdentityId != null)
        'restoredByIdentityId': restoredByIdentityId?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectArchiveEntry',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJsonForProtocol(),
      if (archivePath != null) 'archivePath': archivePath,
      if (reason != null) 'reason': reason,
      if (archivedByIdentityId != null)
        'archivedByIdentityId': archivedByIdentityId?.toJson(),
      'archivedAt': archivedAt.toJson(),
      if (restoredAt != null) 'restoredAt': restoredAt?.toJson(),
      if (restoredByIdentityId != null)
        'restoredByIdentityId': restoredByIdentityId?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
    };
  }

  static ProjectArchiveEntryInclude include({_i2.ProjectInclude? project}) {
    return ProjectArchiveEntryInclude._(project: project);
  }

  static ProjectArchiveEntryIncludeList includeList({
    _i1.WhereExpressionBuilder<ProjectArchiveEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectArchiveEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectArchiveEntryTable>? orderByList,
    ProjectArchiveEntryInclude? include,
  }) {
    return ProjectArchiveEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectArchiveEntry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProjectArchiveEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectArchiveEntryImpl extends ProjectArchiveEntry {
  _ProjectArchiveEntryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    String? archivePath,
    String? reason,
    _i1.UuidValue? archivedByIdentityId,
    DateTime? archivedAt,
    DateTime? restoredAt,
    _i1.UuidValue? restoredByIdentityId,
    Map<String, String>? metadata,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         archivePath: archivePath,
         reason: reason,
         archivedByIdentityId: archivedByIdentityId,
         archivedAt: archivedAt,
         restoredAt: restoredAt,
         restoredByIdentityId: restoredByIdentityId,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [ProjectArchiveEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectArchiveEntry copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    Object? archivePath = _Undefined,
    Object? reason = _Undefined,
    Object? archivedByIdentityId = _Undefined,
    DateTime? archivedAt,
    Object? restoredAt = _Undefined,
    Object? restoredByIdentityId = _Undefined,
    Object? metadata = _Undefined,
  }) {
    return ProjectArchiveEntry(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i2.Project? ? project : this.project?.copyWith(),
      archivePath: archivePath is String? ? archivePath : this.archivePath,
      reason: reason is String? ? reason : this.reason,
      archivedByIdentityId: archivedByIdentityId is _i1.UuidValue?
          ? archivedByIdentityId
          : this.archivedByIdentityId,
      archivedAt: archivedAt ?? this.archivedAt,
      restoredAt: restoredAt is DateTime? ? restoredAt : this.restoredAt,
      restoredByIdentityId: restoredByIdentityId is _i1.UuidValue?
          ? restoredByIdentityId
          : this.restoredByIdentityId,
      metadata: metadata is Map<String, String>?
          ? metadata
          : this.metadata?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
    );
  }
}

class ProjectArchiveEntryUpdateTable
    extends _i1.UpdateTable<ProjectArchiveEntryTable> {
  ProjectArchiveEntryUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<String, String> archivePath(String? value) => _i1.ColumnValue(
    table.archivePath,
    value,
  );

  _i1.ColumnValue<String, String> reason(String? value) => _i1.ColumnValue(
    table.reason,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> archivedByIdentityId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.archivedByIdentityId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> archivedAt(DateTime value) =>
      _i1.ColumnValue(
        table.archivedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> restoredAt(DateTime? value) =>
      _i1.ColumnValue(
        table.restoredAt,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> restoredByIdentityId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.restoredByIdentityId,
    value,
  );

  _i1.ColumnValue<Map<String, String>, Map<String, String>> metadata(
    Map<String, String>? value,
  ) => _i1.ColumnValue(
    table.metadata,
    value,
  );
}

class ProjectArchiveEntryTable extends _i1.Table<_i1.UuidValue?> {
  ProjectArchiveEntryTable({super.tableRelation})
    : super(tableName: 'project_archive_entry') {
    updateTable = ProjectArchiveEntryUpdateTable(this);
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    archivePath = _i1.ColumnString(
      'archivePath',
      this,
    );
    reason = _i1.ColumnString(
      'reason',
      this,
    );
    archivedByIdentityId = _i1.ColumnUuid(
      'archivedByIdentityId',
      this,
    );
    archivedAt = _i1.ColumnDateTime(
      'archivedAt',
      this,
      hasDefault: true,
    );
    restoredAt = _i1.ColumnDateTime(
      'restoredAt',
      this,
    );
    restoredByIdentityId = _i1.ColumnUuid(
      'restoredByIdentityId',
      this,
    );
    metadata = _i1.ColumnSerializable<Map<String, String>>(
      'metadata',
      this,
    );
  }

  late final ProjectArchiveEntryUpdateTable updateTable;

  late final _i1.ColumnUuid projectId;

  _i2.ProjectTable? _project;

  late final _i1.ColumnString archivePath;

  late final _i1.ColumnString reason;

  /// Identity service UUID of the actor that archived the project.
  late final _i1.ColumnUuid archivedByIdentityId;

  late final _i1.ColumnDateTime archivedAt;

  late final _i1.ColumnDateTime restoredAt;

  late final _i1.ColumnUuid restoredByIdentityId;

  late final _i1.ColumnSerializable<Map<String, String>> metadata;

  _i2.ProjectTable get project {
    if (_project != null) return _project!;
    _project = _i1.createRelationTable(
      relationFieldName: 'project',
      field: ProjectArchiveEntry.t.projectId,
      foreignField: _i2.Project.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ProjectTable(tableRelation: foreignTableRelation),
    );
    return _project!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    projectId,
    archivePath,
    reason,
    archivedByIdentityId,
    archivedAt,
    restoredAt,
    restoredByIdentityId,
    metadata,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'project') {
      return project;
    }
    return null;
  }
}

class ProjectArchiveEntryInclude extends _i1.IncludeObject {
  ProjectArchiveEntryInclude._({_i2.ProjectInclude? project}) {
    _project = project;
  }

  _i2.ProjectInclude? _project;

  @override
  Map<String, _i1.Include?> get includes => {'project': _project};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectArchiveEntry.t;
}

class ProjectArchiveEntryIncludeList extends _i1.IncludeList {
  ProjectArchiveEntryIncludeList._({
    _i1.WhereExpressionBuilder<ProjectArchiveEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProjectArchiveEntry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectArchiveEntry.t;
}

class ProjectArchiveEntryRepository {
  const ProjectArchiveEntryRepository._();

  final attachRow = const ProjectArchiveEntryAttachRowRepository._();

  /// Returns a list of [ProjectArchiveEntry]s matching the given query parameters.
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
  Future<List<ProjectArchiveEntry>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectArchiveEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectArchiveEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectArchiveEntryTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectArchiveEntryInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProjectArchiveEntry>(
      where: where?.call(ProjectArchiveEntry.t),
      orderBy: orderBy?.call(ProjectArchiveEntry.t),
      orderByList: orderByList?.call(ProjectArchiveEntry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProjectArchiveEntry] matching the given query parameters.
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
  Future<ProjectArchiveEntry?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectArchiveEntryTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProjectArchiveEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectArchiveEntryTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectArchiveEntryInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProjectArchiveEntry>(
      where: where?.call(ProjectArchiveEntry.t),
      orderBy: orderBy?.call(ProjectArchiveEntry.t),
      orderByList: orderByList?.call(ProjectArchiveEntry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProjectArchiveEntry] by its [id] or null if no such row exists.
  Future<ProjectArchiveEntry?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    ProjectArchiveEntryInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProjectArchiveEntry>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProjectArchiveEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [ProjectArchiveEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ProjectArchiveEntry>> insert(
    _i1.DatabaseSession session,
    List<ProjectArchiveEntry> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ProjectArchiveEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ProjectArchiveEntry] and returns the inserted row.
  ///
  /// The returned [ProjectArchiveEntry] will have its `id` field set.
  Future<ProjectArchiveEntry> insertRow(
    _i1.DatabaseSession session,
    ProjectArchiveEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProjectArchiveEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProjectArchiveEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProjectArchiveEntry>> update(
    _i1.DatabaseSession session,
    List<ProjectArchiveEntry> rows, {
    _i1.ColumnSelections<ProjectArchiveEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProjectArchiveEntry>(
      rows,
      columns: columns?.call(ProjectArchiveEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectArchiveEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProjectArchiveEntry> updateRow(
    _i1.DatabaseSession session,
    ProjectArchiveEntry row, {
    _i1.ColumnSelections<ProjectArchiveEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProjectArchiveEntry>(
      row,
      columns: columns?.call(ProjectArchiveEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectArchiveEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProjectArchiveEntry?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ProjectArchiveEntryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ProjectArchiveEntry>(
      id,
      columnValues: columnValues(ProjectArchiveEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProjectArchiveEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ProjectArchiveEntry>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProjectArchiveEntryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ProjectArchiveEntryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectArchiveEntryTable>? orderBy,
    _i1.OrderByListBuilder<ProjectArchiveEntryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ProjectArchiveEntry>(
      columnValues: columnValues(ProjectArchiveEntry.t.updateTable),
      where: where(ProjectArchiveEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectArchiveEntry.t),
      orderByList: orderByList?.call(ProjectArchiveEntry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ProjectArchiveEntry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProjectArchiveEntry>> delete(
    _i1.DatabaseSession session,
    List<ProjectArchiveEntry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProjectArchiveEntry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProjectArchiveEntry].
  Future<ProjectArchiveEntry> deleteRow(
    _i1.DatabaseSession session,
    ProjectArchiveEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProjectArchiveEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProjectArchiveEntry>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectArchiveEntryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProjectArchiveEntry>(
      where: where(ProjectArchiveEntry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectArchiveEntryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProjectArchiveEntry>(
      where: where?.call(ProjectArchiveEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProjectArchiveEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectArchiveEntryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProjectArchiveEntry>(
      where: where(ProjectArchiveEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ProjectArchiveEntryAttachRowRepository {
  const ProjectArchiveEntryAttachRowRepository._();

  /// Creates a relation between the given [ProjectArchiveEntry] and [Project]
  /// by setting the [ProjectArchiveEntry]'s foreign key `projectId` to refer to the [Project].
  Future<void> project(
    _i1.DatabaseSession session,
    ProjectArchiveEntry projectArchiveEntry,
    _i2.Project project, {
    _i1.Transaction? transaction,
  }) async {
    if (projectArchiveEntry.id == null) {
      throw ArgumentError.notNull('projectArchiveEntry.id');
    }
    if (project.id == null) {
      throw ArgumentError.notNull('project.id');
    }

    var $projectArchiveEntry = projectArchiveEntry.copyWith(
      projectId: project.id,
    );
    await session.db.updateRow<ProjectArchiveEntry>(
      $projectArchiveEntry,
      columns: [ProjectArchiveEntry.t.projectId],
      transaction: transaction,
    );
  }
}
