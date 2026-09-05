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
import '../../projects/models/project_participant_status.dart' as _i2;
import '../../projects/models/project.dart' as _i3;
import '../../projects/models/project_participant_role.dart' as _i4;
import 'package:projects_server/src/generated/protocol.dart' as _i5;

/// Human or organization attached to a project.
abstract class ProjectParticipant
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  ProjectParticipant._({
    this.id,
    required this.projectId,
    this.project,
    required this.role,
    _i2.ProjectParticipantStatus? status,
    this.identityId,
    this.externalId,
    this.displayName,
    this.organizationName,
    this.email,
    this.phone,
    this.notes,
    bool? isPrimary,
    this.metadata,
    DateTime? createdAt,
    this.updatedAt,
  }) : status = status ?? _i2.ProjectParticipantStatus.active,
       isPrimary = isPrimary ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory ProjectParticipant({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectParticipantRole role,
    _i2.ProjectParticipantStatus? status,
    _i1.UuidValue? identityId,
    String? externalId,
    String? displayName,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    bool? isPrimary,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectParticipantImpl;

  factory ProjectParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectParticipant(
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
      role: _i4.ProjectParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.ProjectParticipantStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      identityId: jsonSerialization['identityId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['identityId'],
            ),
      externalId: jsonSerialization['externalId'] as String?,
      displayName: jsonSerialization['displayName'] as String?,
      organizationName: jsonSerialization['organizationName'] as String?,
      email: jsonSerialization['email'] as String?,
      phone: jsonSerialization['phone'] as String?,
      notes: jsonSerialization['notes'] as String?,
      isPrimary: jsonSerialization['isPrimary'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isPrimary']),
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

  static final t = ProjectParticipantTable();

  static const db = ProjectParticipantRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue projectId;

  _i3.Project? project;

  /// Role in the project registry, not a permission model by itself.
  _i4.ProjectParticipantRole role;

  _i2.ProjectParticipantStatus status;

  /// Identity service UUID for Nexus-side users when available.
  _i1.UuidValue? identityId;

  /// External CRM/customer/contact id when this participant comes from another system.
  String? externalId;

  String? displayName;

  String? organizationName;

  String? email;

  String? phone;

  String? notes;

  /// Marks the main client or main client referent for quick lookup.
  bool isPrimary;

  Map<String, String>? metadata;

  DateTime createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ProjectParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectParticipant copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    _i3.Project? project,
    _i4.ProjectParticipantRole? role,
    _i2.ProjectParticipantStatus? status,
    _i1.UuidValue? identityId,
    String? externalId,
    String? displayName,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    bool? isPrimary,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectParticipant',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJson(),
      'role': role.toJson(),
      'status': status.toJson(),
      if (identityId != null) 'identityId': identityId?.toJson(),
      if (externalId != null) 'externalId': externalId,
      if (displayName != null) 'displayName': displayName,
      if (organizationName != null) 'organizationName': organizationName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      'isPrimary': isPrimary,
      if (metadata != null) 'metadata': metadata?.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProjectParticipant',
      if (id != null) 'id': id?.toJson(),
      'projectId': projectId.toJson(),
      if (project != null) 'project': project?.toJsonForProtocol(),
      'role': role.toJson(),
      'status': status.toJson(),
      if (identityId != null) 'identityId': identityId?.toJson(),
      if (externalId != null) 'externalId': externalId,
      if (displayName != null) 'displayName': displayName,
      if (organizationName != null) 'organizationName': organizationName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      'isPrimary': isPrimary,
      if (metadata != null) 'metadata': metadata?.toJson(),
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static ProjectParticipantInclude include({_i3.ProjectInclude? project}) {
    return ProjectParticipantInclude._(project: project);
  }

  static ProjectParticipantIncludeList includeList({
    _i1.WhereExpressionBuilder<ProjectParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectParticipantTable>? orderByList,
    ProjectParticipantInclude? include,
  }) {
    return ProjectParticipantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectParticipant.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProjectParticipant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectParticipantImpl extends ProjectParticipant {
  _ProjectParticipantImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    _i3.Project? project,
    required _i4.ProjectParticipantRole role,
    _i2.ProjectParticipantStatus? status,
    _i1.UuidValue? identityId,
    String? externalId,
    String? displayName,
    String? organizationName,
    String? email,
    String? phone,
    String? notes,
    bool? isPrimary,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         projectId: projectId,
         project: project,
         role: role,
         status: status,
         identityId: identityId,
         externalId: externalId,
         displayName: displayName,
         organizationName: organizationName,
         email: email,
         phone: phone,
         notes: notes,
         isPrimary: isPrimary,
         metadata: metadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ProjectParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectParticipant copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? projectId,
    Object? project = _Undefined,
    _i4.ProjectParticipantRole? role,
    _i2.ProjectParticipantStatus? status,
    Object? identityId = _Undefined,
    Object? externalId = _Undefined,
    Object? displayName = _Undefined,
    Object? organizationName = _Undefined,
    Object? email = _Undefined,
    Object? phone = _Undefined,
    Object? notes = _Undefined,
    bool? isPrimary,
    Object? metadata = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return ProjectParticipant(
      id: id is _i1.UuidValue? ? id : this.id,
      projectId: projectId ?? this.projectId,
      project: project is _i3.Project? ? project : this.project?.copyWith(),
      role: role ?? this.role,
      status: status ?? this.status,
      identityId: identityId is _i1.UuidValue? ? identityId : this.identityId,
      externalId: externalId is String? ? externalId : this.externalId,
      displayName: displayName is String? ? displayName : this.displayName,
      organizationName: organizationName is String?
          ? organizationName
          : this.organizationName,
      email: email is String? ? email : this.email,
      phone: phone is String? ? phone : this.phone,
      notes: notes is String? ? notes : this.notes,
      isPrimary: isPrimary ?? this.isPrimary,
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

class ProjectParticipantUpdateTable
    extends _i1.UpdateTable<ProjectParticipantTable> {
  ProjectParticipantUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<_i4.ProjectParticipantRole, _i4.ProjectParticipantRole> role(
    _i4.ProjectParticipantRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<_i2.ProjectParticipantStatus, _i2.ProjectParticipantStatus>
  status(_i2.ProjectParticipantStatus value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> identityId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.identityId,
    value,
  );

  _i1.ColumnValue<String, String> externalId(String? value) => _i1.ColumnValue(
    table.externalId,
    value,
  );

  _i1.ColumnValue<String, String> displayName(String? value) => _i1.ColumnValue(
    table.displayName,
    value,
  );

  _i1.ColumnValue<String, String> organizationName(String? value) =>
      _i1.ColumnValue(
        table.organizationName,
        value,
      );

  _i1.ColumnValue<String, String> email(String? value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> phone(String? value) => _i1.ColumnValue(
    table.phone,
    value,
  );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<bool, bool> isPrimary(bool value) => _i1.ColumnValue(
    table.isPrimary,
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

class ProjectParticipantTable extends _i1.Table<_i1.UuidValue?> {
  ProjectParticipantTable({super.tableRelation})
    : super(tableName: 'project_participant') {
    updateTable = ProjectParticipantUpdateTable(this);
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    identityId = _i1.ColumnUuid(
      'identityId',
      this,
    );
    externalId = _i1.ColumnString(
      'externalId',
      this,
    );
    displayName = _i1.ColumnString(
      'displayName',
      this,
    );
    organizationName = _i1.ColumnString(
      'organizationName',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    phone = _i1.ColumnString(
      'phone',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    isPrimary = _i1.ColumnBool(
      'isPrimary',
      this,
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

  late final ProjectParticipantUpdateTable updateTable;

  late final _i1.ColumnUuid projectId;

  _i3.ProjectTable? _project;

  /// Role in the project registry, not a permission model by itself.
  late final _i1.ColumnEnum<_i4.ProjectParticipantRole> role;

  late final _i1.ColumnEnum<_i2.ProjectParticipantStatus> status;

  /// Identity service UUID for Nexus-side users when available.
  late final _i1.ColumnUuid identityId;

  /// External CRM/customer/contact id when this participant comes from another system.
  late final _i1.ColumnString externalId;

  late final _i1.ColumnString displayName;

  late final _i1.ColumnString organizationName;

  late final _i1.ColumnString email;

  late final _i1.ColumnString phone;

  late final _i1.ColumnString notes;

  /// Marks the main client or main client referent for quick lookup.
  late final _i1.ColumnBool isPrimary;

  late final _i1.ColumnSerializable<Map<String, String>> metadata;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  _i3.ProjectTable get project {
    if (_project != null) return _project!;
    _project = _i1.createRelationTable(
      relationFieldName: 'project',
      field: ProjectParticipant.t.projectId,
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
    role,
    status,
    identityId,
    externalId,
    displayName,
    organizationName,
    email,
    phone,
    notes,
    isPrimary,
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

class ProjectParticipantInclude extends _i1.IncludeObject {
  ProjectParticipantInclude._({_i3.ProjectInclude? project}) {
    _project = project;
  }

  _i3.ProjectInclude? _project;

  @override
  Map<String, _i1.Include?> get includes => {'project': _project};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectParticipant.t;
}

class ProjectParticipantIncludeList extends _i1.IncludeList {
  ProjectParticipantIncludeList._({
    _i1.WhereExpressionBuilder<ProjectParticipantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProjectParticipant.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ProjectParticipant.t;
}

class ProjectParticipantRepository {
  const ProjectParticipantRepository._();

  final attachRow = const ProjectParticipantAttachRowRepository._();

  /// Returns a list of [ProjectParticipant]s matching the given query parameters.
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
  Future<List<ProjectParticipant>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectParticipantTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectParticipantInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProjectParticipant>(
      where: where?.call(ProjectParticipant.t),
      orderBy: orderBy?.call(ProjectParticipant.t),
      orderByList: orderByList?.call(ProjectParticipant.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProjectParticipant] matching the given query parameters.
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
  Future<ProjectParticipant?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectParticipantTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProjectParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProjectParticipantTable>? orderByList,
    _i1.Transaction? transaction,
    ProjectParticipantInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProjectParticipant>(
      where: where?.call(ProjectParticipant.t),
      orderBy: orderBy?.call(ProjectParticipant.t),
      orderByList: orderByList?.call(ProjectParticipant.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProjectParticipant] by its [id] or null if no such row exists.
  Future<ProjectParticipant?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    ProjectParticipantInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProjectParticipant>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProjectParticipant]s in the list and returns the inserted rows.
  ///
  /// The returned [ProjectParticipant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ProjectParticipant>> insert(
    _i1.DatabaseSession session,
    List<ProjectParticipant> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ProjectParticipant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ProjectParticipant] and returns the inserted row.
  ///
  /// The returned [ProjectParticipant] will have its `id` field set.
  Future<ProjectParticipant> insertRow(
    _i1.DatabaseSession session,
    ProjectParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProjectParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProjectParticipant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProjectParticipant>> update(
    _i1.DatabaseSession session,
    List<ProjectParticipant> rows, {
    _i1.ColumnSelections<ProjectParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProjectParticipant>(
      rows,
      columns: columns?.call(ProjectParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectParticipant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProjectParticipant> updateRow(
    _i1.DatabaseSession session,
    ProjectParticipant row, {
    _i1.ColumnSelections<ProjectParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProjectParticipant>(
      row,
      columns: columns?.call(ProjectParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProjectParticipant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProjectParticipant?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ProjectParticipantUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ProjectParticipant>(
      id,
      columnValues: columnValues(ProjectParticipant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProjectParticipant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ProjectParticipant>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProjectParticipantUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<ProjectParticipantTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProjectParticipantTable>? orderBy,
    _i1.OrderByListBuilder<ProjectParticipantTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ProjectParticipant>(
      columnValues: columnValues(ProjectParticipant.t.updateTable),
      where: where(ProjectParticipant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProjectParticipant.t),
      orderByList: orderByList?.call(ProjectParticipant.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ProjectParticipant]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProjectParticipant>> delete(
    _i1.DatabaseSession session,
    List<ProjectParticipant> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProjectParticipant>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProjectParticipant].
  Future<ProjectParticipant> deleteRow(
    _i1.DatabaseSession session,
    ProjectParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProjectParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProjectParticipant>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectParticipantTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProjectParticipant>(
      where: where(ProjectParticipant.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProjectParticipantTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProjectParticipant>(
      where: where?.call(ProjectParticipant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProjectParticipant] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProjectParticipantTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProjectParticipant>(
      where: where(ProjectParticipant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ProjectParticipantAttachRowRepository {
  const ProjectParticipantAttachRowRepository._();

  /// Creates a relation between the given [ProjectParticipant] and [Project]
  /// by setting the [ProjectParticipant]'s foreign key `projectId` to refer to the [Project].
  Future<void> project(
    _i1.DatabaseSession session,
    ProjectParticipant projectParticipant,
    _i3.Project project, {
    _i1.Transaction? transaction,
  }) async {
    if (projectParticipant.id == null) {
      throw ArgumentError.notNull('projectParticipant.id');
    }
    if (project.id == null) {
      throw ArgumentError.notNull('project.id');
    }

    var $projectParticipant = projectParticipant.copyWith(
      projectId: project.id,
    );
    await session.db.updateRow<ProjectParticipant>(
      $projectParticipant,
      columns: [ProjectParticipant.t.projectId],
      transaction: transaction,
    );
  }
}
