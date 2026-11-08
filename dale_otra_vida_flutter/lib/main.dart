import 'package:dale_otra_vida_flutter/app/navigation.dart';
import 'package:dale_otra_vida_flutter/core/navigation/tap_guard.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean addresses (…/mensajes, not …/#/mensajes); no-op on phones.
  usePathUrlStrategy();
  await initializeClient();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

final _tapGuard = TapGuard();

// Built once (top-level finals are lazy): rebuilding it would reset the
// navigation.
final GoRouter _router = buildRouter(tapGuard: _tapGuard);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dale Otra Vida',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      builder: (context, child) => _tapGuard.wrap(child),
    );
  }
}
