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

/// Opinion a tester sends from the app.
abstract class AppFeedback
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppFeedback._({
    this.id,
    required this.profileId,
    this.rating,
    required this.message,
    this.screen,
    this.platform,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppFeedback({
    int? id,
    required int profileId,
    int? rating,
    required String message,
    String? screen,
    String? platform,
    DateTime? createdAt,
  }) = _AppFeedbackImpl;

  factory AppFeedback.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppFeedback(
      id: jsonSerialization['id'] as int?,
      profileId: jsonSerialization['profileId'] as int,
      rating: jsonSerialization['rating'] as int?,
      message: jsonSerialization['message'] as String,
      screen: jsonSerialization['screen'] as String?,
      platform: jsonSerialization['platform'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int profileId;

  /// 1 (very bad) to 5 (very good), optional.
  int? rating;

  String message;

  /// Where the tester was, e.g. "perfil" or "chat".
  String? screen;

  /// "web", "android" or "ios".
  String? platform;

  DateTime createdAt;

  /// Returns a shallow copy of this [AppFeedback]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppFeedback copyWith({
    int? id,
    int? profileId,
    int? rating,
    String? message,
    String? screen,
    String? platform,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppFeedback',
      if (id != null) 'id': id,
      'profileId': profileId,
      if (rating != null) 'rating': rating,
      'message': message,
      if (screen != null) 'screen': screen,
      if (platform != null) 'platform': platform,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppFeedback',
      if (id != null) 'id': id,
      'profileId': profileId,
      if (rating != null) 'rating': rating,
      'message': message,
      if (screen != null) 'screen': screen,
      if (platform != null) 'platform': platform,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppFeedbackImpl extends AppFeedback {
  _AppFeedbackImpl({
    int? id,
    required int profileId,
    int? rating,
    required String message,
    String? screen,
    String? platform,
    DateTime? createdAt,
  }) : super._(
         id: id,
         profileId: profileId,
         rating: rating,
         message: message,
         screen: screen,
         platform: platform,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AppFeedback]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppFeedback copyWith({
    Object? id = _Undefined,
    int? profileId,
    Object? rating = _Undefined,
    String? message,
    Object? screen = _Undefined,
    Object? platform = _Undefined,
    DateTime? createdAt,
  }) {
    return AppFeedback(
      id: id is int? ? id : this.id,
      profileId: profileId ?? this.profileId,
      rating: rating is int? ? rating : this.rating,
      message: message ?? this.message,
      screen: screen is String? ? screen : this.screen,
      platform: platform is String? ? platform : this.platform,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
