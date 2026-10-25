import 'package:dale_otra_vida_flutter/core/models/listing_type_ui.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:dale_otra_vida_flutter/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppPrimaryButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppPrimaryButton(
              label: 'Ingresar',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('renders loading spinner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppPrimaryButton(
              label: 'Ingresar',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Ingresar'), findsNothing);
    });
  });

  group('TypeBadge', () {
    for (final type in ListingTypeUi.values) {
      testWidgets('renders ${type.label}', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(body: TypeBadge(type: type)),
          ),
        );

        expect(find.text(type.label), findsOneWidget);
      });
    }
  });

  group('ListingCard', () {
    testWidgets('renders title, meta and location', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ListingCard(
              title: 'Silla de madera',
              type: ListingTypeUi.donar,
              meta: 'Publicado hace 2 horas',
              location: 'Barrio',
              distance: '0,8 km',
            ),
          ),
        ),
      );

      expect(find.text('Silla de madera'), findsOneWidget);
      expect(find.text('Publicado hace 2 horas'), findsOneWidget);
      expect(find.text('Barrio · a 0,8 km'), findsOneWidget);
      expect(find.text('Donar'), findsOneWidget);
    });
  });
}
