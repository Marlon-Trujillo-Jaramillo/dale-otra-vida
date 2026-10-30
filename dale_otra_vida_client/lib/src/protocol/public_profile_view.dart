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
import 'listing_view.dart' as _ijuym7ok;
import 'member_profile.dart' as _iuh59zig;
import 'review_view.dart' as _io58qecx;

/// Profile screen data: stats, listings, delivery history and reviews.
abstract class PublicProfileView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PublicProfileView._({
    required this.profile,
    required this.isMe,
    required this.listings,
    required this.history,
    required this.reviews,
  });

  factory PublicProfileView({
    required _iuh59zig.MemberProfile profile,
    required bool isMe,
    required List<_ijuym7ok.ListingView> listings,
    required List<_ijuym7ok.ListingView> history,
    required List<_io58qecx.ReviewView> reviews,
  }) = _PublicProfileViewImpl;

  factory PublicProfileView.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicProfileView(
      profile: _ilolbpul.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['profile'],
      ),
      isMe: _isc.BoolJsonExtension.fromJson(jsonSerialization['isMe']),
      listings: _ilolbpul.Protocol().deserialize<List<_ijuym7ok.ListingView>>(
        jsonSerialization['listings'],
      ),
      history: _ilolbpul.Protocol().deserialize<List<_ijuym7ok.ListingView>>(
        jsonSerialization['history'],
      ),
      reviews: _ilolbpul.Protocol().deserialize<List<_io58qecx.ReviewView>>(
        jsonSerialization['reviews'],
      ),
    );
  }

  /// Without coordinates.
  _iuh59zig.MemberProfile profile;

  bool isMe;

  /// Available and reserved listings, newest first.
  List<_ijuym7ok.ListingView> listings;

  /// Delivered listings, newest first.
  List<_ijuym7ok.ListingView> history;

  /// Newest reviews received.
  List<_io58qecx.ReviewView> reviews;

  /// Returns a shallow copy of this [PublicProfileView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PublicProfileView copyWith({
    _iuh59zig.MemberProfile? profile,
    bool? isMe,
    List<_ijuym7ok.ListingView>? listings,
    List<_ijuym7ok.ListingView>? history,
    List<_io58qecx.ReviewView>? reviews,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PublicProfileView',
      'profile': profile.toJson(),
      'isMe': isMe,
      'listings': listings.toJson(valueToJson: (v) => v.toJson()),
      'history': history.toJson(valueToJson: (v) => v.toJson()),
      'reviews': reviews.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PublicProfileView',
      'profile': profile.toJsonForProtocol(),
      'isMe': isMe,
      'listings': listings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'history': history.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'reviews': reviews.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _PublicProfileViewImpl extends PublicProfileView {
  _PublicProfileViewImpl({
    required _iuh59zig.MemberProfile profile,
    required bool isMe,
    required List<_ijuym7ok.ListingView> listings,
    required List<_ijuym7ok.ListingView> history,
    required List<_io58qecx.ReviewView> reviews,
  }) : super._(
         profile: profile,
         isMe: isMe,
         listings: listings,
         history: history,
         reviews: reviews,
       );

  /// Returns a shallow copy of this [PublicProfileView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PublicProfileView copyWith({
    _iuh59zig.MemberProfile? profile,
    bool? isMe,
    List<_ijuym7ok.ListingView>? listings,
    List<_ijuym7ok.ListingView>? history,
    List<_io58qecx.ReviewView>? reviews,
  }) {
    return PublicProfileView(
      profile: profile ?? this.profile.copyWith(),
      isMe: isMe ?? this.isMe,
      listings: listings ?? this.listings.map((e0) => e0.copyWith()).toList(),
      history: history ?? this.history.map((e0) => e0.copyWith()).toList(),
      reviews: reviews ?? this.reviews.map((e0) => e0.copyWith()).toList(),
    );
  }
}
