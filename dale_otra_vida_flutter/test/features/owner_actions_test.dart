import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/listing/listing_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('allowedOwnerActions', () {
    test('available listing allows reserve and withdraw', () {
      expect(
        allowedOwnerActions(ListingStatus.available),
        [OwnerAction.reserve, OwnerAction.withdraw],
      );
    });

    test(
      'reserved listing allows mark available, mark delivered and withdraw',
      () {
        expect(
          allowedOwnerActions(ListingStatus.reserved),
          [
            OwnerAction.markAvailable,
            OwnerAction.markDelivered,
            OwnerAction.withdraw,
          ],
        );
      },
    );

    test('delivered listing allows no actions', () {
      expect(allowedOwnerActions(ListingStatus.delivered), isEmpty);
    });

    test('withdrawn listing allows no actions', () {
      expect(allowedOwnerActions(ListingStatus.withdrawn), isEmpty);
    });
  });
}
