import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Chat endpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder owner;
    late TestSessionBuilder requester;
    late TestSessionBuilder stranger;
    late MemberProfile ownerProfile;
    late MemberProfile requesterProfile;
    late ListingView listing;
    late int conversationId;

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
      );
      return (builder, profile);
    }

    setUp(() async {
      (owner, ownerProfile) = await member('Ana');
      (requester, requesterProfile) = await member('Luis');
      (stranger, _) = await member('Caro');

      final path =
          'listings/${ownerProfile.id}/0f8b6c1e-3a2d-4c5b-9e7f-1a2b3c4d5e6f.jpg';
      await owner.build().storage.storeFile(
        storageId: 'public',
        path: path,
        byteData: ByteData(8),
      );
      listing = await endpoints.listing.create(
        owner,
        Listing(
          ownerId: 0,
          title: 'Mercado de frutas',
          description: 'Descripción de prueba suficientemente larga.',
          type: ListingType.donate,
          category: Category.food,
          condition: ItemCondition.good,
          photoUrls: [path],
          neighborhood: 'Robledo',
          latitude: 6.25,
          longitude: -75.56,
          expiresAt: DateTime.now().toUtc().add(const Duration(days: 3)),
        ),
      );
      await endpoints.request.create(
        requester,
        listing.listing.id!,
        message: 'Hola, ¿todavía lo tienes?',
      );
      final conversations = await endpoints.chat.conversations(requester);
      conversationId = conversations.single.conversation.id!;
    });

    group('conversations', () {
      test('lists the conversation for both sides', () async {
        final mine = await endpoints.chat.conversations(requester);
        expect(mine.single.isOwner, isFalse);
        expect(mine.single.other.id, ownerProfile.id);
        expect(mine.single.other.latitude, isNull);
        expect(mine.single.request?.status, RequestStatus.pending);
        expect(mine.single.listing.listing.id, listing.listing.id);
        expect(mine.single.unreadCount, 0);

        final theirs = await endpoints.chat.conversations(owner);
        expect(theirs.single.isOwner, isTrue);
        expect(theirs.single.other.id, requesterProfile.id);
        // The requester's text message counts, the system message does not.
        expect(theirs.single.unreadCount, 1);
        expect(
          theirs.single.conversation.lastMessagePreview,
          'Hola, ¿todavía lo tienes?',
        );
      });

      test('a stranger has no conversations and no access', () async {
        expect(await endpoints.chat.conversations(stranger), isEmpty);
        final denied = throwsA(isA<NotAllowedException>());
        await expectLater(
          endpoints.chat.conversation(stranger, conversationId),
          denied,
        );
        await expectLater(
          endpoints.chat.messages(stranger, conversationId),
          denied,
        );
        await expectLater(
          endpoints.chat.send(stranger, conversationId, 'Hola'),
          denied,
        );
        await expectLater(
          endpoints.chat.markRead(stranger, conversationId),
          denied,
        );
        await expectLater(
          endpoints.chat.subscribe(stranger, conversationId).first,
          denied,
        );
        await expectLater(endpoints.chat.conversation(owner, 999999), denied);
      });
    });

    group('send', () {
      test('trims and stores the message, updating the preview', () async {
        final sent = await endpoints.chat.send(
          owner,
          conversationId,
          '  Sí, está disponible.  ',
        );
        expect(sent.text, 'Sí, está disponible.');
        expect(sent.senderId, ownerProfile.id);
        expect(sent.kind, MessageKind.text);

        final view = await endpoints.chat.conversation(owner, conversationId);
        expect(view.conversation.lastMessagePreview, 'Sí, está disponible.');
      });

      test('a safe point proposal gets a prefixed preview', () async {
        await endpoints.chat.send(
          requester,
          conversationId,
          'Parque Biblioteca',
          kind: MessageKind.safePointProposal,
        );
        final view = await endpoints.chat.conversation(owner, conversationId);
        expect(
          view.conversation.lastMessagePreview,
          '📍 Punto propuesto: Parque Biblioteca',
        );
      });

      test('rejects empty, too long and system messages', () async {
        final denied = throwsA(isA<NotAllowedException>());
        await expectLater(
          endpoints.chat.send(owner, conversationId, '   '),
          denied,
        );
        await expectLater(
          endpoints.chat.send(owner, conversationId, 'a' * 1001),
          denied,
        );
        await expectLater(
          endpoints.chat.send(
            owner,
            conversationId,
            'Hola',
            kind: MessageKind.system,
          ),
          denied,
        );
      });

      test('a withdrawn listing closes the conversation', () async {
        await endpoints.listing.updateStatus(
          owner,
          listing.listing.id!,
          ListingStatus.withdrawn,
        );
        await expectLater(
          endpoints.chat.send(requester, conversationId, 'Hola'),
          throwsA(isA<NotAllowedException>()),
        );
      });

      test('a rejected request closes the conversation', () async {
        final requests = await endpoints.request.forListing(
          owner,
          listing.listing.id!,
        );
        await endpoints.request.reject(owner, requests.single.request.id!);
        await expectLater(
          endpoints.chat.send(requester, conversationId, 'Hola'),
          throwsA(isA<NotAllowedException>()),
        );
      });

      test('notifies the other side only once while unread', () async {
        await endpoints.chat.send(owner, conversationId, 'Uno');
        await endpoints.chat.send(owner, conversationId, 'Dos');
        final notifications = await endpoints.notification.list(
          requester,
          limit: 30,
          offset: 0,
        );
        final newMessages = notifications
            .where((n) => n.kind == NotificationKind.newMessage)
            .toList();
        expect(newMessages, hasLength(1));
        expect(newMessages.single.refId, conversationId);
        expect(newMessages.single.title, 'Nuevo mensaje de Ana');
      });
    });

    test('messages pages newest first with beforeId', () async {
      for (var i = 0; i < 5; i++) {
        await endpoints.chat.send(owner, conversationId, 'Mensaje $i');
      }
      final firstPage = await endpoints.chat.messages(
        requester,
        conversationId,
        limit: 3,
      );
      expect(firstPage.map((m) => m.text), [
        'Mensaje 4',
        'Mensaje 3',
        'Mensaje 2',
      ]);
      final secondPage = await endpoints.chat.messages(
        requester,
        conversationId,
        beforeId: firstPage.last.id,
        limit: 3,
      );
      expect(secondPage.map((m) => m.text), [
        'Mensaje 1',
        'Mensaje 0',
        'Hola, ¿todavía lo tienes?',
      ]);
    });

    test('markRead clears unread messages and the notification', () async {
      await endpoints.chat.send(requester, conversationId, 'Otro mensaje');
      expect(await endpoints.chat.unreadTotal(owner), 2);
      expect(await endpoints.notification.unreadCount(owner), greaterThan(0));

      await endpoints.chat.markRead(owner, conversationId);

      expect(await endpoints.chat.unreadTotal(owner), 0);
      final view = await endpoints.chat.conversation(owner, conversationId);
      expect(view.unreadCount, 0);
      final notifications = await endpoints.notification.list(
        owner,
        limit: 30,
        offset: 0,
      );
      expect(
        notifications.where(
          (n) => n.kind == NotificationKind.newMessage && n.readAt == null,
        ),
        isEmpty,
      );
      // The requester's own unread count is untouched.
      expect(await endpoints.chat.unreadTotal(requester), 0);
    });

    // Streams check participation with database calls when they start;
    // wait for those to finish before sending.
    Future<void> streamStarted() async {
      await flushEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    test('subscribe receives messages sent afterwards', () async {
      final received = endpoints.chat
          .subscribe(requester, conversationId)
          .first
          .timeout(const Duration(seconds: 5));
      await streamStarted();

      await endpoints.chat.send(owner, conversationId, 'En vivo');

      expect((await received).text, 'En vivo');
    });

    test('inbox receives messages from every conversation', () async {
      final received = endpoints.chat
          .inbox(requester)
          .first
          .timeout(const Duration(seconds: 5));
      await streamStarted();

      await endpoints.chat.send(owner, conversationId, 'Al buzón');

      final message = await received;
      expect(message.text, 'Al buzón');
      expect(message.conversationId, conversationId);
    });
  });
}
