import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/listing/listing_detail_logic.dart';
import 'package:dale_otra_vida_flutter/features/publish/listing_draft.dart';
import 'package:dale_otra_vida_flutter/features/reports/report_sheet.dart';
import 'package:dale_otra_vida_flutter/features/reviews/review_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 29, 12);

  Listing listing({
    Category category = Category.food,
    DateTime? expiresAt,
    ListingStatus status = ListingStatus.available,
  }) => Listing(
    id: 1,
    ownerId: 1,
    title: 'Cuate de mango',
    description: 'Mangos maduros.',
    type: ListingType.donate,
    category: category,
    condition: ItemCondition.good,
    photoUrls: const ['https://example.com/a.jpg'],
    neighborhood: 'Robledo',
    latitude: 6.2,
    longitude: -75.5,
    status: status,
    expiresAt: expiresAt,
    safeMeetingPoint: 'Estación Floresta',
  );

  group('isExpired', () {
    test('food past its date is expired', () {
      expect(
        isExpired(listing(expiresAt: DateTime.utc(2026, 10, 27)), now: now),
        isTrue,
      );
    });

    test('food with a future date is not expired', () {
      expect(
        isExpired(listing(expiresAt: DateTime.utc(2026, 11, 2)), now: now),
        isFalse,
      );
    });

    test('non-food never expires', () {
      expect(
        isExpired(listing(category: Category.furniture), now: now),
        isFalse,
      );
    });
  });

  group('ownListingLabel', () {
    test('labels expired food as Vencida', () {
      expect(
        ownListingLabel(
          listing(expiresAt: DateTime.utc(2026, 10, 27)),
          now: now,
        ),
        'Vencida',
      );
    });

    test('labels every non-available status', () {
      expect(
        ownListingLabel(listing(status: ListingStatus.reserved), now: now),
        'Reservado',
      );
      expect(
        ownListingLabel(listing(status: ListingStatus.delivered), now: now),
        'Entregado',
      );
      expect(
        ownListingLabel(listing(status: ListingStatus.withdrawn), now: now),
        'Retirado',
      );
    });

    test('no label for a visible listing', () {
      expect(
        ownListingLabel(
          listing(expiresAt: DateTime.utc(2026, 11, 2)),
          now: now,
        ),
        isNull,
      );
    });
  });

  test('ListingDraft.fromListing keeps the editable fields', () {
    final draft = ListingDraft.fromListing(
      listing(expiresAt: DateTime.utc(2026, 11, 2)),
    );
    expect(draft.title, 'Cuate de mango');
    expect(draft.category, Category.food);
    expect(draft.photos, hasLength(1));
    expect(draft.safeMeetingPoint, 'Estación Floresta');
    expect(draft.expiresAt, DateTime.utc(2026, 11, 2).toLocal());
    expect(validateListingDraft(draft), isNull);
  });

  test('every report reason and rating has Spanish copy', () {
    for (final reason in ReportReason.values) {
      expect(reportReasonLabel(reason), isNotEmpty);
    }
    expect(ratingCaption(0), 'Toca una estrella');
    expect(ratingCaption(5), '¡Excelente!');
  });
}
