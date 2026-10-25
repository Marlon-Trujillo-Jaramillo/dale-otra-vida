import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:dale_otra_vida_flutter/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  MemberProfile fakeProfile() => MemberProfile(
    authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    displayName: 'Usuario',
  );

  Future<List<ListingView>> fakeFetch({
    ListingType? type,
    Category? category,
    String? query,
    double? latitude,
    double? longitude,
    required int limit,
    required int offset,
  }) async {
    return <ListingView>[];
  }

  testWidgets('bottom bar at 360x640 switches to Mensajes tab', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShell(
          initialProfile: fakeProfile(),
          fetchFeed: fakeFetch,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mensajes'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();

    expect(find.text('Aquí verás tus conversaciones.'), findsOneWidget);
  });
}
