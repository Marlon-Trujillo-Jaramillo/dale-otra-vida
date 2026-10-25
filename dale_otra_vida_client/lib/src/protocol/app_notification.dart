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
import 'notification_kind.dart' as _ipnxo26v;

abstract class AppNotification
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AppNotification._({
    this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    this.refId,
    this.readAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification({
    int? id,
    required int userId,
    required _ipnxo26v.NotificationKind kind,
    required String title,
    required String body,
    int? refId,
    DateTime? readAt,
    DateTime? createdAt,
  }) = _AppNotificationImpl;

  factory AppNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppNotification(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      kind: _ipnxo26v.NotificationKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      refId: jsonSerialization['refId'] as int?,
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  _ipnxo26v.NotificationKind kind;

  String title;

  String body;

  /// Id of the related listing, request or conversation, depending on [kind].
  int? refId;

  DateTime? readAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [AppNotification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AppNotification copyWith({
    int? id,
    int? userId,
    _ipnxo26v.NotificationKind? kind,
    String? title,
    String? body,
    int? refId,
    DateTime? readAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppNotification',
      if (id != null) 'id': id,
      'userId': userId,
      'kind': kind.toJson(),
      'title': title,
      'body': body,
      if (refId != null) 'refId': refId,
      if (readAt != null) 'readAt': readAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AppNotification',
      if (id != null) 'id': id,
      'userId': userId,
      'kind': kind.toJson(),
      'title': title,
      'body': body,
      if (refId != null) 'refId': refId,
      if (readAt != null) 'readAt': readAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppNotificationImpl extends AppNotification {
  _AppNotificationImpl({
    int? id,
    required int userId,
    required _ipnxo26v.NotificationKind kind,
    required String title,
    required String body,
    int? refId,
    DateTime? readAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         kind: kind,
         title: title,
         body: body,
         refId: refId,
         readAt: readAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AppNotification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AppNotification copyWith({
    Object? id = _Undefined,
    int? userId,
    _ipnxo26v.NotificationKind? kind,
    String? title,
    String? body,
    Object? refId = _Undefined,
    Object? readAt = _Undefined,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      refId: refId is int? ? refId : this.refId,
      readAt: readAt is DateTime? ? readAt : this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
