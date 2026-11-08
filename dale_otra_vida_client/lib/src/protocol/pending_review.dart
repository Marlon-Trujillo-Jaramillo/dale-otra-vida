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
import 'member_profile.dart' as _iuh59zig;

/// A delivery the caller took part in and has not rated yet.
abstract class PendingReview
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PendingReview._({
    required this.listingId,
    required this.listingTitle,
    this.photoUrl,
    required this.member,
  });

  factory PendingReview({
    required int listingId,
    required String listingTitle,
    String? photoUrl,
    required _iuh59zig.MemberProfile member,
  }) = _PendingReviewImpl;

  factory PendingReview.fromJson(Map<String, dynamic> jsonSerialization) {
    return PendingReview(
      listingId: jsonSerialization['listingId'] as int,
      listingTitle: jsonSerialization['listingTitle'] as String,
      photoUrl: jsonSerialization['photoUrl'] as String?,
      member: _ilolbpul.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['member'],
      ),
    );
  }

  int listingId;

  String listingTitle;

  String? photoUrl;

  /// The other side of the delivery, the one to rate.
  _iuh59zig.MemberProfile member;

  /// Returns a shallow copy of this [PendingReview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PendingReview copyWith({
    int? listingId,
    String? listingTitle,
    String? photoUrl,
    _iuh59zig.MemberProfile? member,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PendingReview',
      'listingId': listingId,
      'listingTitle': listingTitle,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'member': member.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PendingReview',
      'listingId': listingId,
      'listingTitle': listingTitle,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'member': member.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PendingReviewImpl extends PendingReview {
  _PendingReviewImpl({
    required int listingId,
    required String listingTitle,
    String? photoUrl,
    required _iuh59zig.MemberProfile member,
  }) : super._(
         listingId: listingId,
         listingTitle: listingTitle,
         photoUrl: photoUrl,
         member: member,
       );

  /// Returns a shallow copy of this [PendingReview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PendingReview copyWith({
    int? listingId,
    String? listingTitle,
    Object? photoUrl = _Undefined,
    _iuh59zig.MemberProfile? member,
  }) {
    return PendingReview(
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      photoUrl: photoUrl is String? ? photoUrl : this.photoUrl,
      member: member ?? this.member.copyWith(),
    );
  }
}
