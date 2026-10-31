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
import 'package:serverpod/serverpod.dart' as _is;

/// Community-wide numbers shown on the home screen.
abstract class CommunityImpact
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CommunityImpact._({
    required this.deliveredCount,
    required this.foodSavedCount,
    required this.activeCount,
    required this.memberCount,
  });

  factory CommunityImpact({
    required int deliveredCount,
    required int foodSavedCount,
    required int activeCount,
    required int memberCount,
  }) = _CommunityImpactImpl;

  factory CommunityImpact.fromJson(Map<String, dynamic> jsonSerialization) {
    return CommunityImpact(
      deliveredCount: jsonSerialization['deliveredCount'] as int,
      foodSavedCount: jsonSerialization['foodSavedCount'] as int,
      activeCount: jsonSerialization['activeCount'] as int,
      memberCount: jsonSerialization['memberCount'] as int,
    );
  }

  /// Listings that reached someone else.
  int deliveredCount;

  /// Delivered food listings.
  int foodSavedCount;

  /// Listings available right now.
  int activeCount;

  int memberCount;

  /// Returns a shallow copy of this [CommunityImpact]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CommunityImpact copyWith({
    int? deliveredCount,
    int? foodSavedCount,
    int? activeCount,
    int? memberCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CommunityImpact',
      'deliveredCount': deliveredCount,
      'foodSavedCount': foodSavedCount,
      'activeCount': activeCount,
      'memberCount': memberCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CommunityImpact',
      'deliveredCount': deliveredCount,
      'foodSavedCount': foodSavedCount,
      'activeCount': activeCount,
      'memberCount': memberCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CommunityImpactImpl extends CommunityImpact {
  _CommunityImpactImpl({
    required int deliveredCount,
    required int foodSavedCount,
    required int activeCount,
    required int memberCount,
  }) : super._(
         deliveredCount: deliveredCount,
         foodSavedCount: foodSavedCount,
         activeCount: activeCount,
         memberCount: memberCount,
       );

  /// Returns a shallow copy of this [CommunityImpact]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CommunityImpact copyWith({
    int? deliveredCount,
    int? foodSavedCount,
    int? activeCount,
    int? memberCount,
  }) {
    return CommunityImpact(
      deliveredCount: deliveredCount ?? this.deliveredCount,
      foodSavedCount: foodSavedCount ?? this.foodSavedCount,
      activeCount: activeCount ?? this.activeCount,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}
