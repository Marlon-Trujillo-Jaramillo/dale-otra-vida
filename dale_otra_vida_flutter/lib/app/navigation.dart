import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import '../core/navigation/browser_history.dart';
import '../core/navigation/tap_guard.dart';
import '../core/widgets/widgets.dart';
import '../features/chat/chat_screen.dart';
import '../features/identity/identity_review_screen.dart';
import '../features/identity/identity_screen.dart';
import '../features/listing/listing_detail_screen.dart';
import '../features/map/map_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_body.dart' show ProfileTab;
import '../features/profile/public_profile_screen.dart';
import '../features/publish/publish_screen.dart';
import '../features/requests/my_requests_screen.dart';
import 'auth_gate.dart';

// Every screen has its own address, so the browser's back button (and
// Android's back gesture on the web) walks the same path the member took, and
// a listing can be opened from a link:
//
//   /            landing: Inicio, and where "back" from Inicio asks to leave
//   /inicio      Inicio            /mensajes   Mensajes      /perfil  Perfil
//   /mapa  /avisos  /publicar  /solicitudes  /editar-perfil
//   /publicacion/:id   /chat/:id   /usuario/:id
//   /identidad   /identidad/revisar
//
// History stays "Inicio → section": tabs replace each other (see AppShell),
// and closing a screen on the web goes back in the browser instead of
// pushing Inicio again.

/// Tab addresses, in the shell's order.
const tabPaths = ['/inicio', '/mensajes', '/perfil'];

/// The tab a shell address shows; '/' is Inicio too.
int tabForPath(String path) => switch (path) {
  '/mensajes' => 1,
  '/perfil' => 2,
  _ => 0,
};

bool _isShellPath(String path) => path == '/' || tabPaths.contains(path);

/// [shell] replaces sign-in and the real shell, for checking the navigation
/// in a browser without a server (tool/routing_check.dart).
GoRouter buildRouter({
  required TapGuard tapGuard,
  Widget Function(String location)? shell,
}) {
  // The same page key for every tab keeps a single shell (and its state)
  // while the address changes between tabs.
  Page<void> shellPage(BuildContext context, GoRouterState state) =>
      NoTransitionPage<void>(
        key: const ValueKey('shell'),
        child:
            shell?.call(state.uri.path) ??
            AuthGate(location: state.uri.path),
      );

  // Screens opened on top (push) show their own address too, e.g. /mapa or
  // /publicacion/12, so they can be shared and reloaded.
  GoRouter.optionURLReflectsImperativeAPIs = true;

  return GoRouter(
    initialLocation: '/',
    observers: [tapGuard],
    refreshListenable: shell == null ? client.auth.authInfoListenable : null,
    // Screens other than the shell need a session; the shell shows sign-in.
    redirect: (context, state) =>
        shell == null &&
            !client.auth.isAuthenticated &&
            !_isShellPath(state.uri.path)
        ? '/'
        : null,
    routes: [
      for (final path in ['/', ...tabPaths])
        GoRoute(path: path, pageBuilder: shellPage),
      _screen('/mapa', (state) => const MapScreen()),
      _screen('/avisos', (state) => const NotificationsScreen()),
      _screen('/solicitudes', (state) => const MyRequestsScreen()),
      _screen('/identidad', (state) => const IdentityScreen()),
      _screen(
        '/identidad/revisar',
        (state) => const IdentityReviewScreen(),
      ),
      // Not wrapped in _WebBackScope: it asks before discarding changes and
      // closes itself the same way.
      GoRoute(
        path: '/publicar',
        builder: (context, state) => _WithMyProfile(
          builder: (profile) => PublishScreen(
            profile: profile,
            editing: state.extra is Listing ? state.extra! as Listing : null,
          ),
          initial: null,
        ),
      ),
      _screen(
        '/editar-perfil',
        (state) => _WithMyProfile(
          initial: state.extra is MemberProfile
              ? state.extra! as MemberProfile
              : null,
          builder: (profile) => EditProfileScreen(profile: profile),
        ),
      ),
      _screen('/publicacion/:id', (state) {
        final extra = state.extra;
        return extra is ListingView
            ? ListingDetailScreen(view: extra)
            : _ListingById(id: int.parse(state.pathParameters['id']!));
      }),
      _screen(
        '/chat/:id',
        (state) => ChatScreen(
          conversationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      _screen(
        '/usuario/:id',
        (state) => PublicProfileScreen(
          profileId: int.parse(state.pathParameters['id']!),
          initialTab: state.extra is ProfileTab
              ? state.extra! as ProfileTab
              : ProfileTab.listings,
        ),
      ),
    ],
    errorBuilder: (context, state) => const AuthGate(location: '/'),
  );
}

GoRoute _screen(String path, Widget Function(GoRouterState state) build) =>
    GoRoute(
      path: path,
      builder: (context, state) => _WebBackScope(child: build(state)),
    );

/// On the web, closing a screen with the app's own back arrow goes back in
/// the browser: go_router would otherwise record the return as a new visit
/// and the browser's back button would reopen the screen.
class _WebBackScope extends StatelessWidget {
  const _WebBackScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back(context);
      },
      child: child,
    );
  }
}

