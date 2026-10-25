import 'package:dale_otra_vida_flutter/app/auth_gate.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
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
