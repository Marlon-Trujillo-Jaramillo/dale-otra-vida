# Task: real responsive layouts (web/tablet feel, not a stretched phone)

Scope: `dale_otra_vida_flutter/` only. Mobile (< 600 dp) must look EXACTLY as today — every
change below is for wider screens. Use the design system tokens; no new packages.

## Breakpoints — `lib/core/layout/breakpoints.dart`
- `compact` < 600, `medium` 600–1023, `expanded` ≥ 1024.
- `enum ScreenSize { compact, medium, expanded }` + `ScreenSize.of(BuildContext)` using
  `MediaQuery.sizeOf(context).width`.
- `ContentWidth` widget: centers its child with `maxWidth` (default 1200) and horizontal
  padding 20 (compact) / 32 (medium) / 48 (expanded).

## Remove the phone frame
`lib/main.dart`: delete the `builder:` that constrains everything to 480 px. Set
`web/index.html` `<title>` to "Dale Otra Vida" and the manifest name/short_name likewise.

## Auth (`auth_screen.dart`) — expanded/medium: split screen
- Row: left panel (flex 5, `primary` bg, full height, padding 64) with the logo tile, the title
  in Fraunces 56/w700 onPrimary, the tagline (18, onPrimary 85%), then three value-prop rows
  with 40px accent-tinted circular icons: "Dona lo que ya no usas", "Intercambia o presta en tu
  barrio", "Vende a precios justos" (each with a one-line caption at 70% opacity). Bottom:
  small caption "Proyecto Pensamiento Creativo · Pascual Bravo".
- Right panel (flex 4, `background`): the existing segmented control + steps, centered inside a
  420px max-width column, vertically centered, with a "Bienvenido de nuevo" / "Crea tu cuenta"
  Fraunces 28 heading above the segmented control.
- Compact keeps today's layout untouched.

## Onboarding — medium/expanded
Center the form in a `surface` card (max 480, radius 24, 1px border, padding 32) on the
`background`.

## App shell (`app_shell.dart`)
- compact: today's bottom bar + docked FAB (unchanged).
- medium: `NavigationRail` (primary bg, onPrimary icons/labels, extended=false) with Inicio,
  Mensajes, Perfil and a "Publicar" FAB-style button at the top of the rail (accent).
- expanded: top app bar (height 72, `surface`, bottom 1px border) inside `ContentWidth`:
  logo tile + "Dale Otra Vida" (Fraunces 22) left; nav text buttons Inicio / Mensajes / Perfil
  (selected: primary text + 2px underline); right side: bell icon button, primary "+ Publicar"
  button, `AppAvatar` (32px) of the member. Body below.
- Publish opens as a centered dialog on medium/expanded (max 720 wide, 90% height, radius 24),
  full-screen route on compact. Same `PublishScreen` widget inside.

## Home (`home_screen.dart`) — medium/expanded
Inside `ContentWidth`:
- Header row: "Hola, {nombre}" + headline on the left; search field (max 520) on the right
  (expanded) or below (medium). Hide the bell here on expanded (it lives in the top bar).
- expanded: two columns. Left sidebar 260px (sticky via `CustomScrollView` +
  `SliverPersistentHeader` or simply a separate scrollable column): "Qué buscas" with the type
  filters as a vertical list of selectable rows, then "Categorías" as a vertical list with
  icon + label rows (selected row: `categoryCircle` bg + primary text). Right: results.
- medium: filters stay as chips row + category tiles in 8 columns (single row).
- Results on medium/expanded: `SliverGrid` with `maxCrossAxisExtent: 300`,
  `childAspectRatio` ≈ 0.78, spacing 20, using a NEW vertical card `ListingGridCard`
  (`lib/core/widgets/listing_grid_card.dart`): image on top (4:3, radius 16 top corners),
  then padding 14: TypeBadge, title (bodyStrong, 2 lines max), meta caption, location line.
  Hover (web/desktop): `MouseRegion` → slight lift (translate -2px, soft shadow 0 8 24
  rgba(30,58,47,0.08)) animated 160ms, `SystemMouseCursors.click`.
- Section header "Cerca de ti" + "Ver mapa" stays above the grid. Skeletons become grid
  skeletons. Empty/error states centered in the results column.
- compact: unchanged list.

## Listing detail — medium/expanded
`ContentWidth` with two columns (gap 40): left 7/12 gallery (rounded 24, aspect 4:3, thumbnails
row below to switch photos, arrows on hover), right 5/12 info column (badges, title, dates, info
cards, description, meeting point, owner card) and the action buttons inline at the bottom of
that column (no sticky bottom bar). A "← Volver" text button above the gallery. Compact keeps
today's layout.

## Polish (all sizes)
- Every clickable card/row has a hover state on web and `SystemMouseCursors.click`.
- Text never exceeds ~70 characters per line on wide screens (description max width 640).
- Scrollbars visible on web (`ScrollConfiguration` default is fine; don't hide them).

## Acceptance
- `dart format lib test`, `flutter analyze` zero issues, `flutter test` green.
- Add widget tests that pump `AuthScreen` and `AppShell` (with injected profile/fakes as the
  existing shell test does) at 390×844 and 1440×900 and assert: compact shows the bottom bar
  and no `NavigationRail`/top bar; expanded shows the top bar "Publicar" button and no bottom
  bar; auth expanded shows "Dona lo que ya no usas".
- No commits; don't edit `dale_otra_vida_client/` or the server.
