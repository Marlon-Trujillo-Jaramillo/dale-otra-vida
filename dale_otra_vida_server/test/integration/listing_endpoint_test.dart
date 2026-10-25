import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Listing endpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder memberA;
    late TestSessionBuilder memberB;
    late MemberProfile profileA;
    late MemberProfile profileB;

    setUp(() async {
      final authUserA = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      memberA = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserA.id!.uuid,
          {},
        ),
      );
      profileA = await endpoints.profile.saveMe(memberA, displayName: 'Ana');

      final authUserB = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      memberB = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserB.id!.uuid,
          {},
        ),
      );
      profileB = await endpoints.profile.saveMe(memberB, displayName: 'Luis');
    });

    Future<String> uploadPhoto(
      TestSessionBuilder member,
      int profileId, {
      String ext = 'jpg',
    }) async {
      final path =
          'listings/$profileId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final session = member.build();
      await session.storage.storeFile(
        storageId: 'public',
        path: path,
        byteData: ByteData(8),
      );
      return path;
    }

    Listing baseListing({
      int? ownerId,
      required ListingType type,
      required Category category,
      required List<String> photoUrls,
      String title = 'Título de prueba',
      String? wantedInExchange,
      int? price,
      DateTime? expiresAt,
      DateTime? returnDate,
    }) {
      return Listing(
        ownerId: ownerId ?? 0,
        title: title,
        description: 'Descripción de prueba suficientemente larga.',
        type: type,
        category: category,
        condition: ItemCondition.good,
        photoUrls: photoUrls,
        neighborhood: 'Robledo',
        latitude: 6.25,
        longitude: -75.56,
        price: price,
        expiresAt: expiresAt,
        returnDate: returnDate,
        wantedInExchange: wantedInExchange,
      );
    }

    Future<ListingView> createListing({
      required TestSessionBuilder member,
      required ListingType type,
      required Category category,
      required int profileId,
      String title = 'Título de prueba',
    }) async {
      final path = await uploadPhoto(member, profileId);
      return endpoints.listing.create(
        member,
        baseListing(
          type: type,
          category: category,
          photoUrls: [path],
          title: title,
          price: type == ListingType.sell ? 50000 : null,
          expiresAt: category == Category.food
              ? DateTime.now().toUtc().add(const Duration(days: 1))
              : null,
          returnDate: type == ListingType.lend
              ? DateTime.now().toUtc().add(const Duration(days: 7))
              : null,
          wantedInExchange: type == ListingType.exchange
              ? 'Un libro de cocina'
              : null,
        ),
      );
    }

    group('when creating listings', () {
      test('donate succeeds with server-set owner and status', () async {
        final view = await createListing(
          member: memberA,
          type: ListingType.donate,
          category: Category.books,
          profileId: profileA.id!,
        );

        expect(view.listing.ownerId, profileA.id);
        expect(view.listing.status, ListingStatus.available);
        expect(view.isMine, isTrue);
        expect(view.owner.id, profileA.id);
        expect(view.owner.latitude, isNull);
      });

      test('sell succeeds with price', () async {
        final view = await createListing(
          member: memberA,
          type: ListingType.sell,
          category: Category.tech,
          profileId: profileA.id!,
        );

        expect(view.listing.price, 50000);
        expect(view.listing.type, ListingType.sell);
      });

      test('lend succeeds with return date', () async {
        final view = await createListing(
          member: memberA,
          type: ListingType.lend,
          category: Category.tools,
          profileId: profileA.id!,
        );

        expect(view.listing.returnDate, isNotNull);
      });

      test('exchange succeeds with wanted in exchange', () async {
        final view = await createListing(
          member: memberA,
          type: ListingType.exchange,
          category: Category.clothes,
          profileId: profileA.id!,
        );

        expect(view.listing.wantedInExchange, 'Un libro de cocina');
      });

      test('missing photo throws', () async {
        await expectLater(
          endpoints.listing.create(
            memberA,
            baseListing(
              type: ListingType.donate,
              category: Category.books,
              photoUrls: [],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('foreign photo path throws', () async {
        final foreignPath = await uploadPhoto(memberB, profileB.id!);
        await expectLater(
          endpoints.listing.create(
            memberA,
            baseListing(
              type: ListingType.donate,
              category: Category.books,
              photoUrls: [foreignPath],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('food without expiresAt throws', () async {
        final path = await uploadPhoto(memberA, profileA.id!);
        await expectLater(
          endpoints.listing.create(
            memberA,
            baseListing(
              type: ListingType.donate,
              category: Category.food,
              photoUrls: [path],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('sell without price throws', () async {
        final path = await uploadPhoto(memberA, profileA.id!);
        await expectLater(
          endpoints.listing.create(
            memberA,
            baseListing(
              type: ListingType.sell,
              category: Category.tech,
              photoUrls: [path],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('price on donate throws', () async {
        final path = await uploadPhoto(memberA, profileA.id!);
        await expectLater(
          endpoints.listing.create(
            memberA,
            baseListing(
              type: ListingType.donate,
              category: Category.books,
              photoUrls: [path],
              price: 1000,
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('lend without returnDate throws', () async {
        final path = await uploadPhoto(memberA, profileA.id!);
        await expectLater(
          endpoints.listing.create(
            memberA,
            baseListing(
              type: ListingType.lend,
              category: Category.tools,
              photoUrls: [path],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('exchange without wantedInExchange throws', () async {
        final path = await uploadPhoto(memberA, profileA.id!);
        await expectLater(
          endpoints.listing.create(
            memberA,
            baseListing(
              type: ListingType.exchange,
              category: Category.clothes,
              photoUrls: [path],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('when feeding listings', () {
      setUp(() async {
        await createListing(
          member: memberA,
          type: ListingType.donate,
          category: Category.books,
          profileId: profileA.id!,
          title: 'Libro de Dart',
        );
        await createListing(
          member: memberA,
          type: ListingType.sell,
          category: Category.tech,
          profileId: profileA.id!,
          title: 'Celular usado',
        );

        final foodPath = await uploadPhoto(memberA, profileA.id!);
        await endpoints.listing.create(
          memberA,
          baseListing(
            type: ListingType.donate,
            category: Category.food,
            photoUrls: [foodPath],
            title: 'Pan fresco',
            expiresAt: DateTime.now().toUtc().add(const Duration(days: 1)),
          ),
        );

        final expiredPath = await uploadPhoto(memberA, profileA.id!);
        await Listing.db.insertRow(
          sessionBuilder.build(),
          baseListing(
            ownerId: profileA.id!,
            type: ListingType.donate,
            category: Category.food,
            photoUrls: [expiredPath],
            title: 'Leche vencida',
            expiresAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
          ),
        );

        final withdrawnPath = await uploadPhoto(memberA, profileA.id!);
        final withdrawn = await endpoints.listing.create(
          memberA,
          baseListing(
            type: ListingType.donate,
            category: Category.clothes,
            photoUrls: [withdrawnPath],
            title: 'Camiseta',
          ),
        );
        await endpoints.listing.updateStatus(
          memberA,
          withdrawn.listing.id!,
          ListingStatus.withdrawn,
        );
      });

      test('returns only available non-expired listings', () async {
        final feed = await endpoints.listing.feed(
          memberA,
          limit: 20,
          offset: 0,
        );

        final titles = feed.map((v) => v.listing.title).toList();
        expect(titles, contains('Libro de Dart'));
        expect(titles, contains('Celular usado'));
        expect(titles, contains('Pan fresco'));
        expect(titles, isNot(contains('Leche vencida')));
        expect(titles, isNot(contains('Camiseta')));
      });

      test('filters by type', () async {
        final feed = await endpoints.listing.feed(
          memberA,
          type: ListingType.donate,
          limit: 20,
          offset: 0,
        );

        expect(feed.every((v) => v.listing.type == ListingType.donate), isTrue);
        expect(feed.any((v) => v.listing.title == 'Libro de Dart'), isTrue);
        expect(feed.any((v) => v.listing.title == 'Celular usado'), isFalse);
      });

      test('filters by category', () async {
        final feed = await endpoints.listing.feed(
          memberA,
          category: Category.books,
          limit: 20,
          offset: 0,
        );

        expect(feed.length, 1);
        expect(feed.first.listing.title, 'Libro de Dart');
      });

      test('filters by query', () async {
        final feed = await endpoints.listing.feed(
          memberA,
          query: 'celular',
          limit: 20,
          offset: 0,
        );

        expect(feed.length, 1);
        expect(feed.first.listing.title, 'Celular usado');
      });

      test('paginates with limit and offset', () async {
        final first = await endpoints.listing.feed(
          memberA,
          limit: 1,
          offset: 0,
        );
        final second = await endpoints.listing.feed(
          memberA,
          limit: 1,
          offset: 1,
        );

        expect(first.length, 1);
        expect(second.length, 1);
        expect(first.first.listing.id, isNot(second.first.listing.id));
      });

      test('includes distance only when coordinates provided', () async {
        final without = await endpoints.listing.feed(
          memberA,
          limit: 20,
          offset: 0,
        );
        final withDistance = await endpoints.listing.feed(
          memberA,
          latitude: 6.25,
          longitude: -75.56,
          limit: 20,
          offset: 0,
        );

        expect(without.first.distanceKm, isNull);
        expect(withDistance.first.distanceKm, isNotNull);
      });
    });

    group('when reading a listing by id', () {
      test(
        'returns owner without coordinates and resolved photo URLs',
        () async {
          final view = await createListing(
            member: memberA,
            type: ListingType.donate,
            category: Category.books,
            profileId: profileA.id!,
          );

          final found = await endpoints.listing.byId(
            memberA,
            view.listing.id!,
          );

          expect(found, isNotNull);
          expect(found!.listing.id, view.listing.id);
          expect(found.owner.id, profileA.id);
          expect(found.owner.latitude, isNull);
          expect(found.owner.longitude, isNull);
          expect(found.listing.photoUrls.first, startsWith('http'));
        },
      );

      test('returns null for missing id', () async {
        final found = await endpoints.listing.byId(memberA, -1);
        expect(found, isNull);
      });
    });

    group('when updating status', () {
      late ListingView listing;

      setUp(() async {
        listing = await createListing(
          member: memberA,
          type: ListingType.donate,
          category: Category.books,
          profileId: profileA.id!,
        );
      });

      test('owner transitions are allowed', () async {
        final reserved = await endpoints.listing.updateStatus(
          memberA,
          listing.listing.id!,
          ListingStatus.reserved,
        );
        expect(reserved.listing.status, ListingStatus.reserved);

        final availableAgain = await endpoints.listing.updateStatus(
          memberA,
          listing.listing.id!,
          ListingStatus.available,
        );
        expect(availableAgain.listing.status, ListingStatus.available);
      });

      test('invalid transition throws', () async {
        await expectLater(
          endpoints.listing.updateStatus(
            memberA,
            listing.listing.id!,
            ListingStatus.delivered,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('non-owner throws NotAllowedException', () async {
        await expectLater(
          endpoints.listing.updateStatus(
            memberB,
            listing.listing.id!,
            ListingStatus.withdrawn,
          ),
          throwsA(isA<NotAllowedException>()),
        );
      });

      test('delivered increments deliveryCount', () async {
        await endpoints.listing.updateStatus(
          memberA,
          listing.listing.id!,
          ListingStatus.reserved,
        );
        await endpoints.listing.updateStatus(
          memberA,
          listing.listing.id!,
          ListingStatus.delivered,
        );

        final me = await endpoints.profile.me(memberA);
        expect(me!.deliveryCount, 1);
      });
    });

    group('when uploading photos', () {
      test('rejects unsupported extension', () async {
        await expectLater(
          endpoints.listing.photoUploadDescription(memberA, '.exe'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('accepts supported extension and returns path', () async {
        final upload = await endpoints.listing.photoUploadDescription(
          memberA,
          'jpg',
        );

        expect(upload.path, startsWith('listings/${profileA.id!}/'));
        expect(upload.path, endsWith('.jpg'));
        expect(upload.uploadDescription, isNotEmpty);
      });

      test('verifyPhotoUpload rejects another member path', () async {
        final path = await uploadPhoto(memberA, profileA.id!);
        final result = await endpoints.listing.verifyPhotoUpload(memberB, path);
        expect(result, isFalse);
      });
    });

    group('when caller has no profile', () {
      late TestSessionBuilder noProfileMember;

      setUp(() async {
        final authUser = await AuthUser.db.insertRow(
          sessionBuilder.build(),
          AuthUser(scopeNames: {}),
        );
        noProfileMember = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            authUser.id!.uuid,
            {},
          ),
        );
      });

      test('mine throws ProfileRequiredException', () async {
        await expectLater(
          endpoints.listing.mine(noProfileMember),
          throwsA(isA<ProfileRequiredException>()),
        );
      });
    });
  });
}
