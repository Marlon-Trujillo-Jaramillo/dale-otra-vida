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
import 'request_status.dart' as _iq8zsng0;

/// A "Lo quiero" request from a user on a listing.
abstract class ListingRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ListingRequest._({
    this.id,
    required this.listingId,
    required this.requesterId,
    this.message,
    _iq8zsng0.RequestStatus? status,
    DateTime? createdAt,
  }) : status = status ?? _iq8zsng0.RequestStatus.pending,
       createdAt = createdAt ?? DateTime.now();

  factory ListingRequest({
    int? id,
    required int listingId,
    required int requesterId,
    String? message,
    _iq8zsng0.RequestStatus? status,
    DateTime? createdAt,
  }) = _ListingRequestImpl;

  factory ListingRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ListingRequest(
      id: jsonSerialization['id'] as int?,
      listingId: jsonSerialization['listingId'] as int,
      requesterId: jsonSerialization['requesterId'] as int,
      message: jsonSerialization['message'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _iq8zsng0.RequestStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ListingRequestTable();

  static const db = ListingRequestRepository._();

  @override
  int? id;

  int listingId;

  int requesterId;

  String? message;

  _iq8zsng0.RequestStatus status;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ListingRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ListingRequest copyWith({
    int? id,
    int? listingId,
    int? requesterId,
    String? message,
    _iq8zsng0.RequestStatus? status,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListingRequest',
      if (id != null) 'id': id,
      'listingId': listingId,
      'requesterId': requesterId,
      if (message != null) 'message': message,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ListingRequest',
      if (id != null) 'id': id,
      'listingId': listingId,
      'requesterId': requesterId,
      if (message != null) 'message': message,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static ListingRequestInclude include() {
    return ListingRequestInclude._();
  }

  static ListingRequestIncludeList includeList({
    _is.WhereExpressionBuilder<ListingRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ListingRequestTable>? orderBy,
    _is.OrderByListBuilder<ListingRequestTable>? orderByList,
    ListingRequestInclude? include,
  }) {
    return ListingRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ListingRequest.t),
      orderByList: orderByList?.call(ListingRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListingRequestImpl extends ListingRequest {
  _ListingRequestImpl({
    int? id,
    required int listingId,
    required int requesterId,
    String? message,
    _iq8zsng0.RequestStatus? status,
    DateTime? createdAt,
  }) : super._(
         id: id,
         listingId: listingId,
         requesterId: requesterId,
         message: message,
         status: status,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ListingRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ListingRequest copyWith({
    Object? id = _Undefined,
    int? listingId,
    int? requesterId,
    Object? message = _Undefined,
    _iq8zsng0.RequestStatus? status,
    DateTime? createdAt,
  }) {
    return ListingRequest(
      id: id is int? ? id : this.id,
      listingId: listingId ?? this.listingId,
      requesterId: requesterId ?? this.requesterId,
      message: message is String? ? message : this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ListingRequestUpdateTable extends _is.UpdateTable<ListingRequestTable> {
  ListingRequestUpdateTable(super.table);

  _is.ColumnValue<int, int> listingId(int value) => _is.ColumnValue(
    table.listingId,
    value,
  );

  _is.ColumnValue<int, int> requesterId(int value) => _is.ColumnValue(
    table.requesterId,
    value,
  );

  _is.ColumnValue<String, String> message(String? value) => _is.ColumnValue(
    table.message,
    value,
  );

  _is.ColumnValue<_iq8zsng0.RequestStatus, _iq8zsng0.RequestStatus> status(
    _iq8zsng0.RequestStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ListingRequestTable extends _is.Table<int?> {
  ListingRequestTable({super.tableRelation})
    : super(tableName: 'listing_request') {
    updateTable = ListingRequestUpdateTable(this);
    listingId = _is.ColumnInt(
      'listingId',
      this,
    );
    requesterId = _is.ColumnInt(
      'requesterId',
      this,
    );
    message = _is.ColumnString(
      'message',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ListingRequestUpdateTable updateTable;

  late final _is.ColumnInt listingId;

  late final _is.ColumnInt requesterId;

  late final _is.ColumnString message;

  late final _is.ColumnEnum<_iq8zsng0.RequestStatus> status;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    listingId,
    requesterId,
    message,
    status,
    createdAt,
  ];
}

class ListingRequestInclude extends _is.IncludeObject {
  ListingRequestInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ListingRequest.t;
}

class ListingRequestIncludeList extends _is.IncludeList {
  ListingRequestIncludeList._({
    _is.WhereExpressionBuilder<ListingRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ListingRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ListingRequest.t;
}

class ListingRequestRepository {
  const ListingRequestRepository._();

  /// Returns a list of [ListingRequest]s matching the given query parameters.
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
  Future<List<ListingRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ListingRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ListingRequestTable>? orderBy,
    _is.OrderByListBuilder<ListingRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ListingRequest>(
      where: where?.call(ListingRequest.t),
      orderBy: orderBy?.call(ListingRequest.t),
      orderByList: orderByList?.call(ListingRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ListingRequest] matching the given query parameters.
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
  Future<ListingRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ListingRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<ListingRequestTable>? orderBy,
    _is.OrderByListBuilder<ListingRequestTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ListingRequest>(
      where: where?.call(ListingRequest.t),
      orderBy: orderBy?.call(ListingRequest.t),
      orderByList: orderByList?.call(ListingRequest.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ListingRequest] by its [id] or null if no such row exists.
  Future<ListingRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ListingRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ListingRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [ListingRequest]s will have their `id` fields set.
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
  Future<List<ListingRequest>> insert(
    _is.DatabaseSession session,
    List<ListingRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ListingRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ListingRequest] and returns the inserted row.
  ///
  /// The returned [ListingRequest] will have its `id` field set.
  Future<ListingRequest> insertRow(
    _is.DatabaseSession session,
    ListingRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ListingRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ListingRequest]s in the list and returns the resulting rows.
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
  /// The returned [ListingRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ListingRequest>> upsert(
    _is.DatabaseSession session,
    List<ListingRequest> rows, {
    required _is.ColumnSelections<ListingRequestTable> conflictColumns,
    _is.ColumnSelections<ListingRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ListingRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ListingRequest>(
      rows,
      conflictColumns: conflictColumns(ListingRequest.t),
      updateColumns: updateColumns?.call(ListingRequest.t),
      updateWhere: updateWhere?.call(ListingRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ListingRequest] and returns the resulting row.
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
  /// The returned [ListingRequest] will have its `id` field set.
  Future<ListingRequest?> upsertRow(
    _is.DatabaseSession session,
    ListingRequest row, {
    required _is.ColumnSelections<ListingRequestTable> conflictColumns,
    _is.ColumnSelections<ListingRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ListingRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ListingRequest>(
      row,
      conflictColumns: conflictColumns(ListingRequest.t),
      updateColumns: updateColumns?.call(ListingRequest.t),
      updateWhere: updateWhere?.call(ListingRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [ListingRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ListingRequest>> update(
    _is.DatabaseSession session,
    List<ListingRequest> rows, {
    _is.ColumnSelections<ListingRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ListingRequest>(
      rows,
      columns: columns?.call(ListingRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ListingRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ListingRequest> updateRow(
    _is.DatabaseSession session,
    ListingRequest row, {
    _is.ColumnSelections<ListingRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ListingRequest>(
      row,
      columns: columns?.call(ListingRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ListingRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ListingRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ListingRequestUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ListingRequest>(
      id,
      columnValues: columnValues(ListingRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ListingRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ListingRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ListingRequestUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ListingRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ListingRequestTable>? orderBy,
    _is.OrderByListBuilder<ListingRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ListingRequest>(
      columnValues: columnValues(ListingRequest.t.updateTable),
      where: where(ListingRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ListingRequest.t),
      orderByList: orderByList?.call(ListingRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ListingRequest]s in the list and returns the deleted rows.
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
  Future<List<ListingRequest>> delete(
    _is.DatabaseSession session,
    List<ListingRequest> rows, {
    _is.OrderByBuilder<ListingRequestTable>? orderBy,
    _is.OrderByListBuilder<ListingRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ListingRequest>(
      rows,
      orderBy: orderBy?.call(ListingRequest.t),
      orderByList: orderByList?.call(ListingRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ListingRequest].
  Future<ListingRequest> deleteRow(
    _is.DatabaseSession session,
    ListingRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ListingRequest>(
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
  Future<List<ListingRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ListingRequestTable> where,
    _is.OrderByBuilder<ListingRequestTable>? orderBy,
    _is.OrderByListBuilder<ListingRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ListingRequest>(
      where: where(ListingRequest.t),
      orderBy: orderBy?.call(ListingRequest.t),
      orderByList: orderByList?.call(ListingRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ListingRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ListingRequest>(
      where: where?.call(ListingRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ListingRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ListingRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ListingRequest>(
      where: where(ListingRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
