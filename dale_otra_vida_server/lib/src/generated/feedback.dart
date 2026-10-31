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

/// Opinion a tester sends from the app.
abstract class AppFeedback
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AppFeedback._({
    this.id,
    required this.profileId,
    this.rating,
    required this.message,
    this.screen,
    this.platform,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppFeedback({
    int? id,
    required int profileId,
    int? rating,
    required String message,
    String? screen,
    String? platform,
    DateTime? createdAt,
  }) = _AppFeedbackImpl;

  factory AppFeedback.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppFeedback(
      id: jsonSerialization['id'] as int?,
      profileId: jsonSerialization['profileId'] as int,
      rating: jsonSerialization['rating'] as int?,
      message: jsonSerialization['message'] as String,
      screen: jsonSerialization['screen'] as String?,
      platform: jsonSerialization['platform'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AppFeedbackTable();

  static const db = AppFeedbackRepository._();

  @override
  int? id;

  int profileId;

  /// 1 (very bad) to 5 (very good), optional.
  int? rating;

  String message;

  /// Where the tester was, e.g. "perfil" or "chat".
  String? screen;

  /// "web", "android" or "ios".
  String? platform;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AppFeedback]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AppFeedback copyWith({
    int? id,
    int? profileId,
    int? rating,
    String? message,
    String? screen,
    String? platform,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppFeedback',
      if (id != null) 'id': id,
      'profileId': profileId,
      if (rating != null) 'rating': rating,
      'message': message,
      if (screen != null) 'screen': screen,
      if (platform != null) 'platform': platform,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppFeedback',
      if (id != null) 'id': id,
      'profileId': profileId,
      if (rating != null) 'rating': rating,
      'message': message,
      if (screen != null) 'screen': screen,
      if (platform != null) 'platform': platform,
      'createdAt': createdAt.toJson(),
    };
  }

  static AppFeedbackInclude include() {
    return AppFeedbackInclude._();
  }

  static AppFeedbackIncludeList includeList({
    _is.WhereExpressionBuilder<AppFeedbackTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppFeedbackTable>? orderBy,
    _is.OrderByListBuilder<AppFeedbackTable>? orderByList,
    AppFeedbackInclude? include,
  }) {
    return AppFeedbackIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppFeedback.t),
      orderByList: orderByList?.call(AppFeedback.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppFeedbackImpl extends AppFeedback {
  _AppFeedbackImpl({
    int? id,
    required int profileId,
    int? rating,
    required String message,
    String? screen,
    String? platform,
    DateTime? createdAt,
  }) : super._(
         id: id,
         profileId: profileId,
         rating: rating,
         message: message,
         screen: screen,
         platform: platform,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AppFeedback]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AppFeedback copyWith({
    Object? id = _Undefined,
    int? profileId,
    Object? rating = _Undefined,
    String? message,
    Object? screen = _Undefined,
    Object? platform = _Undefined,
    DateTime? createdAt,
  }) {
    return AppFeedback(
      id: id is int? ? id : this.id,
      profileId: profileId ?? this.profileId,
      rating: rating is int? ? rating : this.rating,
      message: message ?? this.message,
      screen: screen is String? ? screen : this.screen,
      platform: platform is String? ? platform : this.platform,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AppFeedbackUpdateTable extends _is.UpdateTable<AppFeedbackTable> {
  AppFeedbackUpdateTable(super.table);

  _is.ColumnValue<int, int> profileId(int value) => _is.ColumnValue(
    table.profileId,
    value,
  );

  _is.ColumnValue<int, int> rating(int? value) => _is.ColumnValue(
    table.rating,
    value,
  );

  _is.ColumnValue<String, String> message(String value) => _is.ColumnValue(
    table.message,
    value,
  );

  _is.ColumnValue<String, String> screen(String? value) => _is.ColumnValue(
    table.screen,
    value,
  );

  _is.ColumnValue<String, String> platform(String? value) => _is.ColumnValue(
    table.platform,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AppFeedbackTable extends _is.Table<int?> {
  AppFeedbackTable({super.tableRelation}) : super(tableName: 'app_feedback') {
    updateTable = AppFeedbackUpdateTable(this);
    profileId = _is.ColumnInt(
      'profileId',
      this,
    );
    rating = _is.ColumnInt(
      'rating',
      this,
    );
    message = _is.ColumnString(
      'message',
      this,
    );
    screen = _is.ColumnString(
      'screen',
      this,
    );
    platform = _is.ColumnString(
      'platform',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AppFeedbackUpdateTable updateTable;

  late final _is.ColumnInt profileId;

  /// 1 (very bad) to 5 (very good), optional.
  late final _is.ColumnInt rating;

  late final _is.ColumnString message;

  /// Where the tester was, e.g. "perfil" or "chat".
  late final _is.ColumnString screen;

  /// "web", "android" or "ios".
  late final _is.ColumnString platform;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    profileId,
    rating,
    message,
    screen,
    platform,
    createdAt,
  ];
}

class AppFeedbackInclude extends _is.IncludeObject {
  AppFeedbackInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AppFeedback.t;
}

class AppFeedbackIncludeList extends _is.IncludeList {
  AppFeedbackIncludeList._({
    _is.WhereExpressionBuilder<AppFeedbackTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AppFeedback.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AppFeedback.t;
}

class AppFeedbackRepository {
  const AppFeedbackRepository._();

  /// Returns a list of [AppFeedback]s matching the given query parameters.
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
  Future<List<AppFeedback>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppFeedbackTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppFeedbackTable>? orderBy,
    _is.OrderByListBuilder<AppFeedbackTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AppFeedback>(
      where: where?.call(AppFeedback.t),
      orderBy: orderBy?.call(AppFeedback.t),
      orderByList: orderByList?.call(AppFeedback.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AppFeedback] matching the given query parameters.
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
  Future<AppFeedback?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppFeedbackTable>? where,
    int? offset,
    _is.OrderByBuilder<AppFeedbackTable>? orderBy,
    _is.OrderByListBuilder<AppFeedbackTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AppFeedback>(
      where: where?.call(AppFeedback.t),
      orderBy: orderBy?.call(AppFeedback.t),
      orderByList: orderByList?.call(AppFeedback.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AppFeedback] by its [id] or null if no such row exists.
  Future<AppFeedback?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AppFeedback>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AppFeedback]s in the list and returns the inserted rows.
  ///
  /// The returned [AppFeedback]s will have their `id` fields set.
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
  Future<List<AppFeedback>> insert(
    _is.DatabaseSession session,
    List<AppFeedback> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AppFeedback>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AppFeedback] and returns the inserted row.
  ///
  /// The returned [AppFeedback] will have its `id` field set.
  Future<AppFeedback> insertRow(
    _is.DatabaseSession session,
    AppFeedback row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AppFeedback>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AppFeedback]s in the list and returns the resulting rows.
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
  /// The returned [AppFeedback]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppFeedback>> upsert(
    _is.DatabaseSession session,
    List<AppFeedback> rows, {
    required _is.ColumnSelections<AppFeedbackTable> conflictColumns,
    _is.ColumnSelections<AppFeedbackTable>? updateColumns,
    _is.WhereExpressionBuilder<AppFeedbackTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AppFeedback>(
      rows,
      conflictColumns: conflictColumns(AppFeedback.t),
      updateColumns: updateColumns?.call(AppFeedback.t),
      updateWhere: updateWhere?.call(AppFeedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AppFeedback] and returns the resulting row.
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
  /// The returned [AppFeedback] will have its `id` field set.
  Future<AppFeedback?> upsertRow(
    _is.DatabaseSession session,
    AppFeedback row, {
    required _is.ColumnSelections<AppFeedbackTable> conflictColumns,
    _is.ColumnSelections<AppFeedbackTable>? updateColumns,
    _is.WhereExpressionBuilder<AppFeedbackTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AppFeedback>(
      row,
      conflictColumns: conflictColumns(AppFeedback.t),
      updateColumns: updateColumns?.call(AppFeedback.t),
      updateWhere: updateWhere?.call(AppFeedback.t),
      transaction: transaction,
    );
  }

  /// Updates all [AppFeedback]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppFeedback>> update(
    _is.DatabaseSession session,
    List<AppFeedback> rows, {
    _is.ColumnSelections<AppFeedbackTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AppFeedback>(
      rows,
      columns: columns?.call(AppFeedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AppFeedback]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AppFeedback> updateRow(
    _is.DatabaseSession session,
    AppFeedback row, {
    _is.ColumnSelections<AppFeedbackTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AppFeedback>(
      row,
      columns: columns?.call(AppFeedback.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AppFeedback] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AppFeedback?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AppFeedbackUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AppFeedback>(
      id,
      columnValues: columnValues(AppFeedback.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AppFeedback]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AppFeedback>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AppFeedbackUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AppFeedbackTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AppFeedbackTable>? orderBy,
    _is.OrderByListBuilder<AppFeedbackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AppFeedback>(
      columnValues: columnValues(AppFeedback.t.updateTable),
      where: where(AppFeedback.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AppFeedback.t),
      orderByList: orderByList?.call(AppFeedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AppFeedback]s in the list and returns the deleted rows.
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
  Future<List<AppFeedback>> delete(
    _is.DatabaseSession session,
    List<AppFeedback> rows, {
    _is.OrderByBuilder<AppFeedbackTable>? orderBy,
    _is.OrderByListBuilder<AppFeedbackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AppFeedback>(
      rows,
      orderBy: orderBy?.call(AppFeedback.t),
      orderByList: orderByList?.call(AppFeedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AppFeedback].
  Future<AppFeedback> deleteRow(
    _is.DatabaseSession session,
    AppFeedback row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AppFeedback>(
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
  Future<List<AppFeedback>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AppFeedbackTable> where,
    _is.OrderByBuilder<AppFeedbackTable>? orderBy,
    _is.OrderByListBuilder<AppFeedbackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AppFeedback>(
      where: where(AppFeedback.t),
      orderBy: orderBy?.call(AppFeedback.t),
      orderByList: orderByList?.call(AppFeedback.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AppFeedbackTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AppFeedback>(
      where: where?.call(AppFeedback.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AppFeedback] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AppFeedbackTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AppFeedback>(
      where: where(AppFeedback.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
