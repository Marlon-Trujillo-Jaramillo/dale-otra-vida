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
}
