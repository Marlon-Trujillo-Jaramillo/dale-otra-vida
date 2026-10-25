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
import 'listing.dart' as _ir9e9w84;
import 'listing_request.dart' as _i0jjpqa3;
import 'member_profile.dart' as _iuh59zig;

/// Public view of a listing, including resolved photos and owner without location.
abstract class ListingView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ListingView._({
    required this.listing,
    required this.owner,
    this.distanceKm,
    required this.isMine,
    this.myRequest,
    int? pendingRequestCount,
  }) : pendingRequestCount = pendingRequestCount ?? 0;

  factory ListingView({
    required _ir9e9w84.Listing listing,
    required _iuh59zig.MemberProfile owner,
    double? distanceKm,
    required bool isMine,
    _i0jjpqa3.ListingRequest? myRequest,
    int? pendingRequestCount,
  }) = _ListingViewImpl;

  factory ListingView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ListingView(
      listing: _iy3gazpv.Protocol().deserialize<_ir9e9w84.Listing>(
        jsonSerialization['listing'],
      ),
      owner: _iy3gazpv.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['owner'],
      ),
      distanceKm: (jsonSerialization['distanceKm'] as num?)?.toDouble(),
      isMine: _is.BoolJsonExtension.fromJson(jsonSerialization['isMine']),
      myRequest: jsonSerialization['myRequest'] == null
          ? null
          : _iy3gazpv.Protocol().deserialize<_i0jjpqa3.ListingRequest>(
              jsonSerialization['myRequest'],
            ),
      pendingRequestCount: jsonSerialization['pendingRequestCount'] as int?,
    );
  }

  _ir9e9w84.Listing listing;

  _iuh59zig.MemberProfile owner;

  double? distanceKm;

  bool isMine;

  /// The caller's request on this listing, whatever its status.
  _i0jjpqa3.ListingRequest? myRequest;

  /// Pending requests on the caller's own listing, 0 for everyone else.
  int pendingRequestCount;

  /// Returns a shallow copy of this [ListingView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ListingView copyWith({
    _ir9e9w84.Listing? listing,
    _iuh59zig.MemberProfile? owner,
    double? distanceKm,
    bool? isMine,
    _i0jjpqa3.ListingRequest? myRequest,
    int? pendingRequestCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListingView',
      'listing': listing.toJson(),
      'owner': owner.toJson(),
      if (distanceKm != null) 'distanceKm': distanceKm,
      'isMine': isMine,
      if (myRequest != null) 'myRequest': myRequest?.toJson(),
      'pendingRequestCount': pendingRequestCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ListingView',
      'listing': listing.toJsonForProtocol(),
      'owner': owner.toJsonForProtocol(),
      if (distanceKm != null) 'distanceKm': distanceKm,
      'isMine': isMine,
      if (myRequest != null) 'myRequest': myRequest?.toJsonForProtocol(),
      'pendingRequestCount': pendingRequestCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListingViewImpl extends ListingView {
  _ListingViewImpl({
    required _ir9e9w84.Listing listing,
    required _iuh59zig.MemberProfile owner,
    double? distanceKm,
    required bool isMine,
    _i0jjpqa3.ListingRequest? myRequest,
    int? pendingRequestCount,
  }) : super._(
         listing: listing,
         owner: owner,
         distanceKm: distanceKm,
         isMine: isMine,
         myRequest: myRequest,
         pendingRequestCount: pendingRequestCount,
       );

  /// Returns a shallow copy of this [ListingView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ListingView copyWith({
    _ir9e9w84.Listing? listing,
    _iuh59zig.MemberProfile? owner,
    Object? distanceKm = _Undefined,
    bool? isMine,
    Object? myRequest = _Undefined,
    int? pendingRequestCount,
  }) {
    return ListingView(
      listing: listing ?? this.listing.copyWith(),
      owner: owner ?? this.owner.copyWith(),
      distanceKm: distanceKm is double? ? distanceKm : this.distanceKm,
      isMine: isMine ?? this.isMine,
      myRequest: myRequest is _i0jjpqa3.ListingRequest?
          ? myRequest
          : this.myRequest?.copyWith(),
      pendingRequestCount: pendingRequestCount ?? this.pendingRequestCount,
    );
  }
}
