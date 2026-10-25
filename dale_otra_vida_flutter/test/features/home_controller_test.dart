import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/home/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MemberProfile fakeProfile() => MemberProfile(
    authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    displayName: 'Usuario',
  );

  ListingView fakeView(int id) => ListingView(
    listing: Listing(
      ownerId: 1,
      title: 'Publicación $id',
      description: 'Descripción de la publicación $id.',
      type: ListingType.donate,
      category: Category.books,
      condition: ItemCondition.good,
      photoUrls: ['photos/$id.jpg'],
      neighborhood: 'Laureles',
      latitude: 6.2,
      longitude: -75.5,
    ),
    owner: fakeProfile(),
    isMine: false,
  );

  group('HomeController generation guard', () {
    test('older slower response does not overwrite a newer one', () async {
      final completer1 = Completer<List<ListingView>>();
      final completer2 = Completer<List<ListingView>>();
      var callCount = 0;

      Future<List<ListingView>> fetch({
        ListingType? type,
        Category? category,
        String? query,
        double? latitude,
        double? longitude,
        required int limit,
        required int offset,
      }) async {
        callCount++;
        if (callCount == 1) return completer1.future;
        return completer2.future;
      }

      final controller = HomeController(
        profile: fakeProfile(),
        fetchFeed: fetch,
      );

      unawaited(controller.init());
      await Future.delayed(Duration.zero);
      expect(controller.loading, isTrue);

      controller.setQuery('nueva');
      await Future.delayed(Duration.zero);
      expect(controller.loading, isTrue);

      completer2.complete([fakeView(2)]);
      await Future.delayed(Duration.zero);
      expect(controller.listings, hasLength(1));
      expect(controller.listings.first.listing.title, 'Publicación 2');
      expect(controller.loading, isFalse);

      completer1.complete([fakeView(1)]);
      await Future.delayed(Duration.zero);
      expect(controller.listings, hasLength(1));
      expect(controller.listings.first.listing.title, 'Publicación 2');

      controller.dispose();
    });

    test('skips loadMore while a refresh is in flight', () async {
      final completer = Completer<List<ListingView>>();
      Future<List<ListingView>> fetch({
        ListingType? type,
        Category? category,
        String? query,
        double? latitude,
        double? longitude,
        required int limit,
        required int offset,
      }) async {
        return completer.future;
      }

      final controller = HomeController(
        profile: fakeProfile(),
        fetchFeed: fetch,
      );

      unawaited(controller.init());
      await Future.delayed(Duration.zero);
      expect(controller.loading, isTrue);

      await controller.loadMore();
      expect(controller.loadingMore, isFalse);

      completer.complete([fakeView(1)]);
      await Future.delayed(Duration.zero);
      expect(controller.loading, isFalse);

      controller.dispose();
    });
  });
}
