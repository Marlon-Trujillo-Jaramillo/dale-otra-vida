import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/features/listing/listing_detail_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MemberProfile fakeOwner() => MemberProfile(
    authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    displayName: 'Dueño',
  );

  ListingView buildView({
    required ListingStatus listingStatus,
    RequestStatus? requestStatus,
    bool isMine = false,
  }) {
    return ListingView(
      listing: Listing(
        ownerId: 1,
        title: 'Silla',
        description: 'Una silla.',
        type: ListingType.donate,
        category: Category.furniture,
        condition: ItemCondition.good,
        photoUrls: const [],
        neighborhood: 'Laureles',
        latitude: 6.2,
        longitude: -75.5,
        status: listingStatus,
      ),
      owner: fakeOwner(),
      isMine: isMine,
      myRequest: requestStatus == null
          ? null
          : ListingRequest(
              listingId: 1,
              requesterId: 2,
              status: requestStatus,
            ),
    );
  }

  group('requesterActionState', () {
    test('available listing with no request returns canRequest', () {
      final view = buildView(listingStatus: ListingStatus.available);
      expect(requesterActionState(view), RequesterActionState.canRequest);
    });

    test('cancelled request on available listing returns canRequest', () {
      final view = buildView(
        listingStatus: ListingStatus.available,
        requestStatus: RequestStatus.cancelled,
      );
      expect(requesterActionState(view), RequesterActionState.canRequest);
    });

    test('pending request returns pending', () {
      final view = buildView(
        listingStatus: ListingStatus.available,
        requestStatus: RequestStatus.pending,
      );
      expect(requesterActionState(view), RequesterActionState.pending);
    });

    test('accepted request returns accepted', () {
      final view = buildView(
        listingStatus: ListingStatus.reserved,
        requestStatus: RequestStatus.accepted,
      );
      expect(requesterActionState(view), RequesterActionState.accepted);
    });

    test('rejected request returns rejected', () {
      final view = buildView(
        listingStatus: ListingStatus.available,
        requestStatus: RequestStatus.rejected,
      );
      expect(requesterActionState(view), RequesterActionState.rejected);
    });

    test(
      'unavailable listing with no accepted request returns unavailable',
      () {
        final view = buildView(listingStatus: ListingStatus.reserved);
        expect(requesterActionState(view), RequesterActionState.unavailable);
      },
    );

    test('cancelled request on reserved listing returns unavailable', () {
      final view = buildView(
        listingStatus: ListingStatus.reserved,
        requestStatus: RequestStatus.cancelled,
      );
      expect(requesterActionState(view), RequesterActionState.unavailable);
    });
  });
}
