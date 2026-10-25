# Dale Otra Vida — Design system

Source of truth: `Prototipo Dale Otra Vida.pdf` (6 screens). Colors and fonts below were
extracted from the PDF itself, not eyeballed.

Personality: warm, calm, trustworthy, community. Cream paper background, deep forest green
for authority, a warm orange accent used sparingly (logo tile, FAB, selected category chip).
Apple-level polish: generous spacing, soft 1px borders instead of heavy shadows, smooth
200–300ms ease-out transitions, 44pt minimum touch targets.

## Fonts (google_fonts package, already a dependency)
- Display / headings: **Fraunces** (serif). Weights 600–700.
- Body / UI: **Nunito Sans**. Weights 400, 600, 700, 800.

## Color tokens (`AppColors`)
| Token | Hex | Use |
|---|---|---|
| primary | #1E3A2F | Primary buttons, header blocks, bottom nav bar, selected filter chip, sent chat bubble, headings text |
| primaryVariant | #33443C | Pressed primary / secondary dark text |
| onPrimary | #F5F1EA | Text/icons on primary |
| accent | #E8A35C | Logo tile, FAB (+), avatar circle |
| accentStrong | #B4521A | Selected category chip in Publish form |
| link | #8A3D10 | Text links ("¿Olvidaste tu contraseña?", "Ver mapa") |
| background | #F5F1EA | Scaffold background (cream) |
| surface | #FBF9F5 | Cards, inputs, unselected chips, received chat bubble |
| surfaceMuted | #E9E2D2 | Image placeholders, segmented control track |
| border | #DCD5C8 | Default 1px borders (inputs, cards, chips) |
| borderLight | #E4DDD0 | Dividers, subtle borders |
| textPrimary | #1E3A2F | Titles |
| textSecondary | #4F5E57 | Body text, meta |
| textHint | #757575 | Placeholders |
| categoryCircle | #DDE4DF | Circle behind category initials/icons |
| verified | #2D6A4F | Verified shield icon |
| danger | #9B2C2C | "Reportar usuario", report flag |

Listing-type badges (pill, 12px radius, bold 11–12px text):
| Type | Background | Text |
|---|---|---|
| Donar | #E4EBE3 | #1E3A2F |
| Intercambiar | #F6E3CF | #6E300B |
| Vender | #DEE3EE | #2B3A6B |
| Prestar | #E9E2D2 | #4F5E57 |

Expiry highlight card (detail screen "Fecha de vencimiento"): bg #F6E3CF, label/text #8A3D10.

## Shape & spacing
- Radii: inputs/buttons 14, cards 16, chips/badges 999 (pill), large header blocks 28 (bottom corners), screen sheets 24.
- Spacing scale (`AppSpacing`): 4, 8, 12, 16, 20, 24, 32. Screen horizontal padding 20.
- Buttons: height 52, full width by default, bold 16px Nunito Sans.
- Inputs: height 52, filled `surface`, 1px `border`, focused border 1.5px `primary`, label above field (bold 14px, `textPrimary`), no floating label.
- Elevation: none by default. Use 1px borders. Only the FAB has a soft shadow.

## Typography scale (`AppTypography`)
| Style | Font | Size/weight |
|---|---|---|
| display | Fraunces | 32 / w700 (login hero title) |
| headline | Fraunces | 26 / w700 (detail title, "Dale Otra Vida" on home) |
| title | Fraunces | 22 / w700 (screen titles like "Publicar algo") |
| sectionLabel | Nunito Sans | 15 / w800 ("Categorías", "Cerca de ti") |
| body | Nunito Sans | 15 / w400 |
| bodyStrong | Nunito Sans | 15 / w700 |
| caption | Nunito Sans | 12.5 / w400, textSecondary |
| button | Nunito Sans | 16 / w700 |
| badge | Nunito Sans | 11.5 / w800 |

## Components (in `lib/core/widgets/`)
- `AppPrimaryButton` (filled primary), `AppSecondaryButton` (surface fill + border, e.g. "Continuar con Google"), both with `isLoading` state (small spinner, disabled).
- `AppTextField`: label above, hint, obscure toggle for passwords, error text below in danger.
- `AppSegmentedControl`: two-option pill toggle (Ingresar / Crear cuenta) — track `surfaceMuted`, selected segment `surface` with subtle shadow, animated 220ms.
- `FilterChipRow`: horizontal scroll of pill chips; selected = primary bg + onPrimary text.
- `TypeBadge(ListingType)`: colors from the badge table.
- `CategoryTile`: rounded card (surface + border) with a 36px `categoryCircle` circle containing an icon, label below (12px w700).
- `ListingCard`: horizontal card — 84px rounded image (placeholder `surfaceMuted` with image icon), type badge, title (bodyStrong), meta line (caption), location line with pin icon + "Barrio · a 0,8 km".
- `AppAvatar`: circle with initials, accent bg, Fraunces text.
- `SectionHeader`: label left + optional link action right (link color).
- `EmptyState`: icon, title, message, optional action.

Categories (enum order + Material icon suggestion): Alimentos (`restaurant`), Ropa (`checkroom`),
Libros (`menu_book`), Muebles (`chair`), Juguetes (`toys`), Tecnología (`devices`),
Herramientas (`handyman`), Hogar (`home`), Útiles (`edit`).

Listing types: Donar ("Regálalo a quien lo necesite"), Intercambiar ("Cámbialo por otra cosa"),
Vender ("Ofrécelo a un precio accesible"), Prestar ("Por un tiempo y te lo devuelven").

## Theme
`AppTheme.light` builds a Material 3 `ThemeData` from these tokens (colorScheme, scaffold bg,
inputDecorationTheme, filledButtonTheme, textTheme, chipTheme, bottomNavigationBar, snackBar).
Light mode only for the MVP. Respect text scaling; use `CupertinoPageRoute`-style transitions on
iOS and the platform default on Android (`PageTransitionsTheme`).
