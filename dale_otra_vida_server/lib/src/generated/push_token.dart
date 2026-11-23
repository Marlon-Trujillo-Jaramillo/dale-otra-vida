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
import 'dart:async' as _ida;
import 'package:serverpod/serverpod.dart' as _is;

/// A device that accepted push notifications (Firebase Cloud Messaging).
abstract class PushToken
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PushToken._({
    this.id,
    required this.profileId,
    required this.token,
    required this.platform,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory PushToken({
    int? id,
    required int profileId,
    required String token,
    required String platform,
    DateTime? updatedAt,
  }) = _PushTokenImpl;

  factory PushToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return PushToken(
      id: jsonSerialization['id'] as int?,
      profileId: jsonSerialization['profileId'] as int,
      token: jsonSerialization['token'] as String,
      platform: jsonSerialization['platform'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = PushTokenTable();

  static const db = PushTokenRepository._();

  @override
  int? id;

  int profileId;

  /// The FCM registration token of the device.
  String token;

  /// "web", "android" or "ios".
  String platform;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PushToken]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PushToken copyWith({
    int? id,
    int? profileId,
    String? token,
    String? platform,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PushToken',
      if (id != null) 'id': id,
      'profileId': profileId,
      'token': token,
      'platform': platform,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PushToken',
      if (id != null) 'id': id,
      'profileId': profileId,
      'token': token,
      'platform': platform,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static PushTokenInclude include() {
    return PushTokenInclude._();
  }

  static PushTokenIncludeList includeList({
    _is.WhereExpressionBuilder<PushTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushTokenTable>? orderBy,
    _is.OrderByListBuilder<PushTokenTable>? orderByList,
    PushTokenInclude? include,
  }) {
    return PushTokenIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PushToken.t),
      orderByList: orderByList?.call(PushToken.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PushTokenImpl extends PushToken {
  _PushTokenImpl({
    int? id,
    required int profileId,
    required String token,
    required String platform,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         profileId: profileId,
         token: token,
         platform: platform,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PushToken]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PushToken copyWith({
    Object? id = _Undefined,
    int? profileId,
    String? token,
    String? platform,
    DateTime? updatedAt,
  }) {
    return PushToken(
      id: id is int? ? id : this.id,
      profileId: profileId ?? this.profileId,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PushTokenUpdateTable extends _is.UpdateTable<PushTokenTable> {
  PushTokenUpdateTable(super.table);

  _is.ColumnValue<int, int> profileId(int value) => _is.ColumnValue(
    table.profileId,
    value,
  );

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<String, String> platform(String value) => _is.ColumnValue(
    table.platform,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class PushTokenTable extends _is.Table<int?> {
  PushTokenTable({super.tableRelation}) : super(tableName: 'push_token') {
    updateTable = PushTokenUpdateTable(this);
    profileId = _is.ColumnInt(
      'profileId',
      this,
    );
    token = _is.ColumnString(
      'token',
      this,
    );
    platform = _is.ColumnString(
      'platform',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final PushTokenUpdateTable updateTable;

  late final _is.ColumnInt profileId;

  /// The FCM registration token of the device.
  late final _is.ColumnString token;

  /// "web", "android" or "ios".
  late final _is.ColumnString platform;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    profileId,
    token,
    platform,
    updatedAt,
  ];
}

class PushTokenInclude extends _is.IncludeObject {
  PushTokenInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PushToken.t;
}

class PushTokenIncludeList extends _is.IncludeList {
  PushTokenIncludeList._({
    _is.WhereExpressionBuilder<PushTokenTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PushToken.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PushToken.t;
}

class PushTokenRepository {
  const PushTokenRepository._();

  /// Returns a list of [PushToken]s matching the given query parameters.
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
  Future<List<PushToken>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushTokenTable>? orderBy,
    _is.OrderByListBuilder<PushTokenTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PushToken>(
      where: where?.call(PushToken.t),
      orderBy: orderBy?.call(PushToken.t),
      orderByList: orderByList?.call(PushToken.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [PushToken]s matching the given query parameters every time the
  /// source tables are modified.
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
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `PushToken.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<PushToken>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushTokenTable>? orderBy,
    _is.OrderByListBuilder<PushTokenTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<PushToken>(
      where: where?.call(PushToken.t),
      orderBy: orderBy?.call(PushToken.t),
      orderByList: orderByList?.call(PushToken.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [PushToken] matching the given query parameters.
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
  Future<PushToken?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushTokenTable>? where,
    int? offset,
    _is.OrderByBuilder<PushTokenTable>? orderBy,
    _is.OrderByListBuilder<PushTokenTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PushToken>(
      where: where?.call(PushToken.t),
      orderBy: orderBy?.call(PushToken.t),
      orderByList: orderByList?.call(PushToken.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PushToken] by its [id] or null if no such row exists.
  Future<PushToken?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PushToken>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PushToken]s in the list and returns the inserted rows.
  ///
  /// The returned [PushToken]s will have their `id` fields set.
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
  Future<List<PushToken>> insert(
    _is.DatabaseSession session,
    List<PushToken> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PushToken>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PushToken] and returns the inserted row.
  ///
  /// The returned [PushToken] will have its `id` field set.
  Future<PushToken> insertRow(
    _is.DatabaseSession session,
    PushToken row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PushToken>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PushToken]s in the list and returns the resulting rows.
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
  /// The returned [PushToken]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushToken>> upsert(
    _is.DatabaseSession session,
    List<PushToken> rows, {
    required _is.ColumnSelections<PushTokenTable> conflictColumns,
    _is.ColumnSelections<PushTokenTable>? updateColumns,
    _is.WhereExpressionBuilder<PushTokenTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PushToken>(
      rows,
      conflictColumns: conflictColumns(PushToken.t),
      updateColumns: updateColumns?.call(PushToken.t),
      updateWhere: updateWhere?.call(PushToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PushToken] and returns the resulting row.
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
  /// The returned [PushToken] will have its `id` field set.
  Future<PushToken?> upsertRow(
    _is.DatabaseSession session,
    PushToken row, {
    required _is.ColumnSelections<PushTokenTable> conflictColumns,
    _is.ColumnSelections<PushTokenTable>? updateColumns,
    _is.WhereExpressionBuilder<PushTokenTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PushToken>(
      row,
      conflictColumns: conflictColumns(PushToken.t),
      updateColumns: updateColumns?.call(PushToken.t),
      updateWhere: updateWhere?.call(PushToken.t),
      transaction: transaction,
    );
  }

  /// Updates all [PushToken]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushToken>> update(
    _is.DatabaseSession session,
    List<PushToken> rows, {
    _is.ColumnSelections<PushTokenTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PushToken>(
      rows,
      columns: columns?.call(PushToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PushToken]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PushToken> updateRow(
    _is.DatabaseSession session,
    PushToken row, {
    _is.ColumnSelections<PushTokenTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PushToken>(
      row,
      columns: columns?.call(PushToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PushToken] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PushToken?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PushTokenUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PushToken>(
      id,
      columnValues: columnValues(PushToken.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PushToken]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PushToken>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PushTokenUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PushTokenTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PushTokenTable>? orderBy,
    _is.OrderByListBuilder<PushTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PushToken>(
      columnValues: columnValues(PushToken.t.updateTable),
      where: where(PushToken.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PushToken.t),
      orderByList: orderByList?.call(PushToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PushToken]s in the list and returns the deleted rows.
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
  Future<List<PushToken>> delete(
    _is.DatabaseSession session,
    List<PushToken> rows, {
    _is.OrderByBuilder<PushTokenTable>? orderBy,
    _is.OrderByListBuilder<PushTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PushToken>(
      rows,
      orderBy: orderBy?.call(PushToken.t),
      orderByList: orderByList?.call(PushToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PushToken].
  Future<PushToken> deleteRow(
    _is.DatabaseSession session,
    PushToken row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PushToken>(
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
  Future<List<PushToken>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PushTokenTable> where,
    _is.OrderByBuilder<PushTokenTable>? orderBy,
    _is.OrderByListBuilder<PushTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PushToken>(
      where: where(PushToken.t),
      orderBy: orderBy?.call(PushToken.t),
      orderByList: orderByList?.call(PushToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PushTokenTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PushToken>(
      where: where?.call(PushToken.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PushToken] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PushTokenTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PushToken>(
      where: where(PushToken.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
