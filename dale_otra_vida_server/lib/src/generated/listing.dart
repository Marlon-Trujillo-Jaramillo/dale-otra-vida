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
import 'package:dale_otra_vida_server/src/generated/protocol.dart' as _iy3gazpv;
import 'package:serverpod/serverpod.dart' as _is;
import 'category.dart' as _issw2w8j;
import 'item_condition.dart' as _ittj06x2;
import 'listing_status.dart' as _igczfm3x;
import 'listing_type.dart' as _i1ntjlwm;

/// Something a user offers to donate, exchange, sell or lend.
abstract class Listing
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Listing._({
    this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.condition,
    _igczfm3x.ListingStatus? status,
    required this.photoUrls,
    this.expiresAt,
    this.price,
    this.returnDate,
    this.wantedInExchange,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    this.safeMeetingPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : status = status ?? _igczfm3x.ListingStatus.available,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Listing({
    int? id,
    required int ownerId,
    required String title,
    required String description,
    required _i1ntjlwm.ListingType type,
    required _issw2w8j.Category category,
    required _ittj06x2.ItemCondition condition,
    _igczfm3x.ListingStatus? status,
    required List<String> photoUrls,
    DateTime? expiresAt,
    int? price,
    DateTime? returnDate,
    String? wantedInExchange,
    required String neighborhood,
    required double latitude,
    required double longitude,
    String? safeMeetingPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ListingImpl;

  factory Listing.fromJson(Map<String, dynamic> jsonSerialization) {
    return Listing(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as int,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      type: _i1ntjlwm.ListingType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      category: _issw2w8j.Category.fromJson(
        (jsonSerialization['category'] as String),
      ),
      condition: _ittj06x2.ItemCondition.fromJson(
        (jsonSerialization['condition'] as String),
      ),
      status: jsonSerialization['status'] == null
          ? null
          : _igczfm3x.ListingStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      photoUrls: _iy3gazpv.Protocol().deserialize<List<String>>(
        jsonSerialization['photoUrls'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      price: jsonSerialization['price'] as int?,
      returnDate: jsonSerialization['returnDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['returnDate']),
      wantedInExchange: jsonSerialization['wantedInExchange'] as String?,
      neighborhood: jsonSerialization['neighborhood'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      safeMeetingPoint: jsonSerialization['safeMeetingPoint'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ListingTable();

  static const db = ListingRepository._();

  @override
  int? id;

  int ownerId;

  String title;

  String description;

  _i1ntjlwm.ListingType type;

  _issw2w8j.Category category;

  _ittj06x2.ItemCondition condition;

  _igczfm3x.ListingStatus status;

  List<String> photoUrls;

  /// Required for food.
  DateTime? expiresAt;

  /// Price in COP, only for `sell`.
  int? price;

  /// Only for `lend`.
  DateTime? returnDate;

  /// Only for `exchange`: what the owner wants in return.
  String? wantedInExchange;

  String neighborhood;

  /// Approximate location (rounded to ~100 m).
  double latitude;

  double longitude;

  String? safeMeetingPoint;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Listing]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Listing copyWith({
    int? id,
    int? ownerId,
    String? title,
    String? description,
    _i1ntjlwm.ListingType? type,
    _issw2w8j.Category? category,
    _ittj06x2.ItemCondition? condition,
    _igczfm3x.ListingStatus? status,
    List<String>? photoUrls,
    DateTime? expiresAt,
    int? price,
    DateTime? returnDate,
    String? wantedInExchange,
    String? neighborhood,
    double? latitude,
    double? longitude,
    String? safeMeetingPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Listing',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'type': type.toJson(),
      'category': category.toJson(),
      'condition': condition.toJson(),
      'status': status.toJson(),
      'photoUrls': photoUrls.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (price != null) 'price': price,
      if (returnDate != null) 'returnDate': returnDate?.toJson(),
      if (wantedInExchange != null) 'wantedInExchange': wantedInExchange,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      if (safeMeetingPoint != null) 'safeMeetingPoint': safeMeetingPoint,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Listing',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'type': type.toJson(),
      'category': category.toJson(),
      'condition': condition.toJson(),
      'status': status.toJson(),
      'photoUrls': photoUrls.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (price != null) 'price': price,
      if (returnDate != null) 'returnDate': returnDate?.toJson(),
      if (wantedInExchange != null) 'wantedInExchange': wantedInExchange,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      if (safeMeetingPoint != null) 'safeMeetingPoint': safeMeetingPoint,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static ListingInclude include() {
    return ListingInclude._();
  }

  static ListingIncludeList includeList({
    _is.WhereExpressionBuilder<ListingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ListingTable>? orderBy,
    _is.OrderByListBuilder<ListingTable>? orderByList,
    ListingInclude? include,
  }) {
    return ListingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Listing.t),
      orderByList: orderByList?.call(Listing.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListingImpl extends Listing {
  _ListingImpl({
    int? id,
    required int ownerId,
    required String title,
    required String description,
    required _i1ntjlwm.ListingType type,
    required _issw2w8j.Category category,
    required _ittj06x2.ItemCondition condition,
    _igczfm3x.ListingStatus? status,
    required List<String> photoUrls,
    DateTime? expiresAt,
    int? price,
    DateTime? returnDate,
    String? wantedInExchange,
    required String neighborhood,
    required double latitude,
    required double longitude,
    String? safeMeetingPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         title: title,
         description: description,
         type: type,
         category: category,
         condition: condition,
         status: status,
         photoUrls: photoUrls,
         expiresAt: expiresAt,
         price: price,
         returnDate: returnDate,
         wantedInExchange: wantedInExchange,
         neighborhood: neighborhood,
         latitude: latitude,
         longitude: longitude,
         safeMeetingPoint: safeMeetingPoint,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Listing]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Listing copyWith({
    Object? id = _Undefined,
    int? ownerId,
    String? title,
    String? description,
    _i1ntjlwm.ListingType? type,
    _issw2w8j.Category? category,
    _ittj06x2.ItemCondition? condition,
    _igczfm3x.ListingStatus? status,
    List<String>? photoUrls,
    Object? expiresAt = _Undefined,
    Object? price = _Undefined,
    Object? returnDate = _Undefined,
    Object? wantedInExchange = _Undefined,
    String? neighborhood,
    double? latitude,
    double? longitude,
    Object? safeMeetingPoint = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls.map((e0) => e0).toList(),
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      price: price is int? ? price : this.price,
      returnDate: returnDate is DateTime? ? returnDate : this.returnDate,
      wantedInExchange: wantedInExchange is String?
          ? wantedInExchange
          : this.wantedInExchange,
      neighborhood: neighborhood ?? this.neighborhood,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      safeMeetingPoint: safeMeetingPoint is String?
          ? safeMeetingPoint
          : this.safeMeetingPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ListingUpdateTable extends _is.UpdateTable<ListingTable> {
  ListingUpdateTable(super.table);

  _is.ColumnValue<int, int> ownerId(int value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<_i1ntjlwm.ListingType, _i1ntjlwm.ListingType> type(
    _i1ntjlwm.ListingType value,
  ) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<_issw2w8j.Category, _issw2w8j.Category> category(
    _issw2w8j.Category value,
  ) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<_ittj06x2.ItemCondition, _ittj06x2.ItemCondition> condition(
    _ittj06x2.ItemCondition value,
  ) => _is.ColumnValue(
    table.condition,
    value,
  );

  _is.ColumnValue<_igczfm3x.ListingStatus, _igczfm3x.ListingStatus> status(
    _igczfm3x.ListingStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<List<String>, List<String>> photoUrls(List<String> value) =>
      _is.ColumnValue(
        table.photoUrls,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime? value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<int, int> price(int? value) => _is.ColumnValue(
    table.price,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> returnDate(DateTime? value) =>
      _is.ColumnValue(
        table.returnDate,
        value,
      );

  _is.ColumnValue<String, String> wantedInExchange(String? value) =>
      _is.ColumnValue(
        table.wantedInExchange,
        value,
      );

  _is.ColumnValue<String, String> neighborhood(String value) => _is.ColumnValue(
    table.neighborhood,
    value,
  );

  _is.ColumnValue<double, double> latitude(double value) => _is.ColumnValue(
    table.latitude,
    value,
  );

  _is.ColumnValue<double, double> longitude(double value) => _is.ColumnValue(
    table.longitude,
    value,
  );

  _is.ColumnValue<String, String> safeMeetingPoint(String? value) =>
      _is.ColumnValue(
        table.safeMeetingPoint,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class ListingTable extends _is.Table<int?> {
  ListingTable({super.tableRelation}) : super(tableName: 'listing') {
    updateTable = ListingUpdateTable(this);
    ownerId = _is.ColumnInt(
      'ownerId',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    type = _is.ColumnEnum(
      'type',
      this,
      _is.EnumSerialization.byName,
    );
    category = _is.ColumnEnum(
      'category',
      this,
      _is.EnumSerialization.byName,
    );
    condition = _is.ColumnEnum(
      'condition',
      this,
      _is.EnumSerialization.byName,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    photoUrls = _is.ColumnSerializable<List<String>>(
      'photoUrls',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    price = _is.ColumnInt(
      'price',
      this,
    );
    returnDate = _is.ColumnDateTime(
      'returnDate',
      this,
    );
    wantedInExchange = _is.ColumnString(
      'wantedInExchange',
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
    safeMeetingPoint = _is.ColumnString(
      'safeMeetingPoint',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final ListingUpdateTable updateTable;

  late final _is.ColumnInt ownerId;

  late final _is.ColumnString title;

  late final _is.ColumnString description;

  late final _is.ColumnEnum<_i1ntjlwm.ListingType> type;

  late final _is.ColumnEnum<_issw2w8j.Category> category;

  late final _is.ColumnEnum<_ittj06x2.ItemCondition> condition;

  late final _is.ColumnEnum<_igczfm3x.ListingStatus> status;

  late final _is.ColumnSerializable<List<String>> photoUrls;

  /// Required for food.
  late final _is.ColumnDateTime expiresAt;

  /// Price in COP, only for `sell`.
  late final _is.ColumnInt price;

  /// Only for `lend`.
  late final _is.ColumnDateTime returnDate;

  /// Only for `exchange`: what the owner wants in return.
  late final _is.ColumnString wantedInExchange;

  late final _is.ColumnString neighborhood;

  /// Approximate location (rounded to ~100 m).
  late final _is.ColumnDouble latitude;

  late final _is.ColumnDouble longitude;

  late final _is.ColumnString safeMeetingPoint;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    title,
    description,
    type,
    category,
    condition,
    status,
    photoUrls,
    expiresAt,
    price,
    returnDate,
    wantedInExchange,
    neighborhood,
    latitude,
    longitude,
    safeMeetingPoint,
    createdAt,
    updatedAt,
  ];
}

class ListingInclude extends _is.IncludeObject {
  ListingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Listing.t;
}

class ListingIncludeList extends _is.IncludeList {
  ListingIncludeList._({
    _is.WhereExpressionBuilder<ListingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Listing.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Listing.t;
}

class ListingRepository {
  const ListingRepository._();

  /// Returns a list of [Listing]s matching the given query parameters.
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
  Future<List<Listing>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ListingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ListingTable>? orderBy,
    _is.OrderByListBuilder<ListingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Listing>(
      where: where?.call(Listing.t),
      orderBy: orderBy?.call(Listing.t),
      orderByList: orderByList?.call(Listing.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Listing] matching the given query parameters.
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
  Future<Listing?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ListingTable>? where,
    int? offset,
    _is.OrderByBuilder<ListingTable>? orderBy,
    _is.OrderByListBuilder<ListingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Listing>(
      where: where?.call(Listing.t),
      orderBy: orderBy?.call(Listing.t),
      orderByList: orderByList?.call(Listing.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Listing] by its [id] or null if no such row exists.
  Future<Listing?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Listing>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Listing]s in the list and returns the inserted rows.
  ///
  /// The returned [Listing]s will have their `id` fields set.
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
  Future<List<Listing>> insert(
    _is.DatabaseSession session,
    List<Listing> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Listing>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Listing] and returns the inserted row.
  ///
  /// The returned [Listing] will have its `id` field set.
  Future<Listing> insertRow(
    _is.DatabaseSession session,
    Listing row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Listing>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Listing]s in the list and returns the resulting rows.
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
  /// The returned [Listing]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Listing>> upsert(
    _is.DatabaseSession session,
    List<Listing> rows, {
    required _is.ColumnSelections<ListingTable> conflictColumns,
    _is.ColumnSelections<ListingTable>? updateColumns,
    _is.WhereExpressionBuilder<ListingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Listing>(
      rows,
      conflictColumns: conflictColumns(Listing.t),
      updateColumns: updateColumns?.call(Listing.t),
      updateWhere: updateWhere?.call(Listing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Listing] and returns the resulting row.
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
  /// The returned [Listing] will have its `id` field set.
  Future<Listing?> upsertRow(
    _is.DatabaseSession session,
    Listing row, {
    required _is.ColumnSelections<ListingTable> conflictColumns,
    _is.ColumnSelections<ListingTable>? updateColumns,
    _is.WhereExpressionBuilder<ListingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Listing>(
      row,
      conflictColumns: conflictColumns(Listing.t),
      updateColumns: updateColumns?.call(Listing.t),
      updateWhere: updateWhere?.call(Listing.t),
      transaction: transaction,
    );
  }

  /// Updates all [Listing]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Listing>> update(
    _is.DatabaseSession session,
    List<Listing> rows, {
    _is.ColumnSelections<ListingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Listing>(
      rows,
      columns: columns?.call(Listing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Listing]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Listing> updateRow(
    _is.DatabaseSession session,
    Listing row, {
    _is.ColumnSelections<ListingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Listing>(
      row,
      columns: columns?.call(Listing.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Listing] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Listing?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ListingUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Listing>(
      id,
      columnValues: columnValues(Listing.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Listing]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Listing>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ListingUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ListingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ListingTable>? orderBy,
    _is.OrderByListBuilder<ListingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Listing>(
      columnValues: columnValues(Listing.t.updateTable),
      where: where(Listing.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Listing.t),
      orderByList: orderByList?.call(Listing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Listing]s in the list and returns the deleted rows.
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
  Future<List<Listing>> delete(
    _is.DatabaseSession session,
    List<Listing> rows, {
    _is.OrderByBuilder<ListingTable>? orderBy,
    _is.OrderByListBuilder<ListingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Listing>(
      rows,
      orderBy: orderBy?.call(Listing.t),
      orderByList: orderByList?.call(Listing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Listing].
  Future<Listing> deleteRow(
    _is.DatabaseSession session,
    Listing row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Listing>(
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
  Future<List<Listing>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ListingTable> where,
    _is.OrderByBuilder<ListingTable>? orderBy,
    _is.OrderByListBuilder<ListingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Listing>(
      where: where(Listing.t),
      orderBy: orderBy?.call(Listing.t),
      orderByList: orderByList?.call(Listing.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ListingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Listing>(
      where: where?.call(Listing.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Listing] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ListingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Listing>(
      where: where(Listing.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
