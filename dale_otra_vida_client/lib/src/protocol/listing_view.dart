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
import 'listing.dart' as _ir9e9w84;
import 'member_profile.dart' as _iuh59zig;

/// Public view of a listing, including resolved photos and owner without location.
abstract class ListingView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ListingView._({
    required this.listing,
    required this.owner,
    this.distanceKm,
    required this.isMine,
  });

  factory ListingView({
    required _ir9e9w84.Listing listing,
    required _iuh59zig.MemberProfile owner,
    double? distanceKm,
    required bool isMine,
  }) = _ListingViewImpl;

  factory ListingView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ListingView(
      listing: _ilolbpul.Protocol().deserialize<_ir9e9w84.Listing>(
        jsonSerialization['listing'],
      ),
      owner: _ilolbpul.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['owner'],
      ),
      distanceKm: (jsonSerialization['distanceKm'] as num?)?.toDouble(),
      isMine: _isc.BoolJsonExtension.fromJson(jsonSerialization['isMine']),
    );
  }

  _ir9e9w84.Listing listing;

  _iuh59zig.MemberProfile owner;

  double? distanceKm;

  bool isMine;

  /// Returns a shallow copy of this [ListingView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ListingView copyWith({
    _ir9e9w84.Listing? listing,
    _iuh59zig.MemberProfile? owner,
    double? distanceKm,
    bool? isMine,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ListingView',
      'listing': listing.toJson(),
      'owner': owner.toJson(),
      if (distanceKm != null) 'distanceKm': distanceKm,
      'isMine': isMine,
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
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListingViewImpl extends ListingView {
  _ListingViewImpl({
    required _ir9e9w84.Listing listing,
    required _iuh59zig.MemberProfile owner,
    double? distanceKm,
    required bool isMine,
  }) : super._(
         listing: listing,
         owner: owner,
         distanceKm: distanceKm,
         isMine: isMine,
       );

  /// Returns a shallow copy of this [ListingView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ListingView copyWith({
    _ir9e9w84.Listing? listing,
    _iuh59zig.MemberProfile? owner,
    Object? distanceKm = _Undefined,
    bool? isMine,
  }) {
    return ListingView(
      listing: listing ?? this.listing.copyWith(),
      owner: owner ?? this.owner.copyWith(),
      distanceKm: distanceKm is double? ? distanceKm : this.distanceKm,
      isMine: isMine ?? this.isMine,
    );
  }
}
