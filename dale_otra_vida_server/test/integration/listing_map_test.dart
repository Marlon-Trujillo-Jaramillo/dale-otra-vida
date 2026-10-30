import 'dart:math' as math;
import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given listings on the map', (sessionBuilder, endpoints) {
    late TestSessionBuilder owner;
    late TestSessionBuilder viewer;
    late MemberProfile ownerProfile;

    Future<(TestSessionBuilder, MemberProfile)> member(String name) async {
      final authUser = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      final builder = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUser.id!.uuid,
          {},
        ),
      );
      return (
        builder,
        await endpoints.profile.saveMe(builder, displayName: name),
      );
    }

    String uuid() {
      final random = math.Random.secure();
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 0x0F) | 0x40;
      bytes[8] = (bytes[8] & 0x3F) | 0x80;
      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
          '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
          '${hex.substring(20, 32)}';
    }

    Future<ListingView> listingAt(
      String title,
      double latitude,
      double longitude, {
      Category category = Category.books,
      DateTime? expiresAt,
    }) async {
      final path = 'listings/${ownerProfile.id}/${uuid()}.jpg';
      await owner.build().storage.storeFile(
        storageId: 'public',
        path: path,
        byteData: ByteData(8),
      );
      return endpoints.listing.create(
        owner,
        Listing(
          ownerId: 0,
          title: title,
          description: 'Descripción de prueba suficientemente larga.',
          type: ListingType.donate,
          category: category,
          condition: ItemCondition.good,
          photoUrls: [path],
          neighborhood: 'Laureles',
          latitude: latitude,
          longitude: longitude,
          expiresAt: expiresAt,
        ),
      );
    }

    setUp(() async {
      (owner, ownerProfile) = await member('Ana');
      (viewer, _) = await member('Luis');
    });

    test('nearest sorts by distance instead of date', () async {
      await listingAt('Lejos', 6.30, -75.60);
      await listingAt('Cerca', 6.251, -75.561);
      await listingAt('Medio', 6.27, -75.58);

      final nearest = await endpoints.listing.feed(
        viewer,
        latitude: 6.25,
        longitude: -75.56,
        nearest: true,
        limit: 20,
        offset: 0,
      );
      expect(nearest.map((v) => v.listing.title), ['Cerca', 'Medio', 'Lejos']);

      final newest = await endpoints.listing.feed(
        viewer,
        latitude: 6.25,
        longitude: -75.56,
        limit: 20,
        offset: 0,
      );
      expect(newest.map((v) => v.listing.title), ['Medio', 'Cerca', 'Lejos']);

      final secondPage = await endpoints.listing.feed(
        viewer,
        latitude: 6.25,
        longitude: -75.56,
        nearest: true,
        limit: 2,
        offset: 2,
      );
      expect(secondPage.map((v) => v.listing.title), ['Lejos']);
    });

    test('inArea returns only visible listings inside the box', () async {
      await listingAt('Adentro', 6.25, -75.56);
      await listingAt('Afuera', 6.40, -75.56);
      final withdrawnFood = await listingAt(
        'Comida',
        6.251,
        -75.561,
        category: Category.food,
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 2)),
      );
      await endpoints.listing.updateStatus(
        owner,
        withdrawnFood.listing.id!,
        ListingStatus.withdrawn,
      );

      final inside = await endpoints.listing.inArea(
        viewer,
        south: 6.2,
        west: -75.6,
        north: 6.3,
        east: -75.5,
        latitude: 6.25,
        longitude: -75.56,
      );
      expect(inside.map((v) => v.listing.title), ['Adentro']);
      expect(inside.single.distanceKm, isNotNull);
    });

    test('inArea rejects inverted or huge areas', () async {
      await expectLater(
        endpoints.listing.inArea(
          viewer,
          south: 6.3,
          west: -75.6,
          north: 6.2,
          east: -75.5,
        ),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        endpoints.listing.inArea(
          viewer,
          south: 4.0,
          west: -77.0,
          north: 7.0,
          east: -74.0,
        ),
        throwsA(isA<NotAllowedException>()),
      );
    });
  });
}
