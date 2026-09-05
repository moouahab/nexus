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
import '../../projects/models/project_event_kind.dart' as _i3;
import '../../projects/models/project_link_kind.dart' as _i4;
import 'package:projects_server/src/generated/protocol.dart' as _i5;

/// Timeline event for project registry activity.
abstract class ProjectEvent
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  ProjectEvent._({
    this.id,
    required this.projectId,
    this.project,
    required this.kind,
    this.message,
    this.actorIdentityId,
    this.resourceKind,
    this.resourceService,
    this.resourceExternalId,
    this.payload,
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  factory ProjectEvent({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    required _i3.ProjectEventKind kind,
    String? message,
    _i1.UuidValue? actorIdentityId,
    _i4.ProjectLinkKind? resourceKind,
    String? resourceService,
    String? resourceExternalId,
    Map<String, String>? payload,
    DateTime? occurredAt,
  }) = _ProjectEventImpl;

  factory ProjectEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      project: jsonSerialization['project'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.Project>(
              jsonSerialization['project'],
            ),
      kind: _i3.ProjectEventKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      message: jsonSerialization['message'] as String?,
      actorIdentityId: jsonSerialization['actorIdentityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['actorIdentityId'],
            ),
      resourceKind: jsonSerialization['resourceKind'] == null
          ? null
          : _i4.ProjectLinkKind.fromJson(
              (jsonSerialization['resourceKind'] as String),
            ),
      resourceService: jsonSerialization['resourceService'] as String?,
      resourceExternalId: jsonSerialization['resourceExternalId'] as String?,
      payload: jsonSerialization['payload'] == null
          ? null
          : _i5.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['payload'],
            ),
      occurredAt: jsonSerialization['occurredAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['occurredAt']),
    );
  }

  static final t = ProjectEventTable();

  static const db = ProjectEventRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue projectId;

  _i2.Project? project;

  _i3.ProjectEventKind kind;

  String? message;

  /// Identity service UUID of the actor that caused this event.
  _i1.UuidValue? actorIdentityId;

  _i4.ProjectLinkKind? resourceKind;

  String? resourceService;

  String? resourceExternalId;

  Map<String, String>? payload;

  DateTime occurredAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ProjectEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectEvent copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i2.Project? project,
    _i3.ProjectEventKind? kind,
    String? message,
    _i1.UuidValue? actorIdentityId,
    _i4.ProjectLinkKind? resourceKind,
    String? resourceService,
    String? resourceExternalId,
    Map<String, String>? payload,
    DateTime? occurredAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectEvent',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      'kind': kind.toJson(),
      if (message != null) 'message': message,
      if (actorIdentityId != null) 'actorIdentityId': actorIdentityId?.toJson(),
      if (resourceKind != null) 'resourceKind': resourceKind?.toJson(),
      if (resourceService != null) 'resourceService': resourceService,
      if (resourceExternalId != null) 'resourceExternalId': resourceExternalId,
      if (payload != null) 'payload': payload?.toJson(),
      'occurredAt': occurredAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectEvent',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJsonForProtocol(),
      'kind': kind.toJson(),
      if (message != null) 'message': message,
      if (actorIdentityId != null) 'actorIdentityId': actorIdentityId?.toJson(),
      if (resourceKind != null) 'resourceKind': resourceKind?.toJson(),
      if (resourceService != null) 'resourceService': resourceService,
      if (resourceExternalId != null) 'resourceExternalId': resourceExternalId,
      if (payload != null) 'payload': payload?.toJson(),
      'occurredAt': occurredAt.toJson(),
    };
  }

  static ProjectEventInclude include({_i2.ProjectInclude? project}) {
    return ProjectEventInclude._(project: project);
  }

  static ProjectEventIncludeList includeList({
    _i1.WhereExpressionBuilder<ProjectEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectEventTable>? orderByList,
    ProjectEventInclude? include,
  }) {
    return ProjectEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProjectEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectEventImpl extends ProjectEvent {
  _ProjectEventImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i2.Project? project,
    required _i3.ProjectEventKind kind,
    String? message,
    _i1.UuidValue? actorIdentityId,
    _i4.ProjectLinkKind? resourceKind,
    String? resourceService,
    String? resourceExternalId,
    Map<String, String>? payload,
    DateTime? occurredAt,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         kind: kind,
         message: message,
         actorIdentityId: actorIdentityId,
         resourceKind: resourceKind,
         resourceService: resourceService,
         resourceExternalId: resourceExternalId,
         payload: payload,
         occurredAt: occurredAt,
       );

  /// Returns a shallow copy of this [ProjectEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectEvent copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    _i3.ProjectEventKind? kind,
    Object? message = _Undefined,
    Object? actorIdentityId = _Undefined,
    Object? resourceKind = _Undefined,
    Object? resourceService = _Undefined,
    Object? resourceExternalId = _Undefined,
    Object? payload = _Undefined,
    DateTime? occurredAt,
  }) {
    return ProjectEvent(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i2.Project? ? project : this.project?.copyWith(),
      kind: kind ?? this.kind,
      message: message is String? ? message : this.message,
      actorIdentityId: actorIdentityId is _i1.UuidValue?
          ? actorIdentityId
          : this.actorIdentityId,
      resourceKind: resourceKind is _i4.ProjectLinkKind?
          ? resourceKind
          : this.resourceKind,
      resourceService: resourceService is String?
          ? resourceService
          : this.resourceService,
      resourceExternalId: resourceExternalId is String?
          ? resourceExternalId
          : this.resourceExternalId,
      payload: payload is Map<String, String>?
          ? payload
          : this.payload?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }
}

