import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_theme.dart';
import 'package:dale_otra_vida_flutter/core/widgets/listing_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  ListingView fakeView() {
    return ListingView(
      listing: Listing(
        ownerId: 1,
        title: 'Silla de madera',
        description: 'Silla usada en buen estado.',
        type: ListingType.donate,
        category: Category.furniture,
        condition: ItemCondition.good,
        photoUrls: const [],
        neighborhood: 'Laureles',
        latitude: 6.2,
        longitude: -75.6,
      ),
      owner: MemberProfile(
        authUserId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000001',
        ),
        displayName: 'María',
      ),
      isMine: false,
      distanceKm: 0.8,
    );
  }

  testWidgets('renders title, type badge and location', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: ListingGridCard.fromView(
                fakeView(),
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Silla de madera'), findsOneWidget);
    expect(find.text('Donar'), findsOneWidget);
    expect(find.textContaining('Laureles'), findsOneWidget);

    await tester.tap(find.text('Silla de madera'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
