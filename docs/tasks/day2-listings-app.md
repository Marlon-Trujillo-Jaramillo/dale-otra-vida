# Task: home feed, listing detail and publish (Flutter app)

Scope: `dale_otra_vida_flutter/` only. Prototype screens 2 (Inicio), 3 (Detalle) and 5
(Publicar). Use `lib/core/` design system; extend widgets when needed instead of inlining
styles. Spanish copy. The server API is generated in `dale_otra_vida_client` (read it, never
edit it): `client.listing.photoUploadDescription(ext)` → `PhotoUpload{path, uploadDescription}`,
`client.listing.verifyPhotoUpload(path)`, `client.listing.create(Listing)` → `ListingView`,
`client.listing.feed(type:, category:, query:, latitude:, longitude:, limit:, offset:)`,
`client.listing.byId(id, latitude:, longitude:)`, `client.listing.mine()`,
`client.listing.updateStatus(id, status)`. `ListingView{listing, owner, distanceKm, isMine}`.
Server exceptions: `ProfileRequiredException`, `NotAllowedException`; validation errors arrive
as generic errors — show "Revisa los datos e inténtalo de nuevo." for those.

## Packages (add with `flutter pub add`)
`image_picker`, `flutter_image_compress`, `cached_network_image`, `geolocator`, `intl`.
Platform config:
- Android main manifest: `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`.
- iOS Info.plist: `NSLocationWhenInUseUsageDescription` ("Usamos tu ubicación aproximada para
  mostrarte publicaciones cerca de ti."), `NSCameraUsageDescription` ("Para tomar fotos de lo
  que publicas."), `NSPhotoLibraryUsageDescription` ("Para elegir fotos de lo que publicas.").
  Do not touch the Google keys already in Info.plist.

## Shared
- `lib/core/models/listing_type_ui.dart` / `category_ui.dart`: add mappers to/from the server
  enums `ListingType` and `Category` (keep the UI enums).
- `lib/core/format.dart`: `formatDistance(double km)` → "a 0,8 km" / "a 120 m" (es_CO),
  `formatCop(int)` → "$ 25.000", `formatDate(DateTime)` → "24 oct 2026" (es). Initialize
  `intl` date symbols for `es` in `main()`.
- `lib/core/location.dart`: `Future<({double lat, double lng})?> currentApproxLocation()` with
  geolocator (low accuracy, 8 s timeout, handles denied/disabled → null, cache last result in
  memory for 5 min).
- `ListingCard`: accept `imageUrl` (CachedNetworkImage with placeholder/error = current
  placeholder), and build from a `ListingView` via a named constructor
  `ListingCard.fromView(view, onTap:)`. Meta line: food → "Vence: {fecha} · Estado: {cond}",
  sell → "{precio} · Estado: {cond}", lend → "Hasta {fecha}", exchange → "Busca: {texto}".
  Add an `InkWell` ripple with the card radius.
- Condition labels: asNew "Como nuevo", good "Bueno", used "Usado".

## Home (`lib/features/home/home_screen.dart`) — prototype screen 2
- Header: "Hola, {displayName}" (caption) + "Dale Otra Vida" (headline) + bell icon button in
  a 44px bordered circle (opens a placeholder "Notificaciones" screen for now).
- Search field with search icon, hint "Busca ropa, libros, alimentos…", debounce 400 ms.
- `FilterChipRow`: Todos, Donar, Intercambiar, Vender, Prestar.
- "Categorías" grid 4 columns of `CategoryTile` (8 categories shown on home: Alimentos, Ropa,
  Libros, Muebles, Juguetes, Tecnología, Herramientas, Hogar). Tapping selects/unselects that
  category filter (selected tile gets primary border).
- `SectionHeader` "Cerca de ti" + link "Ver mapa" (placeholder screen for now, map is day 6).
- List of `ListingCard.fromView`, infinite scroll (page 20), pull-to-refresh, skeleton loading
  placeholders (3 grey cards), `EmptyState` when no results ("Aún no hay publicaciones por
  aquí" / "Sé el primero en darle otra vida a algo."), error state with "Reintentar".
- Location: request once on first load; if null, feed works without distance.
- State management: plain `StatefulWidget` + a small `HomeController extends ChangeNotifier`
  in `lib/features/home/home_controller.dart` (filters, paging, loading/error). No new state
  management packages.
- Wire it as the "Inicio" tab in `AppShell`; the shell should pass the profile (fetch with
  `client.profile.me()` once in the shell and keep it).

## Detail (`lib/features/listing/listing_detail_screen.dart`) — prototype screen 3
- Photo carousel (`PageView`, 300px tall, `surfaceMuted` bg) with page dots; round back button
  (44px, surface) top-left over the image; tap photo → full-screen viewer with pinch zoom
  (`InteractiveViewer`).
- Badges row: TypeBadge + category pill. Title (headline). "Publicado el {fecha}" caption.
- Two info cards side by side: "Estado" {condition}; and depending on type: food "Fecha de
  vencimiento" (expiry highlight colors), sell "Precio", lend "Devolver antes de", exchange
  "Busca a cambio".
- "Descripción" section. "Punto de encuentro seguro" card with pin icon: safeMeetingPoint or
  "A convenir en un lugar público" + "{barrio} · {distancia}".
- Owner card: AppAvatar initials, name + verified shield if `isVerified`, "★ {ratingAvg} ·
  {reviewCount} reseñas · {deliveryCount} entregas", chevron (profile screen is day 5).
- Status banner if not available ("Reservado" / "Entregado" / "Retirado").
- Bottom bar (safe-area aware, surface, top border): square chat icon button + primary
  "Lo quiero". Both show a SnackBar "Disponible muy pronto" for now (requests + chat are
  days 3–4). If `isMine`: replace with owner actions — "Marcar como reservado/disponible",
  "Marcar como entregado", "Retirar publicación" (confirm dialog) using `updateStatus`, and
  refresh.
- Open from home cards with a hero-free `MaterialPageRoute`.

## Publish (`lib/features/publish/publish_screen.dart`) — prototype screen 5
Opened from the FAB as a full-screen modal route (close "X" top-left, title "Publicar algo").
- Fotos (obligatorio): up to 5. "Agregar" dashed tile → bottom sheet "Tomar foto" / "Elegir
  de la galería". Compress to max 1600 px, JPEG quality 80 before upload. Each thumbnail shows
  upload progress / error-retry and an "x" to remove. Upload immediately after picking:
  `photoUploadDescription('jpg')` → `FileUploader(uploadDescription).upload(bytes)` (from
  `serverpod_flutter`) → `verifyPhotoUpload(path)`; keep the `path`.
- "¿Qué quieres hacer?": 2×2 selectable cards (Donar, Intercambiar, Vender, Prestar) with the
  subtitles from the design system; selected = primary bg + onPrimary text.
- Categoría: wrap of chips with all 9 categories; selected = accentStrong bg.
- Título, Descripción y estado (multiline, counter), Estado del artículo (3 chips).
- Conditional fields: food → "Fecha de vencimiento" (date picker, future only); sell →
  "Precio (COP)" numeric with thousands formatting; lend → "Devolver antes de" date picker;
  exchange → "¿Qué te gustaría recibir a cambio?".
- Barrio (prefilled from profile) and "Punto de encuentro sugerido" (optional, hint "Ej:
  Estación Metro Floresta").
- Location: get `currentApproxLocation()`; if null show inline warning "Activa la ubicación
  para publicar (solo usamos tu zona aproximada)" with a "Reintentar" link; Publicar disabled
  until location and ≥1 uploaded photo.
- Sticky bottom "Publicar" primary button with loading. Client-side validation mirrors the
  server rules (title 3–80, description 10–1000, conditional fields). On success: close,
  show SnackBar "¡Publicado! Gracias por darle otra vida." and refresh the home feed.
- Draft safety: confirm dialog when closing with unsaved changes.

## Tests
- `test/core/format_test.dart` for the formatters.
- `test/features/publish_validation_test.dart`: extract validation into a pure function
  `validateListingDraft(draft)` in `lib/features/publish/listing_draft.dart` and test the rules.
- Existing tests keep passing.

## Acceptance
In `dale_otra_vida_flutter/`: `dart format lib test`, `flutter analyze` zero issues,
`flutter test` green. No commits. Do not edit `dale_otra_vida_client/` or the server.