class ProjectEventUpdateTable extends _i1.UpdateTable<ProjectEventTable> {
  ProjectEventUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<_i3.ProjectEventKind, _i3.ProjectEventKind> kind(
    _i3.ProjectEventKind value,
  ) => _i1.ColumnValue(
    table.kind,
    value,
  );

  _i1.ColumnValue<String, String> message(String? value) => _i1.ColumnValue(
    table.message,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> actorIdentityId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.actorIdentityId,
    value,
  );

  _i1.ColumnValue<_i4.ProjectLinkKind, _i4.ProjectLinkKind> resourceKind(
    _i4.ProjectLinkKind? value,
  ) => _i1.ColumnValue(
    table.resourceKind,
    value,
  );

  _i1.ColumnValue<String, String> resourceService(String? value) =>
      _i1.ColumnValue(
        table.resourceService,
        value,
      );

  _i1.ColumnValue<String, String> resourceExternalId(String? value) =>
      _i1.ColumnValue(
        table.resourceExternalId,
        value,
      );

  _i1.ColumnValue<Map<String, String>, Map<String, String>> payload(
    Map<String, String>? value,
  ) => _i1.ColumnValue(
    table.payload,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> occurredAt(DateTime value) =>
      _i1.ColumnValue(
        table.occurredAt,
        value,
      );
}

class ProjectEventTable extends _i1.Table<_i1.UuidValue?> {
  ProjectEventTable({super.tableRelation}) : super(tableName: 'project_event') {
    updateTable = ProjectEventUpdateTable(this);
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    kind = _i1.ColumnEnum(
      'kind',
      this,
      _i1.EnumSerialization.byName,
    );
    message = _i1.ColumnString(
      'message',
      this,
    );
    actorIdentityId = _i1.ColumnUuid(
      'actorIdentityId',
      this,
    );
    resourceKind = _i1.ColumnEnum(
      'resourceKind',
      this,
      _i1.EnumSerialization.byName,
    );
    resourceService = _i1.ColumnString(
      'resourceService',
      this,
    );
    resourceExternalId = _i1.ColumnString(
      'resourceExternalId',
      this,
    );
    payload = _i1.ColumnSerializable<Map<String, String>>(
      'payload',
      this,
    );
    occurredAt = _i1.ColumnDateTime(
      'occurredAt',
      this,
      hasDefault: true,
    );
  }

  late final ProjectEventUpdateTable updateTable;

  late final _i1.ColumnUuid projectId;

  _i2.ProjectTable? _project;

  late final _i1.ColumnEnum<_i3.ProjectEventKind> kind;

  late final _i1.ColumnString message;

  /// Identity service UUID of the actor that caused this event.
  late final _i1.ColumnUuid actorIdentityId;

  late final _i1.ColumnEnum<_i4.ProjectLinkKind> resourceKind;

  late final _i1.ColumnString resourceService;

  late final _i1.ColumnString resourceExternalId;

  late final _i1.ColumnSerializable<Map<String, String>> payload;

  late final _i1.ColumnDateTime occurredAt;

