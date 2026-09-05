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
import '../../projects/models/project_link_status.dart' as _i2;
import '../../projects/models/project.dart' as _i3;
import '../../projects/models/project_link_kind.dart' as _i4;
import 'package:projects_server/src/generated/protocol.dart' as _i5;

/// Lightweight reference from a project to another Nexus resource.
abstract class ProjectLink
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  ProjectLink._({
    this.id,
    required this.projectId,
    this.project,
    required this.kind,
    required this.service,
    required this.externalId,
    this.label,
    this.uri,
    _i2.ProjectLinkStatus? status,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.ProjectLinkStatus.active,
       createdAt = createdAt ?? DateTime.now();

  factory ProjectLink({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectLinkKind kind,
    required String service,
    required String externalId,
    String? label,
    String? uri,
    _i2.ProjectLinkStatus? status,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectLinkImpl;

  factory ProjectLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectLink(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      project: jsonSerialization['project'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.Project>(
              jsonSerialization['project'],
            ),
      kind: _i4.ProjectLinkKind.fromJson((jsonSerialization['kind'] as String)),
      service: jsonSerialization['service'] as String,
      externalId: jsonSerialization['externalId'] as String,
      label: jsonSerialization['label'] as String?,
      uri: jsonSerialization['uri'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.ProjectLinkStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      metadata: jsonSerialization['metadata'] == null
          ? null
          : _i5.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['metadata'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ProjectLinkTable();

  static const db = ProjectLinkRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue projectId;

  _i3.Project? project;

  _i4.ProjectLinkKind kind;

  /// Owning service name, for example missions, labs, data, documents, history.
  String service;

  /// External resource id managed by the owning service.
  String externalId;

  String? label;

  String? uri;

  _i2.ProjectLinkStatus status;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ProjectLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectLink copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i3.Project? project,
    _i4.ProjectLinkKind? kind,
    String? service,
    String? externalId,
    String? label,
    String? uri,
    _i2.ProjectLinkStatus? status,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectLink',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      'kind': kind.toJson(),
      'service': service,
      'externalId': externalId,
      if (label != null) 'label': label,
      if (uri != null) 'uri': uri,
      'status': status.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectLink',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJsonForProtocol(),
      'kind': kind.toJson(),
      'service': service,
      'externalId': externalId,
      if (label != null) 'label': label,
      if (uri != null) 'uri': uri,
      'status': status.toJson(),
      if (metadata != null) 'metadata': metadata?.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static ProjectLinkInclude include({_i3.ProjectInclude? project}) {
    return ProjectLinkInclude._(project: project);
  }

  static ProjectLinkIncludeList includeList({
    _i1.WhereExpressionBuilder<ProjectLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectLinkTable>? orderByList,
    ProjectLinkInclude? include,
  }) {
    return ProjectLinkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectLink.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProjectLink.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectLinkImpl extends ProjectLink {
  _ProjectLinkImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectLinkKind kind,
    required String service,
    required String externalId,
    String? label,
    String? uri,
    _i2.ProjectLinkStatus? status,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         kind: kind,
         service: service,
         externalId: externalId,
         label: label,
         uri: uri,
         status: status,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ProjectLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectLink copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    _i4.ProjectLinkKind? kind,
    String? service,
    String? externalId,
    Object? label = _Undefined,
    Object? uri = _Undefined,
    _i2.ProjectLinkStatus? status,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return ProjectLink(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i3.Project? ? project : this.project?.copyWith(),
      kind: kind ?? this.kind,
      service: service ?? this.service,
      externalId: externalId ?? this.externalId,
      label: label is String? ? label : this.label,
      uri: uri is String? ? uri : this.uri,
      status: status ?? this.status,
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
    );
  }
}

class ProjectLinkUpdateTable extends _i1.UpdateTable<ProjectLinkTable> {
  ProjectLinkUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<_i4.ProjectLinkKind, _i4.ProjectLinkKind> kind(
    _i4.ProjectLinkKind value,
  ) => _i1.ColumnValue(
    table.kind,
    value,
  );

  _i1.ColumnValue<String, String> service(String value) => _i1.ColumnValue(
    table.service,
    value,
  );

  _i1.ColumnValue<String, String> externalId(String value) => _i1.ColumnValue(
    table.externalId,
    value,
  );

  _i1.ColumnValue<String, String> label(String? value) => _i1.ColumnValue(
    table.label,
    value,
  );

  _i1.ColumnValue<String, String> uri(String? value) => _i1.ColumnValue(
    table.uri,
    value,
  );

  _i1.ColumnValue<_i2.ProjectLinkStatus, _i2.ProjectLinkStatus> status(
    _i2.ProjectLinkStatus value,
  ) => _i1.ColumnValue(
    table.status,
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
}

class ProjectLinkTable extends _i1.Table<_i1.UuidValue?> {
  ProjectLinkTable({super.tableRelation}) : super(tableName: 'project_link') {
    updateTable = ProjectLinkUpdateTable(this);
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    kind = _i1.ColumnEnum(
      'kind',
      this,
      _i1.EnumSerialization.byName,
    );
    service = _i1.ColumnString(
      'service',
      this,
    );
    externalId = _i1.ColumnString(
      'externalId',
      this,
    );
    label = _i1.ColumnString(
      'label',
      this,
    );
    uri = _i1.ColumnString(
      'uri',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
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
  }

  late final ProjectLinkUpdateTable updateTable;

  late final _i1.ColumnUuid projectId;

  _i3.ProjectTable? _project;

  late final _i1.ColumnEnum<_i4.ProjectLinkKind> kind;

  /// Owning service name, for example missions, labs, data, documents, history.
  late final _i1.ColumnString service;

  /// External resource id managed by the owning service.
  late final _i1.ColumnString externalId;

  late final _i1.ColumnString label;

  late final _i1.ColumnString uri;

  late final _i1.ColumnEnum<_i2.ProjectLinkStatus> status;

  late final _i1.ColumnSerializable<Map<String, String>> metadata;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  _i3.ProjectTable get project {
    if (_project != null) return _project!;
    _project = _i1.createRelationTable(
      relationFieldName: 'project',
      field: ProjectLink.t.projectId,
      foreignField: _i3.Project.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ProjectTable(tableRelation: foreignTableRelation),
    );
    return _project!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    projectId,
    kind,
    service,
    externalId,
    label,
    uri,
    status,
    metadata,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'project') {
      return project;
    }
    return null;
  }
}

class ProjectLinkInclude extends _i1.IncludeObject {
  ProjectLinkInclude._({_i3.ProjectInclude? project}) {
    _project = project;
  }

  _i3.ProjectInclude? _project;

  @override
  Map<String, _i1.Include?> get includes => {'project': _project};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectLink.t;
}

class ProjectLinkIncludeList extends _i1.IncludeList {
  ProjectLinkIncludeList._({
    _i1.WhereExpressionBuilder<ProjectLinkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProjectLink.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectLink.t;
}

class ProjectLinkRepository {
  const ProjectLinkRepository._();

  final attachRow = const ProjectLinkAttachRowRepository._();

  /// Returns a list of [ProjectLink]s matching the given query parameters.
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
  Future<List<ProjectLink>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectLinkTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectLinkInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProjectLink>(
      where: where?.call(ProjectLink.t),
      orderBy: orderBy?.call(ProjectLink.t),
      orderByList: orderByList?.call(ProjectLink.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProjectLink] matching the given query parameters.
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
  Future<ProjectLink?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectLinkTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProjectLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectLinkTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectLinkInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProjectLink>(
      where: where?.call(ProjectLink.t),
      orderBy: orderBy?.call(ProjectLink.t),
      orderByList: orderByList?.call(ProjectLink.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProjectLink] by its [id] or null if no such row exists.
  Future<ProjectLink?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    ProjectLinkInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProjectLink>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProjectLink]s in the list and returns the inserted rows.
  ///
  /// The returned [ProjectLink]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ProjectLink>> insert(
    _i1.DatabaseSession session,
    List<ProjectLink> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ProjectLink>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ProjectLink] and returns the inserted row.
  ///
  /// The returned [ProjectLink] will have its `id` field set.
  Future<ProjectLink> insertRow(
    _i1.DatabaseSession session,
    ProjectLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProjectLink>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProjectLink]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProjectLink>> update(
    _i1.DatabaseSession session,
    List<ProjectLink> rows, {
    _i1.ColumnSelections<ProjectLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProjectLink>(
      rows,
      columns: columns?.call(ProjectLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectLink]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProjectLink> updateRow(
    _i1.DatabaseSession session,
    ProjectLink row, {
    _i1.ColumnSelections<ProjectLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProjectLink>(
      row,
      columns: columns?.call(ProjectLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectLink] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProjectLink?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ProjectLinkUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ProjectLink>(
      id,
      columnValues: columnValues(ProjectLink.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProjectLink]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ProjectLink>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProjectLinkUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProjectLinkTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectLinkTable>? orderBy,
    _i1.OrderByListBuilder<ProjectLinkTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ProjectLink>(
      columnValues: columnValues(ProjectLink.t.updateTable),
      where: where(ProjectLink.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectLink.t),
      orderByList: orderByList?.call(ProjectLink.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ProjectLink]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProjectLink>> delete(
    _i1.DatabaseSession session,
    List<ProjectLink> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProjectLink>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProjectLink].
  Future<ProjectLink> deleteRow(
    _i1.DatabaseSession session,
    ProjectLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProjectLink>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProjectLink>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectLinkTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProjectLink>(
      where: where(ProjectLink.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectLinkTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProjectLink>(
      where: where?.call(ProjectLink.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProjectLink] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectLinkTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProjectLink>(
      where: where(ProjectLink.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ProjectLinkAttachRowRepository {
  const ProjectLinkAttachRowRepository._();

  /// Creates a relation between the given [ProjectLink] and [Project]
  /// by setting the [ProjectLink]'s foreign key `projectId` to refer to the [Project].
  Future<void> project(
    _i1.DatabaseSession session,
    ProjectLink projectLink,
    _i3.Project project, {
    _i1.Transaction? transaction,
  }) async {
    if (projectLink.id == null) {
      throw ArgumentError.notNull('projectLink.id');
    }
    if (project.id == null) {
      throw ArgumentError.notNull('project.id');
    }

    var $projectLink = projectLink.copyWith(projectId: project.id);
    await session.db.updateRow<ProjectLink>(
      $projectLink,
      columns: [ProjectLink.t.projectId],
      transaction: transaction,
    );
  }
}
