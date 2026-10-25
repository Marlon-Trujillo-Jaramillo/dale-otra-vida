# Task: "Lo quiero", owner requests, my requests and notifications (Flutter app)

Scope: `dale_otra_vida_flutter/` only. Respect the responsive layouts (compact/medium/expanded
in `lib/core/layout/breakpoints.dart`) — mobile must keep the prototype look. Spanish copy.
Generated API (read `dale_otra_vida_client`, never edit it):
`client.request.create(listingId, message:)`, `forListing(listingId)` → `List<RequestView>`,
`mine()` → `List<MyRequestView>`, `accept(id)`, `reject(id)`, `cancel(id)`;
`client.notification.list(limit:, offset:)`, `unreadCount()`, `markRead(id)`, `markAllRead()`.
`ListingView` now has `myRequest` (ListingRequest?) and `pendingRequestCount` (int).
Map `NotAllowedException.message` to a SnackBar (it is already Spanish).

## Listing detail — requester side (not `isMine`)
Bottom action area (compact: sticky bar; wide: inline in the info column):
- No request / cancelled → primary "Lo quiero" → bottom sheet (compact) or dialog (wide):
  title "¿Te interesa «{título}»?", optional message field ("Cuéntale cuándo podrías
  recogerlo…", max 300), safety tip card ("Por tu seguridad, acuerden la entrega en un punto
  público y no compartan datos bancarios." — same style as the chat banner in the prototype),
  primary "Enviar solicitud". On success: refresh the view, SnackBar "¡Solicitud enviada!".
- pending → disabled-looking status pill "Solicitud enviada · esperando respuesta" + text
  button "Cancelar solicitud" (confirm dialog).
- accepted → highlighted card (verified green tint) "¡Te lo reservaron!" + caption "Coordina la
  entrega por el chat." + secondary "Cancelar reserva" (confirm).
- rejected → muted pill "El dueño eligió a otra persona".
- Listing not available and no accepted request of mine → existing status banner, no actions.
- Chat icon button stays (chat arrives on day 4: keep the "Disponible muy pronto" SnackBar).

## Listing detail — owner side (`isMine`)
- New section "Solicitudes" (badge with `pendingRequestCount`) loading `forListing`:
  each row = AppAvatar + name + "★ rating · n entregas" + optional quoted message (2 lines) +
  relative time ("hace 5 min", add `formatRelative` to `lib/core/format.dart` with tests) +
  status chip. Pending rows show "Aceptar" (primary small) and "Rechazar" (text) — accept asks
  for confirmation "Se reservará para {nombre} y las demás solicitudes se rechazarán.".
- Empty: "Aún nadie la ha pedido. Comparte tu publicación." 
- After accept/reject/cancel actions, refresh both the requests list and the listing view
  (status changes to reserved) and pop with `true` when leaving so home refreshes.
- Existing owner actions (Reservar/Disponible/Entregado/Retirar) stay; "Reservar" manually is
  still allowed.

## "Mis solicitudes" (`lib/features/requests/my_requests_screen.dart`)
Reached from the Perfil tab (a list tile "Mis solicitudes" with count) — Perfil is still mostly a
placeholder (full profile is day 5): add a simple header (avatar, name, barrio) + tiles
"Mis publicaciones" (uses `client.listing.mine()`, grid/list like home) and "Mis solicitudes",
plus the existing "Cerrar sesión".
- List of `MyRequestView` using the listing card (compact list / wide grid) with a status chip
  overlay: Pendiente (amber), Reservado para ti (green), No disponible (grey), Cancelada.
  Tap → listing detail.

## Notifications (`lib/features/notifications/notifications_screen.dart`)
Replace the placeholder opened from the bell (home header on compact, top bar on expanded).
- List newest first with icon per kind (newRequest: hand, requestAccepted: check, rejected /
  cancelled: info, newMessage: chat bubble), title bold if unread, body, relative time.
  Unread rows have a subtle `categoryCircle` background. Tap → markRead + navigate: listing
  kinds → listing detail (refId); newMessage → keep SnackBar until chat exists.
- App bar action "Marcar todo como leído". Pull to refresh, infinite scroll (page 30),
  EmptyState "No tienes notificaciones" with bell icon.
- Unread badge: small accent dot with count (max "9+") on the bell in home header (compact),
  top bar (expanded) and rail (medium). Poll `unreadCount()` every 30 s while the shell is
  visible (Timer, cancelled on dispose) and refresh after returning from the notifications
  screen. Put this in a `NotificationsBadgeController extends ChangeNotifier` in
  `lib/features/notifications/` with an injectable fetch function (testable).

## Tests
- `formatRelative` unit tests (ahora, hace 5 min, hace 2 h, ayer, fecha).
- Pure function `requesterActionState(ListingView)` → enum {canRequest, pending, accepted,
  rejected, unavailable} with tests for every case.
- NotificationsBadgeController test with a fake fetch (count, "9+" label, dispose cancels the
  timer).
- Existing tests stay green.

## Acceptance
`dart format lib test`, `flutter analyze` zero issues, `flutter test` green. No commits, don't
edit the client package or the server, don't start the server.
