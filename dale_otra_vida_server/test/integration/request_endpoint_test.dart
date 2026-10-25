import 'dart:math' as math;
import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Request endpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder memberA;
    late TestSessionBuilder memberB;
    late TestSessionBuilder memberC;
    late TestSessionBuilder memberD;
    late MemberProfile profileA;
    late MemberProfile profileB;
    late MemberProfile profileC;
    late MemberProfile profileD;

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

      final authUserC = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      memberC = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserC.id!.uuid,
          {},
        ),
      );
      profileC = await endpoints.profile.saveMe(memberC, displayName: 'Caro');

      final authUserD = await AuthUser.db.insertRow(
        sessionBuilder.build(),
        AuthUser(scopeNames: {}),
      );
      memberD = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authUserD.id!.uuid,
          {},
        ),
      );
      profileD = await endpoints.profile.saveMe(memberD, displayName: 'Dani');
    });

    String testUuidV4() {
      final random = math.Random.secure();
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 0x0F) | 0x40;
      bytes[8] = (bytes[8] & 0x3F) | 0x80;
      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
          '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
    }

    Future<String> uploadPhoto(
      TestSessionBuilder member,
      int profileId, {
      String ext = 'jpg',
    }) async {
      final path = 'listings/$profileId/${testUuidV4()}.$ext';
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
      double latitude = 6.25,
      double longitude = -75.56,
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
        latitude: latitude,
        longitude: longitude,
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

    /// A donation listing owned by Ana, available for requests.
    Future<ListingView> createOwnedListing({
      String title = 'Título de prueba',
    }) => createListing(
      member: memberA,
      type: ListingType.donate,
      category: Category.books,
      profileId: profileA.id!,
      title: title,
    );

    Future<List<ChatMessage>> conversationMessages(int conversationId) =>
        ChatMessage.db.find(
          sessionBuilder.build(),
          where: (t) => t.conversationId.equals(conversationId),
          orderByList: (t) => [t.createdAt, t.id],
        );

    Future<List<AppNotification>> notificationsFor(int userId) async {
      final notifications = await AppNotification.db.find(
        sessionBuilder.build(),
        where: (t) => t.userId.equals(userId),
      );
      notifications.sort((a, b) {
        final byCreated = b.createdAt.compareTo(a.createdAt);
        if (byCreated != 0) return byCreated;
        return b.id!.compareTo(a.id!);
      });
      return notifications;
    }

    group('when creating a request', () {
      late ListingView listing;

      setUp(() async {
        listing = await createOwnedListing();
      });

      test(
        'happy path stores a pending request, a conversation, messages and an owner notification',
        () async {
          final request = await endpoints.request.create(
            memberB,
            listing.listing.id!,
            message: ' Hola, me interesa ',
          );

          expect(request.status, RequestStatus.pending);
          expect(request.listingId, listing.listing.id);
          expect(request.requesterId, profileB.id);
          expect(request.message, 'Hola, me interesa');

          final conversation = await Conversation.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.listingId.equals(listing.listing.id!),
          );
          expect(conversation, isNotNull);
          expect(conversation!.ownerId, profileA.id);
          expect(conversation.requesterId, profileB.id);

          final messages = await conversationMessages(conversation.id!);
          expect(messages, hasLength(2));
          expect(messages.first.kind, MessageKind.system);
          expect(messages.first.senderId, isNull);
          expect(messages.first.text, 'Luis quiere esta publicación.');
          expect(messages.last.kind, MessageKind.text);
          expect(messages.last.senderId, profileB.id);
          expect(messages.last.text, 'Hola, me interesa');

          final refreshedConversation = await Conversation.db.findById(
            sessionBuilder.build(),
            conversation.id!,
          );
          expect(
            refreshedConversation!.lastMessagePreview,
            'Hola, me interesa',
          );

          final notifications = await notificationsFor(profileA.id!);
          expect(notifications, hasLength(1));
          expect(notifications.first.kind, NotificationKind.newRequest);
          expect(notifications.first.title, 'Nueva solicitud');
          expect(
            notifications.first.body,
            'Luis quiere «Título de prueba»',
          );
          expect(notifications.first.refId, listing.listing.id);
        },
      );

      test('without a message only the system message is stored', () async {
        final request = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );

        expect(request.message, isNull);

        final conversation = await Conversation.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.listingId.equals(listing.listing.id!),
        );
        final messages = await conversationMessages(conversation!.id!);
        expect(messages, hasLength(1));
        expect(messages.first.kind, MessageKind.system);
        expect(messages.first.text, 'Luis quiere esta publicación.');

        final refreshedConversation = await Conversation.db.findById(
          sessionBuilder.build(),
          conversation.id!,
        );
        expect(
          refreshedConversation!.lastMessagePreview,
          'Luis quiere esta publicación.',
        );
      });

      test('own listing throws NotAllowedException', () async {
        await expectLater(
          endpoints.request.create(memberA, listing.listing.id!),
          throwsA(isA<NotAllowedException>()),
        );
      });

      test('missing listing throws', () async {
        await expectLater(
          endpoints.request.create(memberB, -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('non-available listing throws', () async {
        await endpoints.listing.updateStatus(
          memberA,
          listing.listing.id!,
          ListingStatus.reserved,
        );

        await expectLater(
          endpoints.request.create(memberB, listing.listing.id!),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('message longer than 300 characters throws', () async {
        await expectLater(
          endpoints.request.create(
            memberB,
            listing.listing.id!,
            message: 'a' * 301,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'duplicate create returns the same row without new side effects',
        () async {
          final first = await endpoints.request.create(
            memberB,
            listing.listing.id!,
            message: 'Primera',
          );
          final second = await endpoints.request.create(
            memberB,
            listing.listing.id!,
            message: 'Segunda',
          );

          expect(second.id, first.id);
          expect(second.message, 'Primera');
          expect(second.status, RequestStatus.pending);

          final conversation = await Conversation.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) => t.listingId.equals(listing.listing.id!),
          );
          final messages = await conversationMessages(conversation!.id!);
          expect(messages, hasLength(2));

          final notifications = await notificationsFor(profileA.id!);
          expect(notifications, hasLength(1));
        },
      );

      test('cancelled request is reopened with a fresh createdAt', () async {
        final first = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
        await endpoints.request.cancel(memberB, first.id!);

        final reopened = await endpoints.request.create(
          memberB,
          listing.listing.id!,
          message: 'Otra vez',
        );

        expect(reopened.id, first.id);
        expect(reopened.status, RequestStatus.pending);
        expect(reopened.message, 'Otra vez');
        expect(reopened.createdAt.isAfter(first.createdAt), isTrue);

        final conversation = await Conversation.db.findFirstRow(
          sessionBuilder.build(),
          where: (t) => t.listingId.equals(listing.listing.id!),
        );
        final messages = await conversationMessages(conversation!.id!);
        expect(messages, hasLength(3));
        expect(messages[1].kind, MessageKind.system);
        expect(messages[1].text, 'Luis quiere esta publicación.');
        expect(messages.last.kind, MessageKind.text);
        expect(messages.last.text, 'Otra vez');

        final notifications = await notificationsFor(profileA.id!);
        expect(notifications, hasLength(2));
      });

      test('rejected request cannot be recreated', () async {
        final request = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
        await endpoints.request.reject(memberA, request.id!);

        await expectLater(
          endpoints.request.create(memberB, listing.listing.id!),
          throwsA(isA<NotAllowedException>()),
        );
      });
    });

    group('when listing the requests for a listing', () {
      late ListingView listing;
      late ListingRequest requestB;
      late ListingRequest requestC;
      late ListingRequest requestD;

      setUp(() async {
        listing = await createOwnedListing();
        requestB = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
        requestC = await endpoints.request.create(
          memberC,
          listing.listing.id!,
          message: 'Me sirve',
        );
        requestD = await endpoints.request.create(
          memberD,
          listing.listing.id!,
        );
        await endpoints.request.reject(memberA, requestC.id!);
        await endpoints.request.reject(memberA, requestD.id!);
      });

      test('non-owner throws NotAllowedException', () async {
        await expectLater(
          endpoints.request.forListing(memberB, listing.listing.id!),
          throwsA(isA<NotAllowedException>()),
        );
      });

      test('missing listing throws', () async {
        await expectLater(
          endpoints.request.forListing(memberA, -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'returns pending first then newest first, with conversation ids and public requesters',
        () async {
          final views = await endpoints.request.forListing(
            memberA,
            listing.listing.id!,
          );

          expect(views, hasLength(3));
          expect(views.map((v) => v.request.id), [
            requestB.id,
            requestD.id,
            requestC.id,
          ]);
          expect(views.map((v) => v.request.status), [
            RequestStatus.pending,
            RequestStatus.rejected,
            RequestStatus.rejected,
          ]);
          expect(views.map((v) => v.request.requesterId), [
            profileB.id,
            profileD.id,
            profileC.id,
          ]);

          final conversations = await Conversation.db.find(
            sessionBuilder.build(),
            where: (t) => t.listingId.equals(listing.listing.id!),
          );
          final conversationIdByRequester = {
            for (final conversation in conversations)
              conversation.requesterId: conversation.id,
          };
          expect(
            views.first.conversationId,
            conversationIdByRequester[profileB.id],
          );
          expect(
            views[1].conversationId,
            conversationIdByRequester[profileD.id],
          );
          expect(
            views[2].conversationId,
            conversationIdByRequester[profileC.id],
          );

          expect(views.first.requester.id, profileB.id);
          expect(views.first.requester.latitude, isNull);
          expect(views.first.requester.longitude, isNull);
          expect(views.first.requester.displayName, 'Luis');
        },
      );
    });

    group('when accepting a request', () {
      late ListingView listing;
      late ListingRequest requestB;
      late ListingRequest requestC;

      setUp(() async {
        listing = await createOwnedListing();
        requestB = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
        requestC = await endpoints.request.create(
          memberC,
          listing.listing.id!,
        );
      });

      test(
        'accepts, reserves the listing, rejects the other pending requests and notifies everyone',
        () async {
          final accepted = await endpoints.request.accept(
            memberA,
            requestB.id!,
          );

          expect(accepted.status, RequestStatus.accepted);
          expect(accepted.id, requestB.id);

          final view = await endpoints.listing.byId(
            memberA,
            listing.listing.id!,
          );
          expect(view!.listing.status, ListingStatus.reserved);

          final refreshedC = await ListingRequest.db.findById(
            sessionBuilder.build(),
            requestC.id!,
          );
          expect(refreshedC!.status, RequestStatus.rejected);

          final ownerNotifications = await notificationsFor(profileA.id!);
          // The two newRequest notifications from setUp; accept adds none.
          expect(ownerNotifications, hasLength(2));
          expect(
            ownerNotifications.every(
              (n) => n.kind == NotificationKind.newRequest,
            ),
            isTrue,
          );

          final bNotifications = await notificationsFor(profileB.id!);
          expect(bNotifications, hasLength(1));
          expect(bNotifications.first.kind, NotificationKind.requestAccepted);
          expect(bNotifications.first.title, '¡Te lo reservaron!');
          expect(
            bNotifications.first.body,
            'Coordina la entrega de «Título de prueba» por el chat.',
          );
          expect(bNotifications.first.refId, listing.listing.id);

          final cNotifications = await notificationsFor(profileC.id!);
          expect(cNotifications, hasLength(1));
          expect(cNotifications.first.kind, NotificationKind.requestRejected);
          expect(cNotifications.first.title, 'Solicitud no disponible');
          expect(
            cNotifications.first.body,
            '«Título de prueba» fue reservado para otra persona.',
          );

          final conversation = await Conversation.db.findFirstRow(
            sessionBuilder.build(),
            where: (t) =>
                t.listingId.equals(listing.listing.id!) &
                t.requesterId.equals(profileB.id!),
          );
          final messages = await conversationMessages(conversation!.id!);
          expect(messages, hasLength(2));
          expect(messages.last.kind, MessageKind.system);
          expect(messages.last.senderId, isNull);
          expect(
            messages.last.text,
            'Ana reservó esta publicación para ti. '
            'Acuerden un punto de encuentro seguro.',
          );

          final refreshedConversation = await Conversation.db.findById(
            sessionBuilder.build(),
            conversation.id!,
          );
          expect(
            refreshedConversation!.lastMessagePreview,
            'Ana reservó esta publicación para ti. '
            'Acuerden un punto de encuentro seguro.',
          );
        },
      );

      test('non-owner throws NotAllowedException', () async {
        await expectLater(
          endpoints.request.accept(memberC, requestB.id!),
          throwsA(isA<NotAllowedException>()),
        );
      });

      test('missing request throws', () async {
        await expectLater(
          endpoints.request.accept(memberA, -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('non-pending request throws', () async {
        await endpoints.request.accept(memberA, requestB.id!);

        await expectLater(
          endpoints.request.accept(memberA, requestB.id!),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('listing not available throws', () async {
        await endpoints.listing.updateStatus(
          memberA,
          listing.listing.id!,
          ListingStatus.reserved,
        );

        await expectLater(
          endpoints.request.accept(memberA, requestB.id!),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('when rejecting a request', () {
      late ListingView listing;
      late ListingRequest requestB;

      setUp(() async {
        listing = await createOwnedListing();
        requestB = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
      });

      test('rejects a pending request and notifies the requester', () async {
        final rejected = await endpoints.request.reject(
          memberA,
          requestB.id!,
        );

        expect(rejected.status, RequestStatus.rejected);

        final notifications = await notificationsFor(profileB.id!);
        expect(notifications, hasLength(1));
        expect(notifications.first.kind, NotificationKind.requestRejected);
        expect(notifications.first.title, 'Solicitud rechazada');
        expect(
          notifications.first.body,
          'El dueño eligió a otra persona para «Título de prueba».',
        );
        expect(notifications.first.refId, listing.listing.id);
      });

      test('non-pending request throws', () async {
        await endpoints.request.reject(memberA, requestB.id!);

        await expectLater(
          endpoints.request.reject(memberA, requestB.id!),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('non-owner throws NotAllowedException', () async {
        await expectLater(
          endpoints.request.reject(memberB, requestB.id!),
          throwsA(isA<NotAllowedException>()),
        );
      });
    });

    group('when cancelling a request', () {
      late ListingView listing;
      late ListingRequest requestB;

      setUp(() async {
        listing = await createOwnedListing();
        requestB = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
      });

      test('cancelling a pending request does not notify the owner', () async {
        final cancelled = await endpoints.request.cancel(
          memberB,
          requestB.id!,
        );

        expect(cancelled.status, RequestStatus.cancelled);

        final ownerNotifications = await notificationsFor(profileA.id!);
        // Only the newRequest notification from setUp; cancel adds none.
        expect(ownerNotifications, hasLength(1));
        expect(ownerNotifications.first.kind, NotificationKind.newRequest);

        final view = await endpoints.listing.byId(
          memberA,
          listing.listing.id!,
        );
        expect(view!.listing.status, ListingStatus.available);
      });

      test(
        'cancelling an accepted request frees the listing and notifies the owner',
        () async {
          await endpoints.request.accept(memberA, requestB.id!);

          final cancelled = await endpoints.request.cancel(
            memberB,
            requestB.id!,
          );
          expect(cancelled.status, RequestStatus.cancelled);

          final view = await endpoints.listing.byId(
            memberA,
            listing.listing.id!,
          );
          expect(view!.listing.status, ListingStatus.available);

          final ownerNotifications = await notificationsFor(profileA.id!);
          // The newRequest from setUp plus the requestCancelled from cancel.
          expect(ownerNotifications, hasLength(2));
          expect(
            ownerNotifications.first.kind,
            NotificationKind.requestCancelled,
          );
          expect(ownerNotifications.first.title, 'Reserva cancelada');
          expect(
            ownerNotifications.first.body,
            'Luis canceló su solicitud de «Título de prueba».',
          );
          expect(ownerNotifications.first.refId, listing.listing.id);
        },
      );

      test('cancelling a non-pending request throws', () async {
        await endpoints.request.reject(memberA, requestB.id!);

        await expectLater(
          endpoints.request.cancel(memberB, requestB.id!),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('non-requester throws NotAllowedException', () async {
        await expectLater(
          endpoints.request.cancel(memberC, requestB.id!),
          throwsA(isA<NotAllowedException>()),
        );
      });
    });

    group('when the listing status changes', () {
      late ListingView listing;
      late ListingRequest requestB;
      late ListingRequest requestC;

      setUp(() async {
        listing = await createOwnedListing();
        requestB = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
        requestC = await endpoints.request.create(
          memberC,
          listing.listing.id!,
        );
      });

      test(
        'reserved back to available cancels the accepted request and notifies the requester',
        () async {
          await endpoints.request.accept(memberA, requestB.id!);

          final available = await endpoints.listing.updateStatus(
            memberA,
            listing.listing.id!,
            ListingStatus.available,
          );
          expect(available.listing.status, ListingStatus.available);

          final refreshedB = await ListingRequest.db.findById(
            sessionBuilder.build(),
            requestB.id!,
          );
          expect(refreshedB!.status, RequestStatus.cancelled);

          final notifications = await notificationsFor(profileB.id!);
          expect(notifications, hasLength(2));
          expect(notifications.first.kind, NotificationKind.requestCancelled);
          expect(notifications.first.title, 'Reserva cancelada');
          expect(
            notifications.first.body,
            'El dueño volvió a publicar «Título de prueba».',
          );
          expect(notifications.first.refId, listing.listing.id);
        },
      );

      test(
        'withdrawn from available cancels every pending request without notifications',
        () async {
          await endpoints.listing.updateStatus(
            memberA,
            listing.listing.id!,
            ListingStatus.withdrawn,
          );

          final requests = await ListingRequest.db.find(
            sessionBuilder.build(),
            where: (t) => t.listingId.equals(listing.listing.id!),
          );
          expect(
            requests.every((r) => r.status == RequestStatus.cancelled),
            isTrue,
          );

          // The two newRequest notifications from setUp; withdraw adds none.
          final ownerNotifications = await notificationsFor(profileA.id!);
          expect(ownerNotifications, hasLength(2));
          expect(
            ownerNotifications.every(
              (n) => n.kind == NotificationKind.newRequest,
            ),
            isTrue,
          );
          expect(await notificationsFor(profileB.id!), isEmpty);
          expect(await notificationsFor(profileC.id!), isEmpty);
        },
      );

      test(
        'withdrawn from reserved cancels the accepted request without notifications',
        () async {
          await endpoints.request.accept(memberA, requestB.id!);

          await endpoints.listing.updateStatus(
            memberA,
            listing.listing.id!,
            ListingStatus.withdrawn,
          );

          final refreshedB = await ListingRequest.db.findById(
            sessionBuilder.build(),
            requestB.id!,
          );
          expect(refreshedB!.status, RequestStatus.cancelled);

          final refreshedC = await ListingRequest.db.findById(
            sessionBuilder.build(),
            requestC.id!,
          );
          expect(refreshedC!.status, RequestStatus.rejected);

          final bNotifications = await notificationsFor(profileB.id!);
          expect(bNotifications, hasLength(1));
          expect(bNotifications.first.kind, NotificationKind.requestAccepted);

          // The two newRequest notifications from setUp; withdraw adds none.
          final ownerNotifications = await notificationsFor(profileA.id!);
          expect(ownerNotifications, hasLength(2));
          expect(
            ownerNotifications.every(
              (n) => n.kind == NotificationKind.newRequest,
            ),
            isTrue,
          );
        },
      );
    });

    group('when viewing listings with requests', () {
      late ListingView listing;
      late ListingRequest requestB;
      late ListingRequest requestC;

      setUp(() async {
        listing = await createOwnedListing();
        requestB = await endpoints.request.create(
          memberB,
          listing.listing.id!,
        );
        requestC = await endpoints.request.create(
          memberC,
          listing.listing.id!,
        );
      });

      test('the requester sees myRequest on the listing view', () async {
        final viewForB = await endpoints.listing.byId(
          memberB,
          listing.listing.id!,
        );
        final viewForC = await endpoints.listing.byId(
          memberC,
          listing.listing.id!,
        );

        expect(viewForB, isNotNull);
        expect(viewForB!.myRequest, isNotNull);
        expect(viewForB.myRequest!.id, requestB.id);
        expect(viewForB.myRequest!.status, RequestStatus.pending);
        expect(viewForB.isMine, isFalse);
        expect(viewForB.pendingRequestCount, 0);

        expect(viewForC!.myRequest, isNotNull);
        expect(viewForC.myRequest!.id, requestC.id);
        expect(viewForC.pendingRequestCount, 0);
      });

      test('the owner sees pendingRequestCount on their own listing', () async {
        final mine = await endpoints.listing.mine(memberA);

        expect(mine, hasLength(1));
        expect(mine.first.pendingRequestCount, 2);
        expect(mine.first.myRequest, isNull);
      });

      test('an unrelated member sees neither', () async {
        final feed = await endpoints.listing.feed(
          memberD,
          limit: 20,
          offset: 0,
        );

        expect(feed, hasLength(1));
        expect(feed.first.myRequest, isNull);
        expect(feed.first.pendingRequestCount, 0);
      });
    });

    group('when reading my requests', () {
      test(
        'returns the requests of the caller newest first with listing views and conversation ids',
        () async {
          final olderListing = await createOwnedListing(
            title: 'Publicación vieja',
          );
          final newerListing = await createOwnedListing(
            title: 'Publicación nueva',
          );
          final olderRequest = await endpoints.request.create(
            memberB,
            olderListing.listing.id!,
          );
          final newerRequest = await endpoints.request.create(
            memberB,
            newerListing.listing.id!,
            message: 'Me interesa',
          );

          final mine = await endpoints.request.mine(memberB);

          expect(mine, hasLength(2));
          expect(mine.first.request.id, newerRequest.id);
          expect(mine.last.request.id, olderRequest.id);

          expect(mine.first.listing.listing.title, 'Publicación nueva');
          expect(
            mine.first.listing.listing.photoUrls.first,
            startsWith('http'),
          );
          expect(mine.first.listing.owner.id, profileA.id);
          expect(mine.first.listing.owner.latitude, isNull);

          expect(mine.last.listing.listing.title, 'Publicación vieja');
          expect(mine.last.request.message, isNull);

          final conversations = await Conversation.db.find(
            sessionBuilder.build(),
            where: (t) => t.requesterId.equals(profileB.id!),
          );
          final conversationIdByListing = {
            for (final conversation in conversations)
              conversation.listingId: conversation.id,
          };
          expect(
            mine.first.conversationId,
            conversationIdByListing[newerListing.listing.id],
          );
          expect(
            mine.last.conversationId,
            conversationIdByListing[olderListing.listing.id],
          );
        },
      );

      test('a member without requests gets an empty list', () async {
        expect(await endpoints.request.mine(memberD), isEmpty);
      });
    });
  });
}
