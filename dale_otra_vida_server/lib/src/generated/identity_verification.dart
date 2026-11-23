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
import 'identity_status.dart' as _i3lgiogf;

/// A member's identity check for loans: a photo of the cédula and a selfie
/// holding it, reviewed by hand by an administrator. Sensitive data (Ley 1581
/// de 2015): photos live in private storage and are deleted right after the
/// review; only an administrator ever reads this row.
abstract class IdentityVerification
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  IdentityVerification._({
    this.id,
    required this.profileId,
    _i3lgiogf.IdentityStatus? status,
    required this.documentNumber,
    this.frontPath,
    this.selfiePath,
    required this.consentAt,
    DateTime? submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  }) : status = status ?? _i3lgiogf.IdentityStatus.pending,
       submittedAt = submittedAt ?? DateTime.now();

  factory IdentityVerification({
    int? id,
    required int profileId,
    _i3lgiogf.IdentityStatus? status,
    required String documentNumber,
    String? frontPath,
    String? selfiePath,
    required DateTime consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    int? reviewedBy,
    String? rejectionReason,
  }) = _IdentityVerificationImpl;

  factory IdentityVerification.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return IdentityVerification(
      id: jsonSerialization['id'] as int?,
      profileId: jsonSerialization['profileId'] as int,
      status: jsonSerialization['status'] == null
          ? null
          : _i3lgiogf.IdentityStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      documentNumber: jsonSerialization['documentNumber'] as String,
      frontPath: jsonSerialization['frontPath'] as String?,
      selfiePath: jsonSerialization['selfiePath'] as String?,
      consentAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['consentAt'],
      ),
      submittedAt: jsonSerialization['submittedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedAt'],
            ),
      reviewedAt: jsonSerialization['reviewedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['reviewedAt']),
      reviewedBy: jsonSerialization['reviewedBy'] as int?,
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
    );
  }

  static final t = IdentityVerificationTable();

  static const db = IdentityVerificationRepository._();

  @override
  int? id;

  int profileId;

  _i3lgiogf.IdentityStatus status;

  /// Cédula number, digits only. Kept for a police report after a theft.
  String documentNumber;

  /// Private storage paths; cleared when the photos are deleted.
  String? frontPath;

  String? selfiePath;

  /// When the member gave express consent to this processing.
  DateTime consentAt;

  DateTime submittedAt;

  DateTime? reviewedAt;

  /// Profile id of the administrator who reviewed it.
  int? reviewedBy;

  String? rejectionReason;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [IdentityVerification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IdentityVerification copyWith({
    int? id,
    int? profileId,
    _i3lgiogf.IdentityStatus? status,
    String? documentNumber,
    String? frontPath,
    String? selfiePath,
    DateTime? consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt = const _is.$UndefinedDateTime(),
    int? reviewedBy,
    String? rejectionReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IdentityVerification',
      if (id != null) 'id': id,
      'profileId': profileId,
      'status': status.toJson(),
      'documentNumber': documentNumber,
      if (frontPath != null) 'frontPath': frontPath,
      if (selfiePath != null) 'selfiePath': selfiePath,
      'consentAt': consentAt.toJson(),
      'submittedAt': submittedAt.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IdentityVerification',
      if (id != null) 'id': id,
      'profileId': profileId,
      'status': status.toJson(),
      'documentNumber': documentNumber,
      if (frontPath != null) 'frontPath': frontPath,
      if (selfiePath != null) 'selfiePath': selfiePath,
      'consentAt': consentAt.toJson(),
      'submittedAt': submittedAt.toJson(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt?.toJson(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  static IdentityVerificationInclude include() {
    return IdentityVerificationInclude._();
  }

  static IdentityVerificationIncludeList includeList({
    _is.WhereExpressionBuilder<IdentityVerificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IdentityVerificationTable>? orderBy,
    _is.OrderByListBuilder<IdentityVerificationTable>? orderByList,
    IdentityVerificationInclude? include,
  }) {
    return IdentityVerificationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IdentityVerification.t),
      orderByList: orderByList?.call(IdentityVerification.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdentityVerificationImpl extends IdentityVerification {
  _IdentityVerificationImpl({
    int? id,
    required int profileId,
    _i3lgiogf.IdentityStatus? status,
    required String documentNumber,
    String? frontPath,
    String? selfiePath,
    required DateTime consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    int? reviewedBy,
    String? rejectionReason,
  }) : super._(
         id: id,
         profileId: profileId,
         status: status,
         documentNumber: documentNumber,
         frontPath: frontPath,
         selfiePath: selfiePath,
         consentAt: consentAt,
         submittedAt: submittedAt,
         reviewedAt: reviewedAt,
         reviewedBy: reviewedBy,
         rejectionReason: rejectionReason,
       );

  /// Returns a shallow copy of this [IdentityVerification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IdentityVerification copyWith({
    Object? id = _Undefined,
    int? profileId,
    _i3lgiogf.IdentityStatus? status,
    String? documentNumber,
    Object? frontPath = _Undefined,
    Object? selfiePath = _Undefined,
    DateTime? consentAt,
    DateTime? submittedAt,
    DateTime? reviewedAt = const _is.$UndefinedDateTime(),
    Object? reviewedBy = _Undefined,
    Object? rejectionReason = _Undefined,
  }) {
    return IdentityVerification(
      id: id is int? ? id : this.id,
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      documentNumber: documentNumber ?? this.documentNumber,
      frontPath: frontPath is String? ? frontPath : this.frontPath,
      selfiePath: selfiePath is String? ? selfiePath : this.selfiePath,
      consentAt: consentAt ?? this.consentAt,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt is _is.UndefinedSentinel
          ? this.reviewedAt
          : reviewedAt,
      reviewedBy: reviewedBy is int? ? reviewedBy : this.reviewedBy,
      rejectionReason: rejectionReason is String?
          ? rejectionReason
          : this.rejectionReason,
    );
  }
}

class IdentityVerificationUpdateTable
    extends _is.UpdateTable<IdentityVerificationTable> {
  IdentityVerificationUpdateTable(super.table);

  _is.ColumnValue<int, int> profileId(int value) => _is.ColumnValue(
    table.profileId,
    value,
  );

  _is.ColumnValue<_i3lgiogf.IdentityStatus, _i3lgiogf.IdentityStatus> status(
    _i3lgiogf.IdentityStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> documentNumber(String value) =>
      _is.ColumnValue(
        table.documentNumber,
        value,
      );

  _is.ColumnValue<String, String> frontPath(String? value) => _is.ColumnValue(
    table.frontPath,
    value,
  );

  _is.ColumnValue<String, String> selfiePath(String? value) => _is.ColumnValue(
    table.selfiePath,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> consentAt(DateTime value) =>
      _is.ColumnValue(
        table.consentAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> submittedAt(DateTime value) =>
      _is.ColumnValue(
        table.submittedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> reviewedAt(DateTime? value) =>
      _is.ColumnValue(
        table.reviewedAt,
        value,
      );

  _is.ColumnValue<int, int> reviewedBy(int? value) => _is.ColumnValue(
    table.reviewedBy,
    value,
  );

  _is.ColumnValue<String, String> rejectionReason(String? value) =>
      _is.ColumnValue(
        table.rejectionReason,
        value,
      );
}

class IdentityVerificationTable extends _is.Table<int?> {
  IdentityVerificationTable({super.tableRelation})
    : super(tableName: 'identity_verification') {
    updateTable = IdentityVerificationUpdateTable(this);
    profileId = _is.ColumnInt(
      'profileId',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    documentNumber = _is.ColumnString(
      'documentNumber',
      this,
    );
    frontPath = _is.ColumnString(
      'frontPath',
      this,
    );
    selfiePath = _is.ColumnString(
      'selfiePath',
      this,
    );
    consentAt = _is.ColumnDateTime(
      'consentAt',
      this,
    );
    submittedAt = _is.ColumnDateTime(
      'submittedAt',
      this,
      hasDefault: true,
    );
    reviewedAt = _is.ColumnDateTime(
      'reviewedAt',
      this,
    );
    reviewedBy = _is.ColumnInt(
      'reviewedBy',
      this,
    );
    rejectionReason = _is.ColumnString(
      'rejectionReason',
      this,
    );
  }

  late final IdentityVerificationUpdateTable updateTable;

  late final _is.ColumnInt profileId;

  late final _is.ColumnEnum<_i3lgiogf.IdentityStatus> status;

  /// Cédula number, digits only. Kept for a police report after a theft.
  late final _is.ColumnString documentNumber;

  /// Private storage paths; cleared when the photos are deleted.
  late final _is.ColumnString frontPath;

  late final _is.ColumnString selfiePath;

  /// When the member gave express consent to this processing.
  late final _is.ColumnDateTime consentAt;

  late final _is.ColumnDateTime submittedAt;

  late final _is.ColumnDateTime reviewedAt;

  /// Profile id of the administrator who reviewed it.
  late final _is.ColumnInt reviewedBy;

  late final _is.ColumnString rejectionReason;

  @override
  List<_is.Column> get columns => [
    id,
    profileId,
    status,
    documentNumber,
    frontPath,
    selfiePath,
    consentAt,
    submittedAt,
    reviewedAt,
    reviewedBy,
    rejectionReason,
  ];
}

class IdentityVerificationInclude extends _is.IncludeObject {
  IdentityVerificationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => IdentityVerification.t;
}

class IdentityVerificationIncludeList extends _is.IncludeList {
  IdentityVerificationIncludeList._({
    _is.WhereExpressionBuilder<IdentityVerificationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IdentityVerification.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => IdentityVerification.t;
}

class IdentityVerificationRepository {
  const IdentityVerificationRepository._();

  /// Returns a list of [IdentityVerification]s matching the given query parameters.
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
  Future<List<IdentityVerification>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IdentityVerificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IdentityVerificationTable>? orderBy,
    _is.OrderByListBuilder<IdentityVerificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IdentityVerification>(
      where: where?.call(IdentityVerification.t),
      orderBy: orderBy?.call(IdentityVerification.t),
      orderByList: orderByList?.call(IdentityVerification.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [IdentityVerification]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `IdentityVerification.t`.
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
  _ida.Stream<List<IdentityVerification>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IdentityVerificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IdentityVerificationTable>? orderBy,
    _is.OrderByListBuilder<IdentityVerificationTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<IdentityVerification>(
      where: where?.call(IdentityVerification.t),
      orderBy: orderBy?.call(IdentityVerification.t),
      orderByList: orderByList?.call(IdentityVerification.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [IdentityVerification] matching the given query parameters.
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
  Future<IdentityVerification?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IdentityVerificationTable>? where,
    int? offset,
    _is.OrderByBuilder<IdentityVerificationTable>? orderBy,
    _is.OrderByListBuilder<IdentityVerificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IdentityVerification>(
      where: where?.call(IdentityVerification.t),
      orderBy: orderBy?.call(IdentityVerification.t),
      orderByList: orderByList?.call(IdentityVerification.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IdentityVerification] by its [id] or null if no such row exists.
  Future<IdentityVerification?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IdentityVerification>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IdentityVerification]s in the list and returns the inserted rows.
  ///
  /// The returned [IdentityVerification]s will have their `id` fields set.
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
  Future<List<IdentityVerification>> insert(
    _is.DatabaseSession session,
    List<IdentityVerification> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<IdentityVerification>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [IdentityVerification] and returns the inserted row.
  ///
  /// The returned [IdentityVerification] will have its `id` field set.
  Future<IdentityVerification> insertRow(
    _is.DatabaseSession session,
    IdentityVerification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<IdentityVerification>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [IdentityVerification]s in the list and returns the resulting rows.
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
  /// The returned [IdentityVerification]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IdentityVerification>> upsert(
    _is.DatabaseSession session,
    List<IdentityVerification> rows, {
    required _is.ColumnSelections<IdentityVerificationTable> conflictColumns,
    _is.ColumnSelections<IdentityVerificationTable>? updateColumns,
    _is.WhereExpressionBuilder<IdentityVerificationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<IdentityVerification>(
      rows,
      conflictColumns: conflictColumns(IdentityVerification.t),
      updateColumns: updateColumns?.call(IdentityVerification.t),
      updateWhere: updateWhere?.call(IdentityVerification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [IdentityVerification] and returns the resulting row.
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
  /// The returned [IdentityVerification] will have its `id` field set.
  Future<IdentityVerification?> upsertRow(
    _is.DatabaseSession session,
    IdentityVerification row, {
    required _is.ColumnSelections<IdentityVerificationTable> conflictColumns,
    _is.ColumnSelections<IdentityVerificationTable>? updateColumns,
    _is.WhereExpressionBuilder<IdentityVerificationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<IdentityVerification>(
      row,
      conflictColumns: conflictColumns(IdentityVerification.t),
      updateColumns: updateColumns?.call(IdentityVerification.t),
      updateWhere: updateWhere?.call(IdentityVerification.t),
      transaction: transaction,
    );
  }

  /// Updates all [IdentityVerification]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IdentityVerification>> update(
    _is.DatabaseSession session,
    List<IdentityVerification> rows, {
    _is.ColumnSelections<IdentityVerificationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<IdentityVerification>(
      rows,
      columns: columns?.call(IdentityVerification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [IdentityVerification]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IdentityVerification> updateRow(
    _is.DatabaseSession session,
    IdentityVerification row, {
    _is.ColumnSelections<IdentityVerificationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<IdentityVerification>(
      row,
      columns: columns?.call(IdentityVerification.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IdentityVerification] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IdentityVerification?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<IdentityVerificationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<IdentityVerification>(
      id,
      columnValues: columnValues(IdentityVerification.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IdentityVerification]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IdentityVerification>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IdentityVerificationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<IdentityVerificationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IdentityVerificationTable>? orderBy,
    _is.OrderByListBuilder<IdentityVerificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<IdentityVerification>(
      columnValues: columnValues(IdentityVerification.t.updateTable),
      where: where(IdentityVerification.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IdentityVerification.t),
      orderByList: orderByList?.call(IdentityVerification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [IdentityVerification]s in the list and returns the deleted rows.
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
  Future<List<IdentityVerification>> delete(
    _is.DatabaseSession session,
    List<IdentityVerification> rows, {
    _is.OrderByBuilder<IdentityVerificationTable>? orderBy,
    _is.OrderByListBuilder<IdentityVerificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<IdentityVerification>(
      rows,
      orderBy: orderBy?.call(IdentityVerification.t),
      orderByList: orderByList?.call(IdentityVerification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [IdentityVerification].
  Future<IdentityVerification> deleteRow(
    _is.DatabaseSession session,
    IdentityVerification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IdentityVerification>(
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
  Future<List<IdentityVerification>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IdentityVerificationTable> where,
    _is.OrderByBuilder<IdentityVerificationTable>? orderBy,
    _is.OrderByListBuilder<IdentityVerificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<IdentityVerification>(
      where: where(IdentityVerification.t),
      orderBy: orderBy?.call(IdentityVerification.t),
      orderByList: orderByList?.call(IdentityVerification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IdentityVerificationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<IdentityVerification>(
      where: where?.call(IdentityVerification.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IdentityVerification] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IdentityVerificationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IdentityVerification>(
      where: where(IdentityVerification.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
