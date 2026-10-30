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
import 'review.dart' as _itqm5y01;

/// A review with the reviewer's public profile.
abstract class ReviewView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ReviewView._({
    required this.review,
    required this.reviewer,
  });

  factory ReviewView({
    required _itqm5y01.Review review,
    required _iuh59zig.MemberProfile reviewer,
  }) = _ReviewViewImpl;

  factory ReviewView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReviewView(
      review: _ilolbpul.Protocol().deserialize<_itqm5y01.Review>(
        jsonSerialization['review'],
      ),
      reviewer: _ilolbpul.Protocol().deserialize<_iuh59zig.MemberProfile>(
        jsonSerialization['reviewer'],
      ),
    );
  }

  _itqm5y01.Review review;

  _iuh59zig.MemberProfile reviewer;

  /// Returns a shallow copy of this [ReviewView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ReviewView copyWith({
    _itqm5y01.Review? review,
    _iuh59zig.MemberProfile? reviewer,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReviewView',
      'review': review.toJson(),
      'reviewer': reviewer.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReviewView',
      'review': review.toJsonForProtocol(),
      'reviewer': reviewer.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ReviewViewImpl extends ReviewView {
  _ReviewViewImpl({
    required _itqm5y01.Review review,
    required _iuh59zig.MemberProfile reviewer,
  }) : super._(
         review: review,
         reviewer: reviewer,
       );

  /// Returns a shallow copy of this [ReviewView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ReviewView copyWith({
    _itqm5y01.Review? review,
    _iuh59zig.MemberProfile? reviewer,
  }) {
    return ReviewView(
      review: review ?? this.review.copyWith(),
      reviewer: reviewer ?? this.reviewer.copyWith(),
    );
  }
}
