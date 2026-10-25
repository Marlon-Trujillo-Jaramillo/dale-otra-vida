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

/// Chat between a listing owner and one interested user.
abstract class Conversation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Conversation._({
    this.id,
    required this.listingId,
    required this.ownerId,
    required this.requesterId,
    DateTime? lastMessageAt,
    this.lastMessagePreview,
  }) : lastMessageAt = lastMessageAt ?? DateTime.now();

  factory Conversation({
    int? id,
    required int listingId,
    required int ownerId,
    required int requesterId,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
  }) = _ConversationImpl;

  factory Conversation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Conversation(
      id: jsonSerialization['id'] as int?,
      listingId: jsonSerialization['listingId'] as int,
      ownerId: jsonSerialization['ownerId'] as int,
      requesterId: jsonSerialization['requesterId'] as int,
      lastMessageAt: jsonSerialization['lastMessageAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastMessageAt'],
            ),
      lastMessagePreview: jsonSerialization['lastMessagePreview'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int listingId;

  int ownerId;

  int requesterId;

  DateTime lastMessageAt;

  String? lastMessagePreview;

  /// Returns a shallow copy of this [Conversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Conversation copyWith({
    int? id,
    int? listingId,
    int? ownerId,
    int? requesterId,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Conversation',
      if (id != null) 'id': id,
      'listingId': listingId,
      'ownerId': ownerId,
      'requesterId': requesterId,
      'lastMessageAt': lastMessageAt.toJson(),
      if (lastMessagePreview != null) 'lastMessagePreview': lastMessagePreview,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Conversation',
      if (id != null) 'id': id,
      'listingId': listingId,
      'ownerId': ownerId,
      'requesterId': requesterId,
      'lastMessageAt': lastMessageAt.toJson(),
      if (lastMessagePreview != null) 'lastMessagePreview': lastMessagePreview,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConversationImpl extends Conversation {
  _ConversationImpl({
    int? id,
    required int listingId,
    required int ownerId,
    required int requesterId,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
  }) : super._(
         id: id,
         listingId: listingId,
         ownerId: ownerId,
         requesterId: requesterId,
         lastMessageAt: lastMessageAt,
         lastMessagePreview: lastMessagePreview,
       );

  /// Returns a shallow copy of this [Conversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Conversation copyWith({
    Object? id = _Undefined,
    int? listingId,
    int? ownerId,
    int? requesterId,
    DateTime? lastMessageAt,
    Object? lastMessagePreview = _Undefined,
  }) {
    return Conversation(
      id: id is int? ? id : this.id,
      listingId: listingId ?? this.listingId,
      ownerId: ownerId ?? this.ownerId,
      requesterId: requesterId ?? this.requesterId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview is String?
          ? lastMessagePreview
          : this.lastMessagePreview,
    );
  }
}
