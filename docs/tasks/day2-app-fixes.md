# Task: day 2 app review fixes

Scope: `dale_otra_vida_flutter/` only. Fix every item; add tests where marked (T).

## High
1. publish_screen: thumbnails use `Image.network(upload.path!)` with a storage path. Always show
   the local file: `Image.file(File(upload.filePath), fit: BoxFit.cover)`.
2. publish_screen: stale conditional fields. When building `Listing`, send `price` only if type
   == sell, `returnDate` only if lend, `wantedInExchange` only if exchange, `expiresAt` only if
   category == food. Also clear them in the draft when type/category changes. (T: draft →
   Listing mapping function `draft.toListing(...)` in listing_draft.dart, test that switching
   sell→donate drops price, etc.)
3. listing_detail_screen owner actions follow allowed transitions: available → [Reservar,
   Retirar]; reserved → [Marcar disponible, Marcar entregado, Retirar]; delivered/withdrawn →
   no actions (show the status banner only). Lay out actions as a Column of full-width buttons
   (primary for the main action, secondary for others, "Retirar" as a danger text button with
   confirm dialog). Extract `allowedOwnerActions(ListingStatus)` as a pure function (T).
4. home_controller: request-generation guard. `int _gen`; every load (`refresh`, filter change,
   search, `loadMore`) captures `final gen = ++_gen` (loadMore must not bump if a refresh is in
   flight — skip loadMore while refreshing); after each await `if (gen != _gen || _disposed)
   return;`; only clear loading flags when `gen == _gen`. Add `_disposed` set in `dispose()` and
   guard `notifyListeners`. (T: unit test with a fake fetch function injected into the
   controller: older slower response must not overwrite newer one.) Make the fetch function
   injectable via constructor (default uses `client.listing.feed`).
5. home: a failed `loadMore` sets `loadMoreError` (separate from the full-page `error`), stops
   auto-retrying, and shows a "No pudimos cargar más · Reintentar" row at the list end.
6. app_shell: FAB covers "Mensajes". Use a `BottomAppBar` (primary color, `CircularNotchedRectangle`,
   notchMargin 6) with 4 slots: Inicio, Mensajes, [gap for FAB], Perfil — and
   `FloatingActionButtonLocation.centerDocked`. Keep the prototype look (labels under icons,
   selected onPrimary, unselected 60%). Every tab tappable with ≥48dp targets.

## Medium
7. core/location.dart: whole function in try/catch returning null; share one in-flight Future
   so concurrent callers don't both request permission; use `LocationSettings(accuracy: low,
   timeLimit: Duration(seconds: 8))` instead of `.timeout`.
8. publish_screen: `if (!mounted) return;` after every await (`_uploadPhoto`, `_getLocation`,
   `_pickPhoto`, `_submit`).
9. listing_detail_screen: `mounted` checks after `updateStatus`; `finally` must not setState when
   unmounted. Detail pops with `true` when the listing changed; home `_openDetail` awaits the
   push and refreshes when `true`. Preserve `distanceKm` from the previous view after an update.
10. publish: Publicar disabled while any photo is uploading or failed (show "Esperando que
    terminen de subir las fotos" / "Quita o reintenta las fotos con error"). `if (_submitting)
    return;` at the top of `_submit`.
11. listing_draft validation mirrors the server: neighborhood 2–60, safeMeetingPoint ≤120,
    wantedInExchange 3–200, price 1..100000000, photos 1–5; dates must be after today. Add
    `maxLength` to those fields. (T: extend publish_validation_test.)
12. `_CopInputFormatter`: `int.tryParse`, cap at 9 digits, never throw. (T)
13. format.dart: format dates with `.toLocal()`. (T: a UTC 02:00 timestamp shows the previous
    day in UTC-5 — use a fixed DateTime and compare against `toLocal()` output.)
14. Expiry display: show expiry when `expiresAt != null` (food), independent of type; the
    type-specific info card/meta is: sell price, lend return date, exchange wanted, donate →
    nothing extra (unless food expiry). Apply in detail screen and ListingCard meta.
15. home: `SliverFillRemaining(hasScrollBody: false)` for empty/error states.
16. home categories grid: `childAspectRatio: 0.85`, check no overflow at 360dp width.

## Low
17. (covered by 3)
18. Image compression: compute target size so the longest side is ≤1600 (pass minWidth/minHeight
    scaled from the original aspect ratio, or use `CompressFormat.jpeg` with a resize helper).
19. `_initials`: safe for empty names (fallback "?"). Move to a shared helper in
    `lib/core/format.dart` and reuse from AppAvatar callers. (T)

## Acceptance
`dart format lib test`, `flutter analyze` zero issues, `flutter test` green. Add a widget test
that pumps `AppShell` bottom bar at 360×640 and taps "Mensajes" successfully (tab switches) —
inject/fake whatever the shell needs from `client` (e.g. allow passing an initial profile).
No commits; don't edit the client package or the server.
