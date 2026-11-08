import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/map/map_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isAreaTooLarge', () {
    test('a neighborhood-sized area is fine', () {
      expect(
        isAreaTooLarge(south: 6.2, west: -75.6, north: 6.3, east: -75.5),
        isFalse,
      );
    });

    test('more than two degrees on either side is too large', () {
      expect(
        isAreaTooLarge(south: 4.0, west: -75.6, north: 6.3, east: -75.5),
        isTrue,
      );
      expect(
        isAreaTooLarge(south: 6.2, west: -78.0, north: 6.3, east: -75.5),
        isTrue,
      );
    });
  });

  test('areaCountLabel handles zero, one and many', () {
    expect(areaCountLabel(0), 'Nada publicado en esta zona');
    expect(areaCountLabel(1), '1 publicación en esta zona');
    expect(areaCountLabel(4), '4 publicaciones en esta zona');
  });

  ListingView at(double lat, double lng, String neighborhood) => ListingView(
    listing: Listing(
      ownerId: 1,
      title: 'Silla',
      description: 'Una silla.',
      type: ListingType.donate,
      category: Category.furniture,
      condition: ItemCondition.good,
      photoUrls: const [],
      neighborhood: neighborhood,
      latitude: lat,
      longitude: lng,
    ),
    owner: MemberProfile(
      authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
      displayName: 'Dueño',
    ),
    isMine: false,
  );

  test('groupIntoZones puts listings of the same ~1 km cell together', () {
    final zones = groupIntoZones([
      at(6.2451, -75.5951, 'Laureles'),
      at(6.2489, -75.5911, 'Laureles'),
      at(6.2551, -75.5911, 'Estadio'),
      at(6.2101, -75.5701, 'El Poblado'),
    ]);
    expect(zones, hasLength(3));
    final laureles = zones.firstWhere((z) => z.listings.length == 2);
    expect(laureles.neighborhood, 'Laureles');
    expect(laureles.center.latitude, closeTo(6.245, 1e-9));
    expect(laureles.center.longitude, closeTo(-75.595, 1e-9));
  });
}