/// Closes the current screen, with [result] on phones. On the web the
/// browser goes back instead (see [_WebBackScope]), so callers must not
/// depend on [result] there.
void closeScreen<T>(BuildContext context, [T? result]) {
  if (kIsWeb) {
    _back(context);
  } else if (context.canPop()) {
    context.pop(result);
  } else {
    context.go('/inicio');
  }
}

/// Back on the web: the browser's own back, or Inicio for a screen opened
/// straight from a link (nothing in the app to go back to).
void _back(BuildContext context) {
  if (context.canPop()) {
    browserBack();
  } else {
    context.go('/inicio');
  }
}

// --- Opening screens -----------------------------------------------------

Future<void> openListing(BuildContext context, ListingView view) =>
    context.push<void>('/publicacion/${view.listing.id}', extra: view);

Future<void> openChat(BuildContext context, int conversationId) =>
    context.push<void>('/chat/$conversationId');

Future<void> openMemberProfile(
  BuildContext context,
  int profileId, {
  ProfileTab tab = ProfileTab.listings,
}) => context.push<void>('/usuario/$profileId', extra: tab);

Future<void> openMap(BuildContext context) => context.push<void>('/mapa');

Future<void> openNotifications(BuildContext context) =>
    context.push<void>('/avisos');

Future<void> openMyRequests(BuildContext context) =>
    context.push<void>('/solicitudes');

Future<void> openPublish(BuildContext context, {Listing? editing}) =>
    context.push<void>('/publicar', extra: editing);

Future<void> openEditProfile(BuildContext context, MemberProfile profile) =>
    context.push<void>('/editar-perfil', extra: profile);

Future<void> openIdentity(BuildContext context) =>
    context.push<void>('/identidad');

Future<void> openIdentityReview(BuildContext context) =>
    context.push<void>('/identidad/revisar');

// --- Loaders for links without the object in memory ----------------------

class _ListingById extends StatelessWidget {
  const _ListingById({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListingView?>(
      future: client.listing.byId(id),
      builder: (context, snapshot) {
        final view = snapshot.data;
        if (view != null) return ListingDetailScreen(view: view);
        return Scaffold(
          appBar: AppBar(),
          body: snapshot.connectionState == ConnectionState.done
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'Esta publicación ya no está disponible',
                  message: 'Puede que la hayan retirado o entregado.',
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _WithMyProfile extends StatelessWidget {
  const _WithMyProfile({required this.builder, required this.initial});

  final Widget Function(MemberProfile profile) builder;
  final MemberProfile? initial;

  @override
  Widget build(BuildContext context) {
    final initial = this.initial;
    if (initial != null) return builder(initial);
    return FutureBuilder<MemberProfile?>(
      future: client.profile.me(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile != null) return builder(profile);
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
