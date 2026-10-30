import 'dart:math' as math;
import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given day 5 endpoints', (sessionBuilder, endpoints) {
    late TestSessionBuilder owner;
    late TestSessionBuilder requester;
    late TestSessionBuilder stranger;
    late MemberProfile ownerProfile;
    late MemberProfile requesterProfile;
    late MemberProfile strangerProfile;

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
      final profile = await endpoints.profile.saveMe(
        builder,
        displayName: name,
        latitude: 6.25,
        longitude: -75.56,
      );
      return (builder, profile);
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

    Listing draft({
      Category category = Category.furniture,
      DateTime? expiresAt,
      String title = 'Silla de escritorio',
      List<String> photoUrls = const [],
    }) => Listing(
      ownerId: 0,
      title: title,
      description: 'Descripción de prueba suficientemente larga.',
      type: ListingType.donate,
      category: category,
      condition: ItemCondition.good,
      photoUrls: photoUrls,
      neighborhood: 'Robledo',
      latitude: 6.25,
      longitude: -75.56,
      expiresAt: expiresAt,
    );

    Future<ListingView> createListing({
      Category category = Category.furniture,
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
        draft(category: category, expiresAt: expiresAt, photoUrls: [path]),
      );
    }

    /// Creates a listing, has the requester ask for it and the owner accept.
    Future<ListingView> reservedListing() async {
      final view = await createListing();
      final request = await endpoints.request.create(
        requester,
        view.listing.id!,
      );
      await endpoints.request.accept(owner, request.id!);
      return view;
    }

    Future<ListingView> deliveredListing() async {
      final view = await reservedListing();
      return endpoints.listing.updateStatus(
        owner,
        view.listing.id!,
        ListingStatus.delivered,
      );
    }

    setUp(() async {
      (owner, ownerProfile) = await member('Ana');
      (requester, requesterProfile) = await member('Luis');
      (stranger, strangerProfile) = await member('Caro');
    });

    group('listing.update', () {
      test('the owner edits text fields; type and photos stay', () async {
        final view = await createListing();
        final updated = await endpoints.listing.update(
          owner,
          view.listing.id!,
          view.listing.copyWith(
            title: '  Silla ergonómica  ',
            type: ListingType.lend,
            photoUrls: [],
            safeMeetingPoint: 'Estación Floresta',
          ),
        );
        expect(updated.listing.title, 'Silla ergonómica');
        expect(updated.listing.type, ListingType.donate);
        expect(updated.listing.price, isNull);
        expect(updated.listing.photoUrls, hasLength(1));
        expect(updated.listing.safeMeetingPoint, 'Estación Floresta');
      });

      test('a stranger cannot edit', () async {
        final view = await createListing();
        await expectLater(
          endpoints.listing.update(stranger, view.listing.id!, view.listing),
          throwsA(isA<NotAllowedException>()),
        );
      });

      test('an expired food listing gets a new future date', () async {
        final view = await createListing(
          category: Category.food,
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
        );
        final later = DateTime.now().toUtc().add(const Duration(days: 3));
        final updated = await endpoints.listing.update(
          owner,
          view.listing.id!,
          view.listing.copyWith(expiresAt: later),
        );
        expect(updated.listing.expiresAt!.isAfter(DateTime.now()), isTrue);

        await expectLater(
          endpoints.listing.update(
            owner,
            view.listing.id!,
            view.listing.copyWith(
              expiresAt: DateTime.now().toUtc().subtract(
                const Duration(days: 1),
              ),
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('a delivered listing cannot be edited', () async {
        final view = await deliveredListing();
        await expectLater(
          endpoints.listing.update(owner, view.listing.id!, view.listing),
          throwsA(isA<NotAllowedException>()),
        );
      });
    });

    group('delivery and reviews', () {
      test('delivery notifies the receiver and enables reviews', () async {
        final view = await deliveredListing();

        final notifications = await endpoints.notification.list(
          requester,
          limit: 30,
          offset: 0,
        );
        expect(
          notifications.where(
            (n) =>
                n.kind == NotificationKind.deliveryCompleted &&
                n.refId == view.listing.id,
          ),
          hasLength(1),
        );

        final mine = await endpoints.chat.conversations(requester);
        expect(mine.single.canReview, isTrue);
        final theirs = await endpoints.chat.conversations(owner);
        expect(theirs.single.canReview, isTrue);

        final messages = await endpoints.chat.messages(
          requester,
          mine.single.conversation.id!,
        );
        expect(messages.first.kind, MessageKind.system);
        expect(messages.first.text, startsWith('Entrega completada'));
      });

      test('reviews update the rating and can only happen once', () async {
        final view = await deliveredListing();
        final id = view.listing.id!;

        await endpoints.review.create(requester, id, 5, comment: ' Genial ');
        final review = (await endpoints.review.forMember(
          requester,
          ownerProfile.id!,
        )).single;
        expect(review.review.comment, 'Genial');
        expect(review.reviewer.id, requesterProfile.id);

        var ownerNow = await endpoints.profile.byId(owner, ownerProfile.id!);
        expect(ownerNow!.ratingAvg, 5);
        expect(ownerNow.reviewCount, 1);
        expect(ownerNow.deliveryCount, 1);

        await expectLater(
          endpoints.review.create(requester, id, 4),
          throwsA(isA<NotAllowedException>()),
        );
        expect(
          (await endpoints.chat.conversations(requester)).single.canReview,
          isFalse,
        );

        await endpoints.review.create(owner, id, 3);
        final requesterNow = await endpoints.profile.byId(
          owner,
          requesterProfile.id!,
        );
        expect(requesterNow!.ratingAvg, 3);

        final reviewNotifications = await endpoints.notification.list(
          owner,
          limit: 30,
          offset: 0,
        );
        expect(
          reviewNotifications.where(
            (n) => n.kind == NotificationKind.newReview,
          ),
          hasLength(1),
        );
      });

      test('the average accumulates across deliveries', () async {
        final first = await deliveredListing();
        await endpoints.review.create(requester, first.listing.id!, 5);
        final second = await deliveredListing();
        await endpoints.review.create(requester, second.listing.id!, 2);
        final ownerNow = await endpoints.profile.byId(owner, ownerProfile.id!);
        expect(ownerNow!.ratingAvg, 3.5);
        expect(ownerNow.reviewCount, 2);
      });

      test('rejects strangers, open listings and bad ratings', () async {
        final denied = throwsA(isA<NotAllowedException>());
        final delivered = await deliveredListing();
        await expectLater(
          endpoints.review.create(stranger, delivered.listing.id!, 4),
          denied,
        );
        await expectLater(
          endpoints.review.create(requester, delivered.listing.id!, 6),
          denied,
        );
        await expectLater(
          endpoints.review.create(requester, delivered.listing.id!, 0),
          denied,
        );
        final reserved = await reservedListing();
        await expectLater(
          endpoints.review.create(requester, reserved.listing.id!, 4),
          denied,
        );
      });
    });

    group('report.create', () {
      test('stores a report and dedupes repeats within a day', () async {
        final view = await createListing();
        final first = await endpoints.report.create(
          requester,
          ReportReason.scam,
          reportedUserId: ownerProfile.id,
          listingId: view.listing.id,
          details: ' Pide datos bancarios ',
        );
        expect(first.details, 'Pide datos bancarios');
        final again = await endpoints.report.create(
          requester,
          ReportReason.scam,
          reportedUserId: ownerProfile.id,
          listingId: view.listing.id,
        );
        expect(again.id, first.id);

        final userOnly = await endpoints.report.create(
          requester,
          ReportReason.spam,
          reportedUserId: ownerProfile.id,
        );
        expect(userOnly.id, isNot(first.id));
      });

      test(
        'rejects empty targets, yourself, your own listing and mismatches',
        () async {
          final denied = throwsA(isA<NotAllowedException>());
          final view = await createListing();
          await expectLater(
            endpoints.report.create(requester, ReportReason.other),
            denied,
          );
          await expectLater(
            endpoints.report.create(
              requester,
              ReportReason.other,
              reportedUserId: requesterProfile.id,
            ),
            denied,
          );
          await expectLater(
            endpoints.report.create(
              owner,
              ReportReason.other,
              listingId: view.listing.id,
            ),
            denied,
          );
          await expectLater(
            endpoints.report.create(
              requester,
              ReportReason.other,
              reportedUserId: strangerProfile.id,
              listingId: view.listing.id,
            ),
            denied,
          );
        },
      );
    });

    test('publicProfile splits listings, history and reviews', () async {
      final open = await createListing();
      final delivered = await deliveredListing();
      await endpoints.review.create(requester, delivered.listing.id!, 4);

      final view = await endpoints.profile.publicProfile(
        stranger,
        ownerProfile.id!,
      );
      expect(view.isMe, isFalse);
      expect(view.profile.latitude, isNull);
      expect(view.listings.map((l) => l.listing.id), [open.listing.id]);
      expect(view.history.map((l) => l.listing.id), [delivered.listing.id]);
      expect(view.reviews.single.review.rating, 4);

      final me = await endpoints.profile.publicProfile(
        owner,
        ownerProfile.id!,
      );
      expect(me.isMe, isTrue);
      expect(strangerProfile.id, isNotNull);
    });

    test('unreadCount reminds once about food expiring within a day', () async {
      final soon = await createListing(
        category: Category.food,
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 12)),
      );
      await createListing(
        category: Category.food,
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 4)),
      );

      expect(await endpoints.notification.unreadCount(owner), 1);
      expect(await endpoints.notification.unreadCount(owner), 1);

      final notifications = await endpoints.notification.list(
        owner,
        limit: 30,
        offset: 0,
      );
      final reminder = notifications.single;
      expect(reminder.kind, NotificationKind.listingExpiring);
      expect(reminder.refId, soon.listing.id);

      // Moving the date clears the old reminder.
      await endpoints.listing.update(
        owner,
        soon.listing.id!,
        soon.listing.copyWith(
          expiresAt: DateTime.now().toUtc().add(const Duration(days: 3)),
        ),
      );
      expect(
        await endpoints.notification.list(owner, limit: 30, offset: 0),
        isEmpty,
      );
    });
  });
}
