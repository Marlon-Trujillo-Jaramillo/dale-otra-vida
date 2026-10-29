import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/chat/chat_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  MemberProfile member(String name) => MemberProfile(
    authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    displayName: name,
  );

  Listing listing({
    ListingStatus status = ListingStatus.available,
    ListingType type = ListingType.donate,
    DateTime? expiresAt,
    int? price,
    DateTime? returnDate,
  }) => Listing(
    id: 1,
    ownerId: 1,
    title: 'Mercado',
    description: 'Frutas y verduras.',
    type: type,
    category: Category.food,
    condition: ItemCondition.good,
    photoUrls: const [],
    neighborhood: 'Robledo',
    latitude: 6.2,
    longitude: -75.5,
    status: status,
    expiresAt: expiresAt,
    price: price,
    returnDate: returnDate,
  );

  ConversationView view({
    bool isOwner = false,
    ListingStatus status = ListingStatus.available,
    RequestStatus? requestStatus = RequestStatus.pending,
  }) => ConversationView(
    conversation: Conversation(
      id: 7,
      listingId: 1,
      ownerId: 1,
      requesterId: 2,
    ),
    listing: ListingView(
      listing: listing(status: status),
      owner: member('Ana'),
      isMine: isOwner,
    ),
    other: member(isOwner ? 'Luis' : 'Ana'),
    isOwner: isOwner,
    request: requestStatus == null
        ? null
        : ListingRequest(listingId: 1, requesterId: 2, status: requestStatus),
  );

  ChatMessage message(int id, DateTime createdAt, {String text = 'Hola'}) =>
      ChatMessage(
        id: id,
        conversationId: 7,
        senderId: 1,
        text: text,
        createdAt: createdAt,
      );

  group('mergeMessages', () {
    test('dedupes by id and sorts oldest first', () {
      final t = DateTime.utc(2026, 10, 1, 12);
      final merged = mergeMessages(
        [message(2, t.add(const Duration(minutes: 1))), message(1, t)],
        [
          message(2, t.add(const Duration(minutes: 1)), text: 'Editado'),
          message(3, t.add(const Duration(minutes: 2))),
        ],
      );
      expect(merged.map((m) => m.id), [1, 2, 3]);
      expect(merged[1].text, 'Editado');
    });

    test('breaks createdAt ties by id', () {
      final t = DateTime.utc(2026, 10, 1, 12);
      final merged = mergeMessages([message(5, t)], [message(4, t)]);
      expect(merged.map((m) => m.id), [4, 5]);
    });
  });

  group('isConversationClosed', () {
    test('open while the listing is available and the request pending', () {
      expect(isConversationClosed(view()), isFalse);
    });

    test('closed when the listing was withdrawn', () {
      expect(
        isConversationClosed(view(status: ListingStatus.withdrawn)),
        isTrue,
      );
    });

    test('closed when the request was rejected', () {
      expect(
        isConversationClosed(view(requestStatus: RequestStatus.rejected)),
        isTrue,
      );
    });
  });

  group('quickRepliesFor', () {
    test('requester on an available listing', () {
      expect(quickRepliesFor(view()), [
        QuickReply.proposeSafePoint,
        QuickReply.stillAvailable,
      ]);
    });

    test('owner of a reserved listing with the accepted request', () {
      expect(
        quickRepliesFor(
          view(
            isOwner: true,
            status: ListingStatus.reserved,
            requestStatus: RequestStatus.accepted,
          ),
        ),
        [QuickReply.proposeSafePoint, QuickReply.markDelivered],
      );
    });

    test('owner of a listing reserved for someone else', () {
      expect(
        quickRepliesFor(
          view(isOwner: true, status: ListingStatus.reserved),
        ),
        [QuickReply.proposeSafePoint],
      );
    });

    test('nothing once delivered or closed', () {
      expect(quickRepliesFor(view(status: ListingStatus.delivered)), isEmpty);
      expect(
        quickRepliesFor(view(requestStatus: RequestStatus.rejected)),
        isEmpty,
      );
    });
  });

  group('listingSubtitle', () {
    test('food shows the expiry date', () {
      final subtitle = listingSubtitle(
        listing(expiresAt: DateTime(2026, 11, 12, 12)),
      );
      expect(subtitle, startsWith('Donar · Vence 12'));
      expect(subtitle, endsWith('2026'));
    });

    test('a sale shows the price', () {
      expect(
        listingSubtitle(listing(type: ListingType.sell, price: 20000)),
        'Vender · \$ 20.000',
      );
    });

    test('a loan shows the return date', () {
      expect(
        listingSubtitle(
          listing(type: ListingType.lend, returnDate: DateTime(2026, 12, 1)),
        ),
        startsWith('Prestar · Hasta 1'),
      );
    });

    test('otherwise only the type', () {
      expect(
        listingSubtitle(listing(type: ListingType.exchange)),
        'Intercambiar',
      );
    });
  });

  group('formatMessageTime', () {
    final now = DateTime(2026, 10, 29, 18);

    test('today shows the time only', () {
      expect(
        formatMessageTime(DateTime(2026, 10, 29, 9, 5), now: now),
        '09:05',
      );
    });

    test('yesterday', () {
      expect(
        formatMessageTime(DateTime(2026, 10, 28, 23, 59), now: now),
        'Ayer 23:59',
      );
    });

    test('older shows day and month', () {
      expect(
        formatMessageTime(DateTime(2026, 10, 3, 14, 0), now: now),
        '03/10 14:00',
      );
    });
  });

  test('formatRating uses a decimal comma', () {
    expect(formatRating(4.75), '4,8');
    expect(formatRating(0), '0,0');
  });
}
