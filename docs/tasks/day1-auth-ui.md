# Task: auth UI (prototype screen 1) + onboarding + app shell

Use the design system in `lib/core/` (theme, widgets). Spanish copy. Flutter app only
(`dale_otra_vida_flutter/`). Do NOT edit `dale_otra_vida_client/` or the server.

## Auth API (serverpod_auth_idp_flutter 4.0.4 — verified)
- `client.auth.authInfoListenable` (`ValueListenable<AuthSuccess?>`), `client.auth.isAuthenticated`,
  `client.auth.signOutDevice()`.
- `EmailAuthController({required client, startScreen, onAuthenticated, onError})`
  (`package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart`). ChangeNotifier with
  `emailController`, `passwordController`, `verificationCodeController`, `currentScreen`
  (`EmailFlowScreen`: login, startRegistration, verifyRegistration, completeRegistration,
  requestPasswordReset, verifyPasswordReset, completePasswordReset), `isLoading`, `errorMessage`,
  `navigateTo(screen)`, `navigateBack()`.
  - Login: `login()`.
  - Register: `startRegistration()` → `verifyRegistrationCode()` → `finishRegistration()`.
    `resendVerificationCode()` on the verify step.
  - Reset: `navigateTo(requestPasswordReset)` → `startPasswordReset()` → `verifyPasswordResetCode()`
    → `finishPasswordReset()` (signs in automatically).
  - The controller never navigates the app; it only changes `currentScreen`.
- Profile endpoint: `client.profile.me()` → `MemberProfile?`,
  `client.profile.saveMe(displayName:, neighborhood:, latitude:, longitude:)`.

## Files
1. `lib/features/auth/auth_screen.dart` — matches prototype screen 1:
   - Top block: `primary` background, bottom corners radius 28, padding 24, safe-area aware.
     44px rounded (12) `accent` tile with `Icons.eco_outlined` in `primary`; "Dale Otra Vida"
     (`display`, onPrimary); tagline "Lo que ya no usas puede ser justo lo que otra persona
     necesita." (body, onPrimary 85% opacity).
   - Below on `background`: `AppSegmentedControl` Ingresar / Crear cuenta.
   - Renders one step widget per `EmailFlowScreen` with `AnimatedSwitcher` (220ms fade+slide).
   - Login step: Correo electrónico, Contraseña (obscure toggle), right-aligned link
     "¿Olvidaste tu contraseña?" → requestPasswordReset, primary "Ingresar", divider with "o",
     secondary "Continuar con Google" with a Google "G" icon placeholder (`Icons.g_mobiledata`).
     Google is wired on day 2: for now it shows a SnackBar "Muy pronto podrás ingresar con Google".
   - Register steps: email → 6-digit code ("Te enviamos un código a {email}", "Reenviar código")
     → password + confirm password with live requirement hints (min 8 chars) → done.
   - Reset steps: email → code → new password.
   - Back affordance on multi-step flows (`navigateBack`).
   - Errors from `errorMessage` shown under the form in `danger`, plus field-level validation
     (empty email, invalid email, passwords don't match) before calling the controller.
   - Keyboard: `TextInputAction.next/done`, autofill hints (email, password, newPassword,
     oneTimeCode), scrolls when keyboard opens, tap outside dismisses keyboard.
2. `lib/features/onboarding/onboarding_screen.dart` — shown when signed in but `me()` is null:
   title "Cuéntanos de ti" (title style), fields "¿Cómo te llamas?" (2–60 chars) and
   "Barrio" (optional), primary "Continuar" → `saveMe`, then the app shell. Location is added
   on day 6 (map/nearby), not now.
3. `lib/features/shell/app_shell.dart` — bottom bar from prototype: `primary` bar with Inicio,
   Mensajes, center raised circular `accent` FAB with "+", Perfil. Labels 11px, selected
   onPrimary, unselected onPrimary 60%. Tabs show `EmptyState` placeholders for now
   ("Inicio", "Mensajes", "Perfil" with a "Cerrar sesión" secondary button that calls
   `client.auth.signOutDevice()`). FAB opens a placeholder "Publicar algo" screen.
4. `lib/app/auth_gate.dart` — `ValueListenableBuilder` on `client.auth.authInfoListenable`:
   null → `AuthScreen`; signed in → `FutureBuilder` on `client.profile.me()`: loading →
   centered spinner on background; null → `OnboardingScreen`; profile → `AppShell`.
   Refetch the profile when auth changes and after onboarding completes.
5. `lib/main.dart` — `MaterialApp(title: 'Dale Otra Vida', theme: AppTheme.light,
   debugShowCheckedModeBanner: false, home: const AuthGate())`. Keep `initializeClient()`.
   Remove the greetings example screens and `lib/screens/sign_in_screen.dart`. Keep
   `lib/screens/design_gallery_screen.dart` (reachable from Perfil in debug mode only via
   `kDebugMode`). Keep `lib/driver.dart` compiling (it imports main).
6. Android: add `<uses-permission android:name="android.permission.INTERNET"/>` to
   `android/app/src/main/AndroidManifest.xml` (currently only in debug/profile manifests).

## Acceptance
In `dale_otra_vida_flutter/`: `dart format lib test`, `flutter analyze` with zero issues,
`flutter test` passing. Add `test/features/auth_screen_test.dart` that pumps the login step
UI pieces that don't need a live client (or inject the controller) and checks the texts
"Ingresar", "Crear cuenta", "¿Olvidaste tu contraseña?", "Continuar con Google" exist.
No commits.

## Also allowed
You may extend `lib/core/widgets/app_text_field.dart` with: `autofillHints`, `focusNode`,
`enabled`, `maxLength`, `textCapitalization`, `inputFormatters` (keep existing API working).
Wrap the auth forms in `AutofillGroup`.
