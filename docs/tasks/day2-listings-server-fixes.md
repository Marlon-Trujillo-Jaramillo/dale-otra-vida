# Task: listings backend review fixes

Scope: `dale_otra_vida_server/lib/src/listings/listing_endpoint.dart`,
`lib/src/common/geo.dart`, `lib/src/profile/profile_endpoint.dart`, and tests in
`test/integration/`. Do NOT change any endpoint method signature or model (the Flutter app is
being built against the current API in parallel).

1. `feed()`: clamp instead of throwing — `limit = limit.clamp(1, 50)`, `offset = max(0, offset)`.
2. Coordinates: add `bool isValidCoordinate(double lat, double lng)` in geo.dart (finite and in
   range). `create`: reject invalid with ArgumentError. `feed`/`byId`: ignore invalid
   coordinates (treat as not provided, no distance). `saveMe`: if either is given, both must be
   given and valid, else ArgumentError.
3. Photo paths: one helper `bool isOwnPhotoPath(String path, int profileId)` using
   `RegExp('^listings/$profileId/[0-9a-f-]{36}\\.(jpg|jpeg|png|webp)\$')`. Use it in `create`
   (each path) and `verifyPhotoUpload`. `create` also rejects duplicate paths in the list.
4. `updateStatus`: run inside `session.db.transaction((transaction) async { ... })`: re-read the
   listing in the transaction, check owner + transition, update the listing, and when moving to
   delivered re-read the owner profile in the transaction and update only `deliveryCount` with
   `MemberProfile.db.updateRow(..., columns: (t) => [t.deliveryCount], transaction: ...)`
   (or the Serverpod 4 equivalent for updating specific columns — check the ORM API).
5. Input limits: `safeMeetingPoint` trimmed, empty → null, max 120 chars; feed `query` trimmed,
   max 80 chars (truncate); `saveMe` neighborhood trimmed, empty → null, max 60.
6. `query` wildcards: escape `\`, `%`, `_` before building the `ilike` pattern.
7. Ordering: add `id desc` as a tiebreaker after `createdAt desc` in `feed` and `mine`.
8. `haversineKm`: clamp the intermediate `a` to [0, 1].
9. Merge `_toView`/`_toViews` into one batched helper used everywhere.

Tests to add: feed with limit 500 and offset -5 returns ≤50 rows without error; NaN latitude on
create throws; NaN coordinates on feed are ignored; `listings/{id}/../{other}/x.jpg` rejected
by create and verifyPhotoUpload; duplicate photo paths rejected; created listing coordinates are
rounded; query "%" does not match everything; non-owner can read byId.

Acceptance: `dart format lib test`, `dart analyze` zero issues, `dart test` all green. No
commits. Report changes and results.
