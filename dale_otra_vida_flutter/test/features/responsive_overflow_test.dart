import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:dale_otra_vida_flutter/features/auth/auth_screen.dart';
import 'package:dale_otra_vida_flutter/features/chat/conversations_screen.dart';
import 'package:dale_otra_vida_flutter/features/listing/listing_detail_screen.dart';
import 'package:dale_otra_vida_flutter/features/publish/publish_screen.dart';
import 'package:dale_otra_vida_flutter/features/shell/app_shell.dart';
import 'package:dale_otra_vida_flutter/features/profile/profile_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Resizes through phone, tablet and desktop widths and fails on any layout
/// overflow, the kind of glitch that shows up while dragging a window edge.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    client = Client('http://localhost:8080');
    await initializeDateFormatting('es');
  });

  MemberProfile member(String name) => MemberProfile(
    id: 1,
    authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    displayName: name,
    neighborhood: 'Laureles',
    ratingAvg: 4.6,
    reviewCount: 12,
    deliveryCount: 9,
    isVerified: true,
  );

  ListingView listing(int id) => ListingView(
    listing: Listing(
      id: id,
      ownerId: 1,
      title: 'Juego de llaves combinadas de acero cromado número $id',
      description:
          'Herramientas en muy buen estado, las usé un par de veces para '
          'arreglos de la casa. Incluye estuche.',
      type: ListingType.lend,
      category: Category.tools,
      condition: ItemCondition.good,
      photoUrls: const [],
      neighborhood: 'Laureles',
      latitude: 6.25,
      longitude: -75.59,
      returnDate: DateTime.utc(2026, 12, 20),
      safeMeetingPoint: 'Estación Floresta del metro, salida norte',
    ),
    owner: member('Daniela Cardona Bedoya'),
    isMine: false,
    distanceKm: 1.2,
  );

  const widths = <double>[
    320,
    360,
    420,
    599,
    600,
    700,
    820,
    1000,
    1023,
    1024,
    1280,
    1600,
  ];

  Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: child));
    await tester.pump(const Duration(milliseconds: 300));
  }

  for (final width in widths) {
    testWidgets('listing detail fits at ${width.toInt()} px', (tester) async {
      await pumpAt(tester, width, ListingDetailScreen(view: listing(1)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('profile fits at ${width.toInt()} px', (tester) async {
      await pumpAt(
        tester,
        width,
        Scaffold(
          body: ProfileBody(
            view: PublicProfileView(
              profile: member('Daniela Cardona Bedoya'),
              isMe: false,
              listings: [listing(1), listing(2), listing(3)],
              history: const [],
              reviews: const [],
            ),
            tab: ProfileTab.listings,
            onTabChanged: (_) {},
            onOpenListing: (_) {},
            onReport: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('home with listings fits at ${width.toInt()} px', (
      tester,
    ) async {
      Future<List<ListingView>> feed({
        ListingType? type,
        Category? category,
        String? query,
        double? latitude,
        double? longitude,
        bool? nearest,
        required int limit,
        required int offset,
      }) async => [for (var i = 1; i <= 6; i++) listing(i)];

      await pumpAt(
        tester,
        width,
        AppShell(
          initialProfile: member('Daniela Cardona Bedoya'),
          fetchFeed: feed,
          fetchConversations: () async => [],
          inbox: () => const Stream.empty(),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('messages fit at ${width.toInt()} px', (tester) async {
      final conversation = ConversationView(
        conversation: Conversation(
          id: 7,
          listingId: 1,
          ownerId: 1,
          requesterId: 2,
          lastMessagePreview:
              'Hola, sí, todavía está disponible. ¿Cuándo podrías recogerlo?',
        ),
        listing: listing(1),
        other: member('Nicolás Puerta Álvarez'),
        isOwner: true,
        unreadCount: 3,
      );
      await pumpAt(
        tester,
        width,
        ConversationsScreen(
          fetchConversations: () async => [conversation, conversation],
          inbox: () => const Stream.empty(),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('publish fits at ${width.toInt()} px', (tester) async {
      await pumpAt(
        tester,
        width,
        PublishScreen(profile: member('Daniela Cardona Bedoya')),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('auth fits at ${width.toInt()} px', (tester) async {
      await pumpAt(
        tester,
        width,
        AuthScreen(controller: EmailAuthController(client: client)),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
