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
    bool? nearest,
    required int limit,
    required int offset,
  }) async {
    return <ListingView>[];
  }

  void setSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('compact 390x844 shows bottom bar and no rail/top bar', (
    tester,
  ) async {
    setSize(tester, const Size(390, 844));

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

    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Publicar'), findsNothing);

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mensajes'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('expanded 1440x900 shows top bar Publicar and no bottom bar', (
    tester,
  ) async {
    setSize(tester, const Size(1440, 900));

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

    expect(find.byType(BottomAppBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Publicar'), findsOneWidget);
    expect(find.text('Dale Otra Vida'), findsWidgets);
  });

  testWidgets('bottom bar at 360x640 switches to Mensajes tab', (
    tester,
  ) async {
    setSize(tester, const Size(360, 640));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShell(
          initialProfile: fakeProfile(),
          fetchFeed: fakeFetch,
          fetchConversations: () async => [],
          inbox: () => const Stream.empty(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mensajes'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.tap(find.text('Mensajes'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes conversaciones'), findsOneWidget);
  });
}