  _i2.ProjectTable get project {
    if (_project != null) return _project!;
    _project = _i1.createRelationTable(
      relationFieldName: 'project',
      field: ProjectEvent.t.projectId,
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
    kind,
    message,
    actorIdentityId,
    resourceKind,
    resourceService,
    resourceExternalId,
    payload,
    occurredAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'project') {
      return project;
    }
    return null;
  }
}

class ProjectEventInclude extends _i1.IncludeObject {
  ProjectEventInclude._({_i2.ProjectInclude? project}) {
    _project = project;
  }

  _i2.ProjectInclude? _project;

  @override
  Map<String, _i1.Include?> get includes => {'project': _project};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectEvent.t;
}

class ProjectEventIncludeList extends _i1.IncludeList {
  ProjectEventIncludeList._({
    _i1.WhereExpressionBuilder<ProjectEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProjectEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectEvent.t;
}

class ProjectEventRepository {
  const ProjectEventRepository._();

  final attachRow = const ProjectEventAttachRowRepository._();

  /// Returns a list of [ProjectEvent]s matching the given query parameters.
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
  Future<List<ProjectEvent>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectEventTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectEventInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProjectEvent>(
      where: where?.call(ProjectEvent.t),
      orderBy: orderBy?.call(ProjectEvent.t),
      orderByList: orderByList?.call(ProjectEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProjectEvent] matching the given query parameters.
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
  Future<ProjectEvent?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProjectEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectEventTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectEventInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProjectEvent>(
      where: where?.call(ProjectEvent.t),
      orderBy: orderBy?.call(ProjectEvent.t),
      orderByList: orderByList?.call(ProjectEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProjectEvent] by its [id] or null if no such row exists.
  Future<ProjectEvent?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    ProjectEventInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProjectEvent>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProjectEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [ProjectEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ProjectEvent>> insert(
    _i1.DatabaseSession session,
    List<ProjectEvent> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ProjectEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ProjectEvent] and returns the inserted row.
  ///
  /// The returned [ProjectEvent] will have its `id` field set.
  Future<ProjectEvent> insertRow(
    _i1.DatabaseSession session,
    ProjectEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProjectEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProjectEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProjectEvent>> update(
    _i1.DatabaseSession session,
    List<ProjectEvent> rows, {
    _i1.ColumnSelections<ProjectEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProjectEvent>(
      rows,
      columns: columns?.call(ProjectEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProjectEvent> updateRow(
    _i1.DatabaseSession session,
    ProjectEvent row, {
    _i1.ColumnSelections<ProjectEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProjectEvent>(
      row,
      columns: columns?.call(ProjectEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProjectEvent?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ProjectEventUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ProjectEvent>(
      id,
      columnValues: columnValues(ProjectEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProjectEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ProjectEvent>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProjectEventUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProjectEventTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectEventTable>? orderBy,
    _i1.OrderByListBuilder<ProjectEventTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ProjectEvent>(
      columnValues: columnValues(ProjectEvent.t.updateTable),
      where: where(ProjectEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectEvent.t),
      orderByList: orderByList?.call(ProjectEvent.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ProjectEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProjectEvent>> delete(
    _i1.DatabaseSession session,
    List<ProjectEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProjectEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProjectEvent].
  Future<ProjectEvent> deleteRow(
    _i1.DatabaseSession session,
    ProjectEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProjectEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProjectEvent>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProjectEvent>(
      where: where(ProjectEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProjectEvent>(
      where: where?.call(ProjectEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProjectEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectEventTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProjectEvent>(
      where: where(ProjectEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ProjectEventAttachRowRepository {
  const ProjectEventAttachRowRepository._();

  /// Creates a relation between the given [ProjectEvent] and [Project]
  /// by setting the [ProjectEvent]'s foreign key `projectId` to refer to the [Project].
  Future<void> project(
    _i1.DatabaseSession session,
    ProjectEvent projectEvent,
    _i2.Project project, {
    _i1.Transaction? transaction,
  }) async {
    if (projectEvent.id == null) {
      throw ArgumentError.notNull('projectEvent.id');
    }
    if (project.id == null) {
      throw ArgumentError.notNull('project.id');
    }

    var $projectEvent = projectEvent.copyWith(projectId: project.id);
    await session.db.updateRow<ProjectEvent>(
      $projectEvent,
      columns: [ProjectEvent.t.projectId],
      transaction: transaction,
    );
  }
}
