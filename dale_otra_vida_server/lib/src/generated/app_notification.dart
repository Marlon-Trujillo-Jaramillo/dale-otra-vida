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
import 'package:serverpod/serverpod.dart' as _is;
import 'notification_kind.dart' as _ipnxo26v;

abstract class AppNotification
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AppNotification._({
    this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    this.refId,
    this.readAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification({
    int? id,
    required int userId,
    required _ipnxo26v.NotificationKind kind,
    required String title,
    required String body,
    int? refId,
    DateTime? readAt,
    DateTime? createdAt,
  }) = _AppNotificationImpl;

  factory AppNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppNotification(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      kind: _ipnxo26v.NotificationKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      refId: jsonSerialization['refId'] as int?,
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AppNotificationTable();

  static const db = AppNotificationRepository._();

  @override
  int? id;

  int userId;

  _ipnxo26v.NotificationKind kind;

  String title;

  String body;

  /// Id of the related listing, request or conversation, depending on [kind].
  int? refId;

  DateTime? readAt;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AppNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AppNotification copyWith({
    int? id,
    int? userId,
    _ipnxo26v.NotificationKind? kind,
    String? title,
    String? body,
    int? refId,
    DateTime? readAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppNotification',
      if (id != null) 'id': id,
      'userId': userId,
      'kind': kind.toJson(),
      'title': title,
      'body': body,
      if (refId != null) 'refId': refId,
      if (readAt != null) 'readAt': readAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppNotification',
      if (id != null) 'id': id,
      'userId': userId,
      'kind': kind.toJson(),
      'title': title,
      'body': body,
      if (refId != null) 'refId': refId,
      if (readAt != null) 'readAt': readAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static AppNotificationInclude include() {
    return AppNotificationInclude._();
  }

  static AppNotificationIncludeList includeList({
    _is.WhereExpressionBuilder<AppNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppNotificationTable>? orderBy,
    _is.OrderByListBuilder<AppNotificationTable>? orderByList,
    AppNotificationInclude? include,
  }) {
    return AppNotificationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppNotification.t),
      orderByList: orderByList?.call(AppNotification.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppNotificationImpl extends AppNotification {
  _AppNotificationImpl({
    int? id,
    required int userId,
    required _ipnxo26v.NotificationKind kind,
    required String title,
    required String body,
    int? refId,
    DateTime? readAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         kind: kind,
         title: title,
         body: body,
         refId: refId,
         readAt: readAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AppNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AppNotification copyWith({
    Object? id = _Undefined,
    int? userId,
    _ipnxo26v.NotificationKind? kind,
    String? title,
    String? body,
    Object? refId = _Undefined,
    Object? readAt = _Undefined,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      refId: refId is int? ? refId : this.refId,
      readAt: readAt is DateTime? ? readAt : this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AppNotificationUpdateTable extends _is.UpdateTable<AppNotificationTable> {
  AppNotificationUpdateTable(super.table);

  _is.ColumnValue<int, int> userId(int value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<_ipnxo26v.NotificationKind, _ipnxo26v.NotificationKind> kind(
    _ipnxo26v.NotificationKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> body(String value) => _is.ColumnValue(
    table.body,
    value,
  );

  _is.ColumnValue<int, int> refId(int? value) => _is.ColumnValue(
    table.refId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> readAt(DateTime? value) =>
      _is.ColumnValue(
        table.readAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AppNotificationTable extends _is.Table<int?> {
  AppNotificationTable({super.tableRelation})
    : super(tableName: 'app_notification') {
    updateTable = AppNotificationUpdateTable(this);
    userId = _is.ColumnInt(
      'userId',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    body = _is.ColumnString(
      'body',
      this,
    );
    refId = _is.ColumnInt(
      'refId',
      this,
    );
    readAt = _is.ColumnDateTime(
      'readAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AppNotificationUpdateTable updateTable;

  late final _is.ColumnInt userId;

  late final _is.ColumnEnum<_ipnxo26v.NotificationKind> kind;

  late final _is.ColumnString title;

  late final _is.ColumnString body;

  /// Id of the related listing, request or conversation, depending on [kind].
  late final _is.ColumnInt refId;

  late final _is.ColumnDateTime readAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    kind,
    title,
    body,
    refId,
    readAt,
    createdAt,
  ];
}

class AppNotificationInclude extends _is.IncludeObject {
  AppNotificationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AppNotification.t;
}

class AppNotificationIncludeList extends _is.IncludeList {
  AppNotificationIncludeList._({
    _is.WhereExpressionBuilder<AppNotificationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AppNotification.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AppNotification.t;
}

class AppNotificationRepository {
  const AppNotificationRepository._();

  /// Returns a list of [AppNotification]s matching the given query parameters.
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
  Future<List<AppNotification>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppNotificationTable>? orderBy,
    _is.OrderByListBuilder<AppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AppNotification>(
      where: where?.call(AppNotification.t),
      orderBy: orderBy?.call(AppNotification.t),
      orderByList: orderByList?.call(AppNotification.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AppNotification] matching the given query parameters.
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
  Future<AppNotification?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppNotificationTable>? where,
    int? offset,
    _is.OrderByBuilder<AppNotificationTable>? orderBy,
    _is.OrderByListBuilder<AppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AppNotification>(
      where: where?.call(AppNotification.t),
      orderBy: orderBy?.call(AppNotification.t),
      orderByList: orderByList?.call(AppNotification.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AppNotification] by its [id] or null if no such row exists.
  Future<AppNotification?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AppNotification>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AppNotification]s in the list and returns the inserted rows.
  ///
  /// The returned [AppNotification]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppNotification>> insert(
    _is.DatabaseSession session,
    List<AppNotification> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AppNotification>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AppNotification] and returns the inserted row.
  ///
  /// The returned [AppNotification] will have its `id` field set.
  Future<AppNotification> insertRow(
    _is.DatabaseSession session,
    AppNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AppNotification>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AppNotification]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [AppNotification]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppNotification>> upsert(
    _is.DatabaseSession session,
    List<AppNotification> rows, {
    required _is.ColumnSelections<AppNotificationTable> conflictColumns,
    _is.ColumnSelections<AppNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<AppNotificationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AppNotification>(
      rows,
      conflictColumns: conflictColumns(AppNotification.t),
      updateColumns: updateColumns?.call(AppNotification.t),
      updateWhere: updateWhere?.call(AppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AppNotification] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [AppNotification] will have its `id` field set.
  Future<AppNotification?> upsertRow(
    _is.DatabaseSession session,
    AppNotification row, {
    required _is.ColumnSelections<AppNotificationTable> conflictColumns,
    _is.ColumnSelections<AppNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<AppNotificationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AppNotification>(
      row,
      conflictColumns: conflictColumns(AppNotification.t),
      updateColumns: updateColumns?.call(AppNotification.t),
      updateWhere: updateWhere?.call(AppNotification.t),
      transaction: transaction,
    );
  }

  /// Updates all [AppNotification]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppNotification>> update(
    _is.DatabaseSession session,
    List<AppNotification> rows, {
    _is.ColumnSelections<AppNotificationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AppNotification>(
      rows,
      columns: columns?.call(AppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AppNotification]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AppNotification> updateRow(
    _is.DatabaseSession session,
    AppNotification row, {
    _is.ColumnSelections<AppNotificationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AppNotification>(
      row,
      columns: columns?.call(AppNotification.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppNotification] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AppNotification?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AppNotificationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AppNotification>(
      id,
      columnValues: columnValues(AppNotification.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AppNotification]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppNotification>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AppNotificationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AppNotificationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppNotificationTable>? orderBy,
    _is.OrderByListBuilder<AppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AppNotification>(
      columnValues: columnValues(AppNotification.t.updateTable),
      where: where(AppNotification.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppNotification.t),
      orderByList: orderByList?.call(AppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AppNotification]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppNotification>> delete(
    _is.DatabaseSession session,
    List<AppNotification> rows, {
    _is.OrderByBuilder<AppNotificationTable>? orderBy,
    _is.OrderByListBuilder<AppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AppNotification>(
      rows,
      orderBy: orderBy?.call(AppNotification.t),
      orderByList: orderByList?.call(AppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AppNotification].
  Future<AppNotification> deleteRow(
    _is.DatabaseSession session,
    AppNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AppNotification>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppNotification>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AppNotificationTable> where,
    _is.OrderByBuilder<AppNotificationTable>? orderBy,
    _is.OrderByListBuilder<AppNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AppNotification>(
      where: where(AppNotification.t),
      orderBy: orderBy?.call(AppNotification.t),
      orderByList: orderByList?.call(AppNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppNotificationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AppNotification>(
      where: where?.call(AppNotification.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AppNotification] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AppNotificationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AppNotification>(
      where: where(AppNotification.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
