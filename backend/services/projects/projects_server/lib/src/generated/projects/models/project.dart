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
import '../../projects/models/project_status.dart' as _i2;
import '../../projects/models/project_visibility.dart' as _i3;
import 'package:projects_server/src/generated/protocol.dart' as _i4;

/// Registry entry for one Nexus workspace.
abstract class Project
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Project._({
    this.id,
    required this.slug,
    required this.name,
    this.summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    this.ownerIdentityId,
    this.workspacePath,
    this.archivePath,
    this.tags,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
    this.archivedAt,
  }) : status = status ?? _i2.ProjectStatus.active,
       visibility = visibility ?? _i3.ProjectVisibility.private,
       createdAt = createdAt ?? DateTime.now();

  factory Project({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    _i1.UuidValue? ownerIdentityId,
    String? workspacePath,
    String? archivePath,
    List<String>? tags,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      slug: jsonSerialization['slug'] as String,
      name: jsonSerialization['name'] as String,
      summary: jsonSerialization['summary'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.ProjectStatus.fromJson((jsonSerialization['status'] as String)),
      visibility: jsonSerialization['visibility'] == null
          ? null
          : _i3.ProjectVisibility.fromJson(
              (jsonSerialization['visibility'] as String),
            ),
      ownerIdentityId: jsonSerialization['ownerIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['ownerIdentityId'],
            ),
      workspacePath: jsonSerialization['workspacePath'] as String?,
      archivePath: jsonSerialization['archivePath'] as String?,
      tags: jsonSerialization['tags'] == null
          ? null
          : _i4.Protocol().deserialize<List<String>>(jsonSerialization['tags']),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _i4.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['metadata'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
    );
  }

  static final t = ProjectTable();

  static const db = ProjectRepository._();

  @override
  _i1.UuidValue? id;

  /// Stable human-readable key used in URLs and filesystem integrations.
  String slug;

  /// Display name shown in clients.
  String name;

  /// Short registry description. Domain-specific documents stay outside this service.
  String? summary;

  _i2.ProjectStatus status;

  _i3.ProjectVisibility visibility;

  /// Identity service UUID of the owner, kept as an external reference.
  _i1.UuidValue? ownerIdentityId;

  /// Optional local/source workspace path for filesystem-backed projects.
  String? workspacePath;

  /// Optional archive location when the project is archived.
  String? archivePath;

  List<String>? tags;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  DateTime? archivedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Project copyWith({
    _i1.UuidValue? id,
    String? slug,
    String? name,
    String? summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    _i1.UuidValue? ownerIdentityId,
    String? workspacePath,
    String? archivePath,
    List<String>? tags,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Project',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (summary != null) 'summary': summary,
      'status': status.toJson(),
      'visibility': visibility.toJson(),
      if (ownerIdentityId != null) 'ownerIdentityId': ownerIdentityId?.toJson(),
      if (workspacePath != null) 'workspacePath': workspacePath,
      if (archivePath != null) 'archivePath': archivePath,
      if (tags != null) 'tags': tags?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Project',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (summary != null) 'summary': summary,
      'status': status.toJson(),
      'visibility': visibility.toJson(),
      if (ownerIdentityId != null) 'ownerIdentityId': ownerIdentityId?.toJson(),
      if (workspacePath != null) 'workspacePath': workspacePath,
      if (archivePath != null) 'archivePath': archivePath,
      if (tags != null) 'tags': tags?.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
    };
  }

  static ProjectInclude include() {
    return ProjectInclude._();
  }

  static ProjectIncludeList includeList({
    _i1.WhereExpressionBuilder<ProjectTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectTable>? orderByList,
    ProjectInclude? include,
  }) {
    return ProjectIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Project.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Project.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectImpl extends Project {
  _ProjectImpl({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? summary,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    _i1.UuidValue? ownerIdentityId,
    String? workspacePath,
    String? archivePath,
    List<String>? tags,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) : super._(
         id: id,
         slug: slug,
         name: name,
         summary: summary,
         status: status,
         visibility: visibility,
         ownerIdentityId: ownerIdentityId,
         workspacePath: workspacePath,
         archivePath: archivePath,
         tags: tags,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
         archivedAt: archivedAt,
       );

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Project copyWith({
    Object? id = _Undefined,
    String? slug,
    String? name,
    Object? summary = _Undefined,
    _i2.ProjectStatus? status,
    _i3.ProjectVisibility? visibility,
    Object? ownerIdentityId = _Undefined,
    Object? workspacePath = _Undefined,
    Object? archivePath = _Undefined,
    Object? tags = _Undefined,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
    Object? archivedAt = _Undefined,
  }) {
    return Project(
      id: id is _i1.UuidValue? ? id : this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      summary: summary is String? ? summary : this.summary,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      ownerIdentityId: ownerIdentityId is _i1.UuidValue?
          ? ownerIdentityId
          : this.ownerIdentityId,
      workspacePath: workspacePath is String?
          ? workspacePath
          : this.workspacePath,
      archivePath: archivePath is String? ? archivePath : this.archivePath,
      tags: tags is List<String>? ? tags : this.tags?.map((e0) => e0).toList(),
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
    );
  }
}

class ProjectUpdateTable extends _i1.UpdateTable<ProjectTable> {
  ProjectUpdateTable(super.table);

  _i1.ColumnValue<String, String> slug(String value) => _i1.ColumnValue(
    table.slug,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> summary(String? value) => _i1.ColumnValue(
    table.summary,
    value,
  );

  _i1.ColumnValue<_i2.ProjectStatus, _i2.ProjectStatus> status(
    _i2.ProjectStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<_i3.ProjectVisibility, _i3.ProjectVisibility> visibility(
    _i3.ProjectVisibility value,
  ) => _i1.ColumnValue(
    table.visibility,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> ownerIdentityId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.ownerIdentityId,
    value,
  );

  _i1.ColumnValue<String, String> workspacePath(String? value) =>
      _i1.ColumnValue(
        table.workspacePath,
        value,
      );

  _i1.ColumnValue<String, String> archivePath(String? value) => _i1.ColumnValue(
    table.archivePath,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> tags(List<String>? value) =>
      _i1.ColumnValue(
        table.tags,
        value,
      );

  _i1.ColumnValue<Map<String, String>, Map<String, String>> metadata(
    Map<String, String>? value,
  ) => _i1.ColumnValue(
    table.metadata,
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

  _i1.ColumnValue<DateTime, DateTime> archivedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.archivedAt,
        value,
      );
}

class ProjectTable extends _i1.Table<_i1.UuidValue?> {
  ProjectTable({super.tableRelation}) : super(tableName: 'project') {
    updateTable = ProjectUpdateTable(this);
    slug = _i1.ColumnString(
      'slug',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    summary = _i1.ColumnString(
      'summary',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    visibility = _i1.ColumnEnum(
      'visibility',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    ownerIdentityId = _i1.ColumnUuid(
      'ownerIdentityId',
      this,
    );
    workspacePath = _i1.ColumnString(
      'workspacePath',
      this,
    );
    archivePath = _i1.ColumnString(
      'archivePath',
      this,
    );
    tags = _i1.ColumnSerializable<List<String>>(
      'tags',
      this,
    );
    metadata = _i1.ColumnSerializable<Map<String, String>>(
      'metadata',
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
    archivedAt = _i1.ColumnDateTime(
      'archivedAt',
      this,
    );
  }

  late final ProjectUpdateTable updateTable;

  /// Stable human-readable key used in URLs and filesystem integrations.
  late final _i1.ColumnString slug;

  /// Display name shown in clients.
  late final _i1.ColumnString name;

  /// Short registry description. Domain-specific documents stay outside this service.
  late final _i1.ColumnString summary;

  late final _i1.ColumnEnum<_i2.ProjectStatus> status;

  late final _i1.ColumnEnum<_i3.ProjectVisibility> visibility;

  /// Identity service UUID of the owner, kept as an external reference.
  late final _i1.ColumnUuid ownerIdentityId;

  /// Optional local/source workspace path for filesystem-backed projects.
  late final _i1.ColumnString workspacePath;

  /// Optional archive location when the project is archived.
  late final _i1.ColumnString archivePath;

  late final _i1.ColumnSerializable<List<String>> tags;

  late final _i1.ColumnSerializable<Map<String, String>> metadata;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime archivedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    slug,
    name,
    summary,
    status,
    visibility,
    ownerIdentityId,
    workspacePath,
    archivePath,
    tags,
    metadata,
    createdAt,
    updatedAt,
    archivedAt,
  ];
}

class ProjectInclude extends _i1.IncludeObject {
  ProjectInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Project.t;
}

class ProjectIncludeList extends _i1.IncludeList {
  ProjectIncludeList._({
    _i1.WhereExpressionBuilder<ProjectTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Project.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Project.t;
}

class ProjectRepository {
  const ProjectRepository._();

  /// Returns a list of [Project]s matching the given query parameters.
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
  Future<List<Project>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Project>(
      where: where?.call(Project.t),
      orderBy: orderBy?.call(Project.t),
      orderByList: orderByList?.call(Project.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Project] matching the given query parameters.
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
  Future<Project?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProjectTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Project>(
      where: where?.call(Project.t),
      orderBy: orderBy?.call(Project.t),
      orderByList: orderByList?.call(Project.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Project] by its [id] or null if no such row exists.
  Future<Project?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Project>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Project]s in the list and returns the inserted rows.
  ///
  /// The returned [Project]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Project>> insert(
    _i1.DatabaseSession session,
    List<Project> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Project>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Project] and returns the inserted row.
  ///
  /// The returned [Project] will have its `id` field set.
  Future<Project> insertRow(
    _i1.DatabaseSession session,
    Project row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Project>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Project]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Project>> update(
    _i1.DatabaseSession session,
    List<Project> rows, {
    _i1.ColumnSelections<ProjectTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Project>(
      rows,
      columns: columns?.call(Project.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Project]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Project> updateRow(
    _i1.DatabaseSession session,
    Project row, {
    _i1.ColumnSelections<ProjectTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Project>(
      row,
      columns: columns?.call(Project.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Project] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Project?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ProjectUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Project>(
      id,
      columnValues: columnValues(Project.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Project]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Project>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProjectUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProjectTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectTable>? orderBy,
    _i1.OrderByListBuilder<ProjectTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Project>(
      columnValues: columnValues(Project.t.updateTable),
      where: where(Project.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Project.t),
      orderByList: orderByList?.call(Project.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Project]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Project>> delete(
    _i1.DatabaseSession session,
    List<Project> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Project>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Project].
  Future<Project> deleteRow(
    _i1.DatabaseSession session,
    Project row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Project>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Project>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Project>(
      where: where(Project.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Project>(
      where: where?.call(Project.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Project] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Project>(
      where: where(Project.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
