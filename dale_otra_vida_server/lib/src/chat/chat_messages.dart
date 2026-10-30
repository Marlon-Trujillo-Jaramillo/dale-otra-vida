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
    // Only these columns, so a stale copy never rolls other fields back.
    columns: (t) => [t.lastMessageAt, t.lastMessagePreview],
    transaction: transaction,
  );
  return message;
}

/// Streams [message] to the conversation and to both participants' inboxes.
///
/// The message is already stored, so a failed broadcast is only logged:
/// clients catch up when they reload, and the caller must not retry.
Future<void> publishChatMessage(
  Session session,
  Conversation conversation,
  ChatMessage message,
) async {
  try {
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
  } catch (e, stackTrace) {
    session.log(
      'Could not broadcast chat message ${message.id}',
      level: LogLevel.warning,
      exception: e,
      stackTrace: stackTrace,
    );
  }
}

/// Unread messages from the other participant per conversation id, counted
/// in the database.
Future<Map<int, int>> unreadCounts(
  Session session,
  int profileId,
  Set<int> conversationIds,
) async {
  if (conversationIds.isEmpty) return {};
  final rows = await session.db.unsafeQuery(
    'SELECT "conversationId", count(*) FROM chat_message '
    'WHERE "conversationId" = ANY(@ids) AND "senderId" IS NOT NULL '
    'AND "senderId" <> @me AND "readAt" IS NULL '
    'GROUP BY "conversationId"',
    parameters: QueryParametersNamed({
      'ids': conversationIds.toList(),
      'me': profileId,
    }),
  );
  return {for (final row in rows) row[0] as int: row[1] as int};
}

/// Unread messages from others across every conversation of [profileId].
Future<int> unreadTotalFor(Session session, int profileId) async {
  final rows = await session.db.unsafeQuery(
    'SELECT count(*) FROM chat_message m '
    'JOIN conversation c ON c.id = m."conversationId" '
    'WHERE (c."ownerId" = @me OR c."requesterId" = @me) '
    'AND m."senderId" IS NOT NULL AND m."senderId" <> @me '
    'AND m."readAt" IS NULL',
    parameters: QueryParametersNamed({'me': profileId}),
  );
  return rows.first[0] as int;
}
