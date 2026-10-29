import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Channel that streams the messages of one conversation.
String chatChannel(int conversationId) => 'chat-$conversationId';

/// Channel that streams every message addressed to one member.
String inboxChannel(int profileId) => 'inbox-$profileId';

/// Short text shown in the conversation list for [message].
String messagePreview(MessageKind kind, String text) {
  final preview = kind == MessageKind.safePointProposal
      ? '📍 Punto propuesto: $text'
      : text;
  return preview.length <= 120 ? preview : '${preview.substring(0, 119)}…';
}

/// Inserts a message in [conversation] and updates its last message.
///
/// Call [publishChatMessage] once the surrounding transaction committed.
Future<ChatMessage> insertChatMessage(
  Session session,
  Conversation conversation, {
  int? senderId,
  MessageKind kind = MessageKind.text,
  required String text,
  DateTime? createdAt,
  Transaction? transaction,
}) async {
  final message = await ChatMessage.db.insertRow(
    session,
    ChatMessage(
      conversationId: conversation.id!,
      senderId: senderId,
      kind: kind,
      text: text,
      createdAt: createdAt ?? DateTime.now().toUtc(),
    ),
    transaction: transaction,
  );
  await Conversation.db.updateRow(
    session,
    conversation.copyWith(
      lastMessageAt: message.createdAt,
      lastMessagePreview: messagePreview(kind, text),
    ),
    transaction: transaction,
  );
  return message;
}

/// Streams [message] to the conversation and to both participants' inboxes.
Future<void> publishChatMessage(
  Session session,
  Conversation conversation,
  ChatMessage message,
) async {
  await session.messages.postMessage(
    chatChannel(conversation.id!),
    message,
  );
  await session.messages.postMessage(
    inboxChannel(conversation.ownerId),
    message,
  );
  await session.messages.postMessage(
    inboxChannel(conversation.requesterId),
    message,
  );
}
