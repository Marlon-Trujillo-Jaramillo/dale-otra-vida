# Task: real-time chat (server only)

Scope: `dale_otra_vida_server/` only. Follow AGENTS.md (CLI `~/.pub-cache/bin/serverpod generate`;
no table model changes are needed, so no migration). Existing tables: `Conversation` (listingId,
ownerId, requesterId, lastMessageAt, lastMessagePreview; unique listingId+requesterId),
`ChatMessage` (conversationId, senderId? null = system, kind MessageKind{text, system,
safePointProposal}, text, createdAt, readAt?). Conversations are created by
`RequestEndpoint.create`. Reuse `currentProfile`, `toViews` (`lib/src/listings/listing_views.dart`)
and `notify`. Spanish error messages via `NotAllowedException`.

## New non-table model `lib/src/models/conversation_view.spy.yaml`
`ConversationView`: `conversation: Conversation`, `listing: ListingView`, `other: MemberProfile`
(public copy, no coordinates — same stripping as elsewhere), `isOwner: bool`, `unreadCount: int`
(messages from the other party with readAt null; system messages don't count),
`request: ListingRequest?` (the requester's request on that listing).

## Shared helper `lib/src/chat/chat_messages.dart`
- `Future<ChatMessage> insertChatMessage(Session, Conversation, {int? senderId, MessageKind kind,
  String text, Transaction? transaction})` — inserts the message and updates the conversation's
  `lastMessageAt`/`lastMessagePreview` (preview: system/text as is, safePointProposal →
  "📍 Punto propuesto: {text}", truncated to 120 chars).
- `Future<void> publishChatMessage(Session, Conversation, ChatMessage)` — call AFTER the
  transaction committed: `session.messages.postMessage('chat-{conversationId}', message)` and
  `postMessage('inbox-{ownerId}', message)` + `postMessage('inbox-{requesterId}', message)`.
- Refactor `RequestEndpoint.create` and `accept` to use `insertChatMessage` and publish after the
  transaction returns (keep behaviour and tests identical).

## `lib/src/chat/chat_endpoint.dart` — `ChatEndpoint`, `requireLogin`
A caller is a participant if their profile id is the conversation's ownerId or requesterId;
otherwise throw `NotAllowedException('No participas en esta conversación.')` (also when the
conversation doesn't exist).
1. `conversations() → List<ConversationView>` — caller's conversations (as owner or requester),
   `lastMessageAt` desc, max 100. Batched queries only: one `toViews` call, one query for the other
   members, one grouped count (or a single query) for unread, one for requests. No N+1.
2. `conversation(int conversationId) → ConversationView`.
3. `messages(int conversationId, {int? beforeId, int limit = 50}) → List<ChatMessage>` — newest
   first, clamp limit 1..100, `beforeId` = page cursor (id < beforeId), tiebreak by id desc.
4. `send(int conversationId, String text, {MessageKind kind = MessageKind.text}) → ChatMessage`
   - `kind` must be text or safePointProposal (system → NotAllowedException).
   - text trimmed, 1..1000 chars (else `NotAllowedException('El mensaje no puede estar vacío.')` /
     `'El mensaje es demasiado largo.'`).
   - If the listing is `withdrawn` or the requester's request is `rejected` →
     `NotAllowedException('Esta conversación está cerrada.')`.
   - Transaction: insert via helper. After commit: publish, then notify the other participant
     (kind newMessage, title "Nuevo mensaje de {nombre}", body = preview, refId = conversationId)
     ONLY if they have no unread newMessage notification with that refId already (avoid spam).
5. `markRead(int conversationId) → void` — set readAt=now on the other party's unread messages
   (single `updateWhere`), and mark the caller's unread newMessage notifications with
   refId = conversationId as read.
6. `unreadTotal() → int` — total unread messages across the caller's conversations (for the
   Mensajes tab badge).
7. Streaming: `Stream<ChatMessage> subscribe(int conversationId)` — check participation first, then
   return `session.messages.createStream<ChatMessage>('chat-$conversationId')`.
   `Stream<ChatMessage> inbox()` — `createStream<ChatMessage>('inbox-{callerProfileId}')`.
   Use Serverpod 4 streaming method semantics (return type `Stream<T>`; read
   `~/.pub-cache/hosted/pub.dev/serverpod-4.0.4/lib/src/server/session.dart` and the
   serverpod_test docs for how streams are tested).

## Tests `test/integration/chat_endpoint_test.dart`
Setup like request tests (owner, requester, a third member, create a request to get a
conversation). Cover: conversations lists it for both sides with correct `other`, `isOwner`,
`unreadCount`, `request`; third member gets [] and NotAllowedException on conversation/messages/
send/markRead/subscribe. send: trims, rejects empty/too long/system kind, updates preview
(safePointProposal prefix), closed conversation (withdrawn listing, rejected request) throws.
Notification de-dup: two sends → one unread newMessage notification for the other party.
messages paging with beforeId + limit. markRead clears unreadCount and the notification;
unreadTotal. Streams: subscribe receives a message sent afterwards (use the serverpod_test stream
support; take(1) with a timeout); inbox of the other participant receives it too. Existing tests
stay green.

## Acceptance
`dart format lib test`, `dart analyze` zero issues, `dart test` all green (existing 90 too).
Run `serverpod generate` so the client gets `client.chat.*`. No commits, don't start the server,
don't touch the Flutter app.
