// Browser check of the navigation without a server or a session:
//   flutter build web -t tool/routing_check.dart
// The real router and shell, with a fake profile and empty data.
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/app/navigation.dart';
import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/navigation/tap_guard.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:dale_otra_vida_flutter/features/notifications/notifications_badge_controller.dart';
import 'package:dale_otra_vida_flutter/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean addresses (…/mensajes, not …/#/mensajes); no-op on phones.
  usePathUrlStrategy();
  await initializeClient();
  await initializeDateFormatting('es', null);
  final profile = MemberProfile(
    id: 1,
    authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    displayName: 'Prueba',
  );
  final badge = NotificationsBadgeController();
  final chatBadge = NotificationsBadgeController();
  final router = buildRouter(
    tapGuard: TapGuard(),
    shell: (location) => AppShell(
      location: location,
      initialProfile: profile,
      badgeController: badge,
      chatBadgeController: chatBadge,
      fetchFeed:
          ({
            type,
            category,
            query,
            latitude,
            longitude,
            nearest,
            required limit,
            required offset,
          }) async => <ListingView>[],
      fetchConversations: () async => <ConversationView>[],
      inbox: () => const Stream<ChatMessage>.empty(),
    ),
  );
  runApp(MaterialApp.router(theme: AppTheme.light, routerConfig: router));
}
