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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Rating left after a delivered listing.
abstract class Review
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Review._({
    this.id,
    required this.listingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Review({
    int? id,
    required int listingId,
    required int reviewerId,
    required int revieweeId,
    required int rating,
    String? comment,
    DateTime? createdAt,
  }) = _ReviewImpl;

  factory Review.fromJson(Map<String, dynamic> jsonSerialization) {
    return Review(
      id: jsonSerialization['id'] as int?,
      listingId: jsonSerialization['listingId'] as int,
      reviewerId: jsonSerialization['reviewerId'] as int,
      revieweeId: jsonSerialization['revieweeId'] as int,
      rating: jsonSerialization['rating'] as int,
      comment: jsonSerialization['comment'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int listingId;

  int reviewerId;

  int revieweeId;

  /// 1 to 5.
  int rating;

  String? comment;

  DateTime createdAt;

  /// Returns a shallow copy of this [Review]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Review copyWith({
    int? id,
    int? listingId,
    int? reviewerId,
    int? revieweeId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Review',
      if (id != null) 'id': id,
      'listingId': listingId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Review',
      if (id != null) 'id': id,
      'listingId': listingId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReviewImpl extends Review {
  _ReviewImpl({
    int? id,
    required int listingId,
    required int reviewerId,
    required int revieweeId,
    required int rating,
    String? comment,
    DateTime? createdAt,
  }) : super._(
         id: id,
         listingId: listingId,
         reviewerId: reviewerId,
         revieweeId: revieweeId,
         rating: rating,
         comment: comment,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Review]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Review copyWith({
    Object? id = _Undefined,
    int? listingId,
    int? reviewerId,
    int? revieweeId,
    int? rating,
    Object? comment = _Undefined,
    DateTime? createdAt,
  }) {
    return Review(
      id: id is int? ? id : this.id,
      listingId: listingId ?? this.listingId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      comment: comment is String? ? comment : this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
