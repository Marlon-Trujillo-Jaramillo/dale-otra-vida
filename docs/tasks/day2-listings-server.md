# Task: listings backend (server only)

Scope: `dale_otra_vida_server/` only. Models already exist in `lib/src/models/` (Listing,
MemberProfile, enums). Do NOT change existing `.spy.yaml` models unless listed below. Follow
AGENTS.md (server not running: use the CLI fallback `~/.pub-cache/bin/serverpod generate`;
create a migration only if a model changes). Reuse `roundCoordinate` from
`lib/src/profile/profile_endpoint.dart` (move it to `lib/src/common/geo.dart` and import it from
both places).

## New model (non-table) `lib/src/models/listing_view.spy.yaml`
`ListingView` — what the app renders in lists and detail:
- `listing: Listing` (with `photoUrls` already resolved to full download URLs, see Photos)
- `owner: MemberProfile` (public copy: latitude/longitude set to null)
- `distanceKm: double?` (null when the caller has no location)
- `isMine: bool`

## `lib/src/common/geo.dart`
- `roundCoordinate(double?)` (moved).
- `double haversineKm(double lat1, double lon1, double lat2, double lon2)`.

## `lib/src/listings/listing_endpoint.dart` — `ListingEndpoint`, `requireLogin => true`
Helper: `_currentProfile(session)` → the caller's `MemberProfile` (by `authUserId`, import
`package:serverpod_auth_idp_server/core.dart` for the `authUserId` getter); throws
`ProfileRequiredException` (new serializable exception model, field `message: String`) if none.

1. `Future<String> photoUploadDescription(Session session, String fileExtension)`
   - Allowed extensions: `jpg`, `jpeg`, `png`, `webp` (case-insensitive) else `ArgumentError`.
   - Path is derived server-side: `listings/{profileId}/{UUID v4}.{ext}`. Return a record-like
     model `PhotoUpload { path: String, uploadDescription: String }` (new non-table model) using
     `session.storage.createUploadDescription(storageId: 'public', path: path)`.
     Change the return type accordingly: `Future<PhotoUpload>`.
2. `Future<bool> verifyPhotoUpload(Session session, String path)` — path must start with
   `listings/{callerProfileId}/` else `false`; returns `session.storage.verifyUpload(...)`.
3. `Future<ListingView> create(Session session, Listing listing)` — server-controlled fields:
   ignore client `id`, `ownerId`, `status`, `createdAt`, `updatedAt`; set ownerId = caller,
   status = available, timestamps = now. Validation (throw `ArgumentError` with a Spanish
   message):
   - title 3–80 chars (trimmed), description 10–1000 chars (trimmed), neighborhood 2–60.
   - photoUrls: 1–5 entries, each a storage path starting with `listings/{callerProfileId}/`
     and existing in storage (`session.storage.fileExists`).
   - category food ⇒ `expiresAt` required and in the future.
   - type sell ⇒ `price` required, 1..100000000; other types ⇒ price must be null.
   - type lend ⇒ `returnDate` required and in the future; other types ⇒ null.
   - type exchange ⇒ `wantedInExchange` required 3–200 chars; other types ⇒ null.
   - latitude in [-90, 90], longitude in [-180, 180]; store rounded with `roundCoordinate`.
4. `Future<List<ListingView>> feed(Session session, {ListingType? type, Category? category,
   String? query, double? latitude, double? longitude, int limit = 20, int offset = 0})`
   - Only `status == available`, excluding food whose `expiresAt` is in the past.
   - `query`: case-insensitive match on title OR description (`ilike '%q%'`), trimmed, ignore
     if empty.
   - Sort: newest first. When latitude/longitude are given, compute `distanceKm` for each row
     (haversine) — keep newest-first ordering (distance sort comes on day 6 with the map).
   - `limit` clamped to 1..50, `offset` >= 0. Include the caller's own listings (`isMine`).
5. `Future<ListingView?> byId(Session session, int id, {double? latitude, double? longitude})`
   - Returns any status (detail page must show reserved/delivered), null if not found.
6. `Future<List<ListingView>> mine(Session session)` — caller's listings, all statuses,
   newest first.
7. `Future<ListingView> updateStatus(Session session, int id, ListingStatus status)` — only
   the owner; allowed transitions: available→reserved, reserved→available,
   reserved→delivered, available|reserved→withdrawn. Anything else `ArgumentError`. Not owner
   ⇒ throw `NotAllowedException` (new serializable exception, `message: String`). Updates
   `updatedAt`. When moving to delivered, increment owner's `deliveryCount`.

## Photos
Store storage paths in `Listing.photoUrls`. When building a `ListingView`, replace each path
with `session.storage.publicDownloadUrl(storageId: 'public', path: path)` (`toString()`), in a
single helper `_toView(session, listing, caller, {lat, lng})`. Batch-load owners with one query
(`MemberProfile.db.find(where: id.inSet(...))`), not one query per listing.

## Tests `test/integration/listing_endpoint_test.dart`
Use the same pattern as `test/integration/profile_endpoint_test.dart` (insert `AuthUser`
directly, then `saveMe`). Storage in tests: write files with
`session.storage.storeFile(storageId: 'public', path: ..., byteData: ...)` through a
`sessionBuilder.build()` session to simulate uploads. Cover at least:
- create succeeds for each type with valid fields; ownerId/status are server-set.
- create rejects: missing photo, foreign photo path, food without expiresAt, sell without
  price, price on donate, lend without returnDate, exchange without wantedInExchange.
- feed filters by type, category and query; excludes withdrawn/delivered and expired food;
  pagination works; distanceKm present only when coordinates are passed.
- byId returns owner without coordinates and resolved photo URLs.
- updateStatus: owner transitions ok; invalid transition throws; non-owner throws
  NotAllowedException; delivered increments deliveryCount.
- photoUploadDescription rejects `.exe`; verifyPhotoUpload rejects another member's path.
- calls without a profile throw ProfileRequiredException.

## Acceptance
In `dale_otra_vida_server/`: `dart format lib test`, `dart analyze` zero issues, `dart test`
all green (including existing profile tests). No commits. Report files changed and results.
