# Task: "Lo quiero" requests + notifications (server only)

Scope: `dale_otra_vida_server/` only. Models exist: `ListingRequest` (listingId, requesterId,
message?, status RequestStatus{pending, accepted, rejected, cancelled}, createdAt; unique
listingId+requesterId), `Conversation`, `ChatMessage` (kind MessageKind{text, system,
safePointProposal}), `AppNotification` (userId, kind NotificationKind{newRequest,
requestAccepted, requestRejected, newMessage, newReview, listingExpiring}, title, body, refId,
readAt). Follow AGENTS.md (CLI fallback `~/.pub-cache/bin/serverpod generate`; create a
migration only if a table model changes). Reuse `_currentProfile`-style helper: extract it to
`lib/src/common/current_profile.dart` (`Future<MemberProfile> currentProfile(Session)` throwing
`ProfileRequiredException`) and use it from ListingEndpoint too.

## Model changes (non-breaking: only nullable/defaulted additions)
- `ListingView`: add `myRequest: ListingRequest?` (the caller's request on that listing, any
  status) and `pendingRequestCount: int, default=0` (only filled when `isMine`, else 0).
- New non-table `RequestView`: `request: ListingRequest`, `requester: MemberProfile` (public
  copy, no coordinates), `conversationId: int?`.
- New non-table `MyRequestView`: `request: ListingRequest`, `listing: ListingView`,
  `conversationId: int?`.

## `lib/src/requests/request_endpoint.dart` — `RequestEndpoint`, `requireLogin`
All mutations run in `session.db.transaction`.
1. `create(int listingId, {String? message}) → ListingRequest`
   - listing must exist and be `available`, caller must not be the owner
     (`NotAllowedException('No puedes pedir tu propia publicación.')`).
   - message trimmed, empty → null, max 300.
   - Existing row for (listing, caller): pending/accepted → return it unchanged; cancelled →
     set back to pending (+ new createdAt); rejected → `NotAllowedException('El dueño ya
     respondió a tu solicitud.')`.
   - Ensure a `Conversation` (listing, owner, requester) exists (create if missing). Insert a
     system `ChatMessage` "{nombre} quiere esta publicación." (+ the message text as a normal
     `text` message from the requester if provided) and update `lastMessageAt/Preview`.
   - Notify the owner: kind newRequest, title "Nueva solicitud", body "{nombre} quiere
     «{título}»", refId = listing id.
2. `forListing(int listingId) → List<RequestView>` — owner only (else NotAllowedException);
   all statuses, pending first then newest first; include conversationId.
3. `mine() → List<MyRequestView>` — caller's requests, newest first, with the listing view
   (photo URLs resolved, owner public) — reuse ListingEndpoint's view builder by extracting it
   to `lib/src/listings/listing_views.dart`.
4. `accept(int requestId) → ListingRequest` — owner only; request must be pending and listing
   available. Request → accepted, listing → reserved (+updatedAt), every other pending request
   on that listing → rejected. Notifications: requester gets requestAccepted ("¡Te lo
   reservaron!", "Coordina la entrega de «{título}» por el chat."), each auto-rejected
   requester gets requestRejected ("Solicitud no disponible", "«{título}» fue reservado para
   otra persona."). System chat message in the accepted conversation: "{dueño} reservó esta
   publicación para ti. Acuerden un punto de encuentro seguro."
5. `reject(int requestId) → ListingRequest` — owner only; pending → rejected; notify
   requester (requestRejected, "Solicitud rechazada", "El dueño eligió a otra persona para
   «{título}».").
6. `cancel(int requestId) → ListingRequest` — requester only; pending → cancelled; accepted →
   cancelled AND listing reserved → available. Notify owner only when it was accepted (kind
   newRequest is wrong — add enum value `requestCancelled` to NotificationKind; enums are not
   tables, adding a value at the end is safe).

## ListingEndpoint adjustments
- `updateStatus` reserved → available: the accepted request (if any) becomes `cancelled` and
  its requester is notified (requestCancelled, "Reserva cancelada", "El dueño volvió a publicar
  «{título}».").
- `updateStatus` → withdrawn: all pending/accepted requests → cancelled (no notifications
  needed).
- `byId`, `feed`, `mine`: fill `myRequest` (one batched query for the caller's requests on the
  returned listing ids) and `pendingRequestCount` for own listings (one grouped/batched query).

## `lib/src/notifications/notification_endpoint.dart` — `NotificationEndpoint`, requireLogin
- `list({int limit = 30, int offset = 0}) → List<AppNotification>` newest first, clamp limit
  1..50; only the caller's.
- `unreadCount() → int`.
- `markRead(int id) → void` (only own; silently ignore others), `markAllRead() → void`.
- Notification creation lives in `lib/src/notifications/notify.dart`
  (`Future<void> notify(Session, {required int userId, kind, title, body, refId, Transaction?})`).

## Tests (`test/integration/request_endpoint_test.dart`, `notification_endpoint_test.dart`)
Cover: create (happy path creates conversation + system message + owner notification); own
listing rejected; non-available listing rejected; duplicate create returns same row; cancelled
then create reopens; rejected then create throws. forListing owner-only. accept reserves the
listing, rejects other pending, notifies all; accept on non-pending throws; non-owner accept
throws. reject/cancel rules (cancel accepted frees the listing). updateStatus reserved→available
cancels accepted request; withdrawn cancels all. ListingView.myRequest and pendingRequestCount
populated. Notifications: list only own, unreadCount, markRead ignores others, markAllRead.

## Acceptance
`dart format lib test`, `dart analyze` zero issues, `dart test` all green (existing 43 too).
No commits, don't start the server, don't touch the Flutter app.
