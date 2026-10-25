import 'package:dale_otra_vida_flutter/app/auth_gate.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dale Otra Vida',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
