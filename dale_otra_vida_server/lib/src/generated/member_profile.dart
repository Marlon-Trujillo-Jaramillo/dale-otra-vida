/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dale_otra_vida_server/src/generated/protocol.dart' as _iy3gazpv;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'account_type.dart' as _itrmkf8a;

/// Public profile of an app user, one per auth user.
abstract class MemberProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MemberProfile._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.displayName,
    this.neighborhood,
    this.latitude,
    this.longitude,
    this.avatarUrl,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
    _itrmkf8a.AccountType? accountType,
    DateTime? createdAt,
  }) : isVerified = isVerified ?? false,
       ratingAvg = ratingAvg ?? 0.0,
       reviewCount = reviewCount ?? 0,
       deliveryCount = deliveryCount ?? 0,
       accountType = accountType ?? _itrmkf8a.AccountType.person,
       createdAt = createdAt ?? DateTime.now();

  factory MemberProfile({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
    _itrmkf8a.AccountType? accountType,
    DateTime? createdAt,
  }) = _MemberProfileImpl;

  factory MemberProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MemberProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iy3gazpv.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      displayName: jsonSerialization['displayName'] as String,
      neighborhood: jsonSerialization['neighborhood'] as String?,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      isVerified: jsonSerialization['isVerified'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isVerified']),
      ratingAvg: (jsonSerialization['ratingAvg'] as num?)?.toDouble(),
      reviewCount: jsonSerialization['reviewCount'] as int?,
      deliveryCount: jsonSerialization['deliveryCount'] as int?,
      accountType: jsonSerialization['accountType'] == null
          ? null
          : _itrmkf8a.AccountType.fromJson(
              (jsonSerialization['accountType'] as String),
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = MemberProfileTable();

  static const db = MemberProfileRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String displayName;

  String? neighborhood;

  /// Approximate home location (rounded to ~100 m), never an exact address.
  double? latitude;

  double? longitude;

  String? avatarUrl;

  bool isVerified;

  double ratingAvg;

  int reviewCount;

  int deliveryCount;

  _itrmkf8a.AccountType accountType;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MemberProfile copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
    _itrmkf8a.AccountType? accountType,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MemberProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'displayName': displayName,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'ratingAvg': ratingAvg,
      'reviewCount': reviewCount,
      'deliveryCount': deliveryCount,
      'accountType': accountType.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MemberProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'displayName': displayName,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'ratingAvg': ratingAvg,
      'reviewCount': reviewCount,
      'deliveryCount': deliveryCount,
      'accountType': accountType.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static MemberProfileInclude include({_iacs.AuthUserInclude? authUser}) {
    return MemberProfileInclude._(authUser: authUser);
  }

  static MemberProfileIncludeList includeList({
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    MemberProfileInclude? include,
  }) {
    return MemberProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberProfileImpl extends MemberProfile {
  _MemberProfileImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
    _itrmkf8a.AccountType? accountType,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         displayName: displayName,
         neighborhood: neighborhood,
         latitude: latitude,
         longitude: longitude,
         avatarUrl: avatarUrl,
         isVerified: isVerified,
         ratingAvg: ratingAvg,
         reviewCount: reviewCount,
         deliveryCount: deliveryCount,
         accountType: accountType,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MemberProfile copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? displayName,
    Object? neighborhood = _Undefined,
    Object? latitude = _Undefined,
    Object? longitude = _Undefined,
    Object? avatarUrl = _Undefined,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
    _itrmkf8a.AccountType? accountType,
    DateTime? createdAt,
  }) {
    return MemberProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      displayName: displayName ?? this.displayName,
      neighborhood: neighborhood is String? ? neighborhood : this.neighborhood,
      latitude: latitude is double? ? latitude : this.latitude,
      longitude: longitude is double? ? longitude : this.longitude,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryCount: deliveryCount ?? this.deliveryCount,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MemberProfileUpdateTable extends _is.UpdateTable<MemberProfileTable> {
  MemberProfileUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<String, String> neighborhood(String? value) =>
      _is.ColumnValue(
        table.neighborhood,
        value,
      );

  _is.ColumnValue<double, double> latitude(double? value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double? value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<String, String> avatarUrl(String? value) => _is.ColumnValue(
    table.avatarUrl,
    value,
  );

  _is.ColumnValue<bool, bool> isVerified(bool value) => _is.ColumnValue(
    table.isVerified,
    value,
  );

  _is.ColumnValue<double, double> ratingAvg(double value) => _is.ColumnValue(
    table.ratingAvg,
    value,
  );

  _is.ColumnValue<int, int> reviewCount(int value) => _is.ColumnValue(
    table.reviewCount,
    value,
  );

  _is.ColumnValue<int, int> deliveryCount(int value) => _is.ColumnValue(
    table.deliveryCount,
    value,
  );

  _is.ColumnValue<_itrmkf8a.AccountType, _itrmkf8a.AccountType> accountType(
    _itrmkf8a.AccountType value,
  ) => _is.ColumnValue(
    table.accountType,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MemberProfileTable extends _is.Table<int?> {
  MemberProfileTable({super.tableRelation})
    : super(tableName: 'member_profile') {
    updateTable = MemberProfileUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    neighborhood = _is.ColumnString(
      'neighborhood',
      this,
    );
    latitude = _is.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _is.ColumnDouble(
      'longitude',
      this,
    );
    avatarUrl = _is.ColumnString(
      'avatarUrl',
      this,
    );
    isVerified = _is.ColumnBool(
      'isVerified',
      this,
      hasDefault: true,
    );
    ratingAvg = _is.ColumnDouble(
      'ratingAvg',
      this,
      hasDefault: true,
    );
    reviewCount = _is.ColumnInt(
      'reviewCount',
      this,
      hasDefault: true,
    );
    deliveryCount = _is.ColumnInt(
      'deliveryCount',
      this,
      hasDefault: true,
    );
    accountType = _is.ColumnEnum(
      'accountType',
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

  late final MemberProfileUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString displayName;

  late final _is.ColumnString neighborhood;

  /// Approximate home location (rounded to ~100 m), never an exact address.
  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnString avatarUrl;

  late final _is.ColumnBool isVerified;

  late final _is.ColumnDouble ratingAvg;

  late final _is.ColumnInt reviewCount;

  late final _is.ColumnInt deliveryCount;

  late final _is.ColumnEnum<_itrmkf8a.AccountType> accountType;

  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: MemberProfile.t.authUserId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    displayName,
    neighborhood,
    latitude,
    longitude,
    avatarUrl,
    isVerified,
    ratingAvg,
    reviewCount,
    deliveryCount,
    accountType,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class MemberProfileInclude extends _is.IncludeObject {
  MemberProfileInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => MemberProfile.t;
}

class MemberProfileIncludeList extends _is.IncludeList {
  MemberProfileIncludeList._({
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MemberProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MemberProfile.t;
}

class MemberProfileRepository {
  const MemberProfileRepository._();

  final attachRow = const MemberProfileAttachRowRepository._();

  /// Returns a list of [MemberProfile]s matching the given query parameters.
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
  Future<List<MemberProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    MemberProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MemberProfile>(
      where: where?.call(MemberProfile.t),
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MemberProfile] matching the given query parameters.
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
  Future<MemberProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    MemberProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MemberProfile>(
      where: where?.call(MemberProfile.t),
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MemberProfile] by its [id] or null if no such row exists.
  Future<MemberProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    MemberProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MemberProfile>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MemberProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [MemberProfile]s will have their `id` fields set.
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
  Future<List<MemberProfile>> insert(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MemberProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MemberProfile] and returns the inserted row.
  ///
  /// The returned [MemberProfile] will have its `id` field set.
  Future<MemberProfile> insertRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MemberProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MemberProfile]s in the list and returns the resulting rows.
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
  /// The returned [MemberProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MemberProfile>> upsert(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    required _is.ColumnSelections<MemberProfileTable> conflictColumns,
    _is.ColumnSelections<MemberProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MemberProfile>(
      rows,
      conflictColumns: conflictColumns(MemberProfile.t),
      updateColumns: updateColumns?.call(MemberProfile.t),
      updateWhere: updateWhere?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MemberProfile] and returns the resulting row.
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
  /// The returned [MemberProfile] will have its `id` field set.
  Future<MemberProfile?> upsertRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    required _is.ColumnSelections<MemberProfileTable> conflictColumns,
    _is.ColumnSelections<MemberProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MemberProfile>(
      row,
      conflictColumns: conflictColumns(MemberProfile.t),
      updateColumns: updateColumns?.call(MemberProfile.t),
      updateWhere: updateWhere?.call(MemberProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [MemberProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MemberProfile>> update(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    _is.ColumnSelections<MemberProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MemberProfile>(
      rows,
      columns: columns?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MemberProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MemberProfile> updateRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    _is.ColumnSelections<MemberProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MemberProfile>(
      row,
      columns: columns?.call(MemberProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MemberProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MemberProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MemberProfileUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MemberProfile>(
      id,
      columnValues: columnValues(MemberProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MemberProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MemberProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MemberProfileUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MemberProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MemberProfile>(
      columnValues: columnValues(MemberProfile.t.updateTable),
      where: where(MemberProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MemberProfile]s in the list and returns the deleted rows.
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
  Future<List<MemberProfile>> delete(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MemberProfile>(
      rows,
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MemberProfile].
  Future<MemberProfile> deleteRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MemberProfile>(
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
  Future<List<MemberProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberProfileTable> where,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MemberProfile>(
      where: where(MemberProfile.t),
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MemberProfile>(
      where: where?.call(MemberProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MemberProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MemberProfile>(
      where: where(MemberProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MemberProfileAttachRowRepository {
  const MemberProfileAttachRowRepository._();

  /// Creates a relation between the given [MemberProfile] and [AuthUser]
  /// by setting the [MemberProfile]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    MemberProfile memberProfile,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (memberProfile.id == null) {
      throw ArgumentError.notNull('memberProfile.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $memberProfile = memberProfile.copyWith(authUserId: authUser.id);
    await session.db.updateRow<MemberProfile>(
      $memberProfile,
      columns: [MemberProfile.t.authUserId],
      transaction: transaction,
    );
  }
}
