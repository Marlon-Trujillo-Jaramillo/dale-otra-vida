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
import 'package:dale_otra_vida_client/src/protocol/protocol.dart' as _ilolbpul;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'category.dart' as _issw2w8j;
import 'item_condition.dart' as _ittj06x2;
import 'listing_status.dart' as _igczfm3x;
import 'listing_type.dart' as _i1ntjlwm;

/// Something a user offers to donate, exchange, sell or lend.
abstract class Listing
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      photoUrls: _ilolbpul.Protocol().deserialize<List<String>>(
        jsonSerialization['photoUrls'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      price: jsonSerialization['price'] as int?,
      returnDate: jsonSerialization['returnDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['returnDate'],
            ),
      wantedInExchange: jsonSerialization['wantedInExchange'] as String?,
      neighborhood: jsonSerialization['neighborhood'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      safeMeetingPoint: jsonSerialization['safeMeetingPoint'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [Listing]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
