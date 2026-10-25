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
import 'message_kind.dart' as _ibvtcu73;

abstract class ChatMessage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ChatMessage._({
    this.id,
    required this.conversationId,
    this.senderId,
    _ibvtcu73.MessageKind? kind,
    required this.text,
    DateTime? createdAt,
    this.readAt,
  }) : kind = kind ?? _ibvtcu73.MessageKind.text,
       createdAt = createdAt ?? DateTime.now();

  factory ChatMessage({
    int? id,
    required int conversationId,
    int? senderId,
    _ibvtcu73.MessageKind? kind,
    required String text,
    DateTime? createdAt,
    DateTime? readAt,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] as int?,
      conversationId: jsonSerialization['conversationId'] as int,
      senderId: jsonSerialization['senderId'] as int?,
      kind: jsonSerialization['kind'] == null
          ? null
          : _ibvtcu73.MessageKind.fromJson(
              (jsonSerialization['kind'] as String),
            ),
      text: jsonSerialization['text'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int conversationId;

  /// Null for system messages.
  int? senderId;

  _ibvtcu73.MessageKind kind;

  String text;

  DateTime createdAt;

  DateTime? readAt;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ChatMessage copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    _ibvtcu73.MessageKind? kind,
    String? text,
    DateTime? createdAt,
    DateTime? readAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id,
      'conversationId': conversationId,
      if (senderId != null) 'senderId': senderId,
      'kind': kind.toJson(),
      'text': text,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id,
      'conversationId': conversationId,
      if (senderId != null) 'senderId': senderId,
      'kind': kind.toJson(),
      'text': text,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required int conversationId,
    int? senderId,
    _ibvtcu73.MessageKind? kind,
    required String text,
    DateTime? createdAt,
    DateTime? readAt,
  }) : super._(
         id: id,
         conversationId: conversationId,
         senderId: senderId,
         kind: kind,
         text: text,
         createdAt: createdAt,
         readAt: readAt,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    int? conversationId,
    Object? senderId = _Undefined,
    _ibvtcu73.MessageKind? kind,
    String? text,
    DateTime? createdAt,
    Object? readAt = _Undefined,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId is int? ? senderId : this.senderId,
      kind: kind ?? this.kind,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
    );
  }
}
