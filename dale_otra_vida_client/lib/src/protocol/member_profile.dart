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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Public profile of an app user, one per auth user.
abstract class MemberProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    DateTime? createdAt,
  }) : isVerified = isVerified ?? false,
       ratingAvg = ratingAvg ?? 0.0,
       reviewCount = reviewCount ?? 0,
       deliveryCount = deliveryCount ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory MemberProfile({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
    DateTime? createdAt,
  }) = _MemberProfileImpl;

  factory MemberProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MemberProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _ilolbpul.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['authUser'],
            ),
      displayName: jsonSerialization['displayName'] as String,
      neighborhood: jsonSerialization['neighborhood'] as String?,
      latitude: (jsonSerialization['latitude'] as num?)?.toDouble(),
      longitude: (jsonSerialization['longitude'] as num?)?.toDouble(),
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      isVerified: jsonSerialization['isVerified'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isVerified']),
      ratingAvg: (jsonSerialization['ratingAvg'] as num?)?.toDouble(),
      reviewCount: jsonSerialization['reviewCount'] as int?,
      deliveryCount: jsonSerialization['deliveryCount'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  _iacc.AuthUser? authUser;

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

  DateTime createdAt;

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MemberProfile copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    String? displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
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
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberProfileImpl extends MemberProfile {
  _MemberProfileImpl({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String displayName,
    String? neighborhood,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    int? deliveryCount,
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
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MemberProfile copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
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
    DateTime? createdAt,
  }) {
    return MemberProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacc.AuthUser?
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
