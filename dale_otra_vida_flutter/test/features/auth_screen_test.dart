import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:dale_otra_vida_flutter/features/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    client = Client('http://localhost:8080');
  });

  void setSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('login step shows expected texts', (tester) async {
    setSize(tester, const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthScreen(
          controller: EmailAuthController(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ingresar'), findsWidgets);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
  });

  testWidgets('expanded layout shows the wide hero value props', (
    tester,
  ) async {
    setSize(tester, const Size(1440, 900));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthScreen(
          controller: EmailAuthController(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dona lo que ya no usas'), findsOneWidget);
    expect(find.text('Intercambia o presta en tu barrio'), findsOneWidget);
    expect(find.text('Vende a precios justos'), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('compact 390x844 keeps the mobile hero text', (tester) async {
    setSize(tester, const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthScreen(
          controller: EmailAuthController(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dale Otra Vida'), findsOneWidget);
    expect(find.text('Dona lo que ya no usas'), findsNothing);
    expect(find.text('Bienvenido de nuevo'), findsNothing);
  });
}
