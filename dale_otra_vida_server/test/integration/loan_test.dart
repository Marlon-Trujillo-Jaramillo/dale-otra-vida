import 'dart:math' as math;
import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given loans', (sessionBuilder, endpoints) {
    late TestSessionBuilder owner;
    late TestSessionBuilder requester;
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

    Future<Listing> loanDraft({
      Duration returnIn = const Duration(days: 7),
      int? deposit = 50000,
      int? fee = 2000,
    }) async {
      final path = 'listings/${ownerProfile.id}/${uuid()}.jpg';
      await owner.build().storage.storeFile(
        storageId: 'public',
        path: path,
        byteData: ByteData(8),
      );
      return Listing(
        ownerId: 0,
        title: 'Taladro',
        description: 'Taladro percutor con brocas, en buen estado.',
        type: ListingType.lend,
        category: Category.tools,
        condition: ItemCondition.good,
        photoUrls: [path],
        neighborhood: 'Laureles',
        latitude: 6.25,
        longitude: -75.59,
        returnDate: DateTime.now().toUtc().add(returnIn),
        depositAmount: deposit,
        lateFeePerDay: fee,
        loanConditions: '  Devolver limpio  ',
      );
    }

    /// Publishes a loan, has the requester accept its terms and the owner
    /// accept and hand it over.
    Future<ListingView> lentListing({
      Duration returnIn = const Duration(days: 7),
    }) async {
      final view = await endpoints.listing.create(
        owner,
        await loanDraft(returnIn: returnIn),
      );
      final request = await endpoints.request.create(
        requester,
        view.listing.id!,
        acceptTerms: true,
      );
      await endpoints.request.accept(owner, request.id!);
      return endpoints.listing.updateStatus(
        owner,
        view.listing.id!,
        ListingStatus.delivered,
      );
    }

    late MemberProfile requesterProfile;

    setUp(() async {
      (owner, ownerProfile) = await member('Ana');
      (requester, requesterProfile) = await member('Luis');
      // Loans need a reviewed identity (see identity_test.dart).
      await MemberProfile.db.updateRow(
        sessionBuilder.build(),
        requesterProfile.copyWith(isVerified: true),
      );
    });

    test('publishing stores the terms and checks them', () async {
      final view = await endpoints.listing.create(owner, await loanDraft());
      expect(view.listing.depositAmount, 50000);
      expect(view.listing.lateFeePerDay, 2000);
      expect(view.listing.loanConditions, 'Devolver limpio');

      final invalid = throwsA(isA<ArgumentError>());
      await expectLater(
        endpoints.listing.create(
          owner,
          await loanDraft(returnIn: const Duration(days: 40)),
        ),
        invalid,
      );
      await expectLater(
        endpoints.listing.create(owner, await loanDraft(deposit: 1000)),
        invalid,
      );
    });

    test('asking for a loan requires a verified identity', () async {
      final view = await endpoints.listing.create(owner, await loanDraft());
      final (stranger, _) = await member('Caro');
      await expectLater(
        endpoints.request.create(stranger, view.listing.id!, acceptTerms: true),
        throwsA(isA<NotAllowedException>()),
      );
    });

    test('asking for a loan requires accepting its terms', () async {
      final view = await endpoints.listing.create(owner, await loanDraft());
      await expectLater(
        endpoints.request.create(requester, view.listing.id!),
        throwsA(isA<NotAllowedException>()),
      );
      final request = await endpoints.request.create(
        requester,
        view.listing.id!,
        acceptTerms: true,
      );
      expect(request.acceptedTermsAt, isNotNull);
    });

    test('a loan is rated only once the owner closes it', () async {
      final lent = await lentListing();
      final id = lent.listing.id!;

      expect(await endpoints.review.pending(owner), isEmpty);
      await expectLater(
        endpoints.review.create(requester, id, 5),
        throwsA(isA<NotAllowedException>()),
      );

      final closed = await endpoints.listing.closeLoan(
        owner,
        id,
        LoanOutcome.returned,
      );
      expect(closed.listing.loanOutcome, LoanOutcome.returned);
      expect(await endpoints.review.pending(owner), hasLength(1));
      expect(await endpoints.review.pending(requester), hasLength(1));
      await endpoints.review.create(requester, id, 5);

      await expectLater(
        endpoints.listing.closeLoan(owner, id, LoanOutcome.notReturned),
        throwsA(isA<NotAllowedException>()),
      );
    });

    test('only the owner closes a loan', () async {
      final lent = await lentListing();
      await expectLater(
        endpoints.listing.closeLoan(
          requester,
          lent.listing.id!,
          LoanOutcome.returned,
        ),
        throwsA(isA<NotAllowedException>()),
      );
    });

    test('a loan due tomorrow reminds both sides once', () async {
      final lent = await lentListing(returnIn: const Duration(hours: 12));

      await endpoints.notification.unreadCount(requester);
      await endpoints.notification.unreadCount(requester);
      await endpoints.notification.unreadCount(owner);

      Future<int> dueSoon(TestSessionBuilder who) async =>
          (await endpoints.notification.list(who, limit: 50, offset: 0))
              .where(
                (n) =>
                    n.kind == NotificationKind.loanDueSoon &&
                    n.refId == lent.listing.id,
              )
              .length;
      expect(await dueSoon(requester), 1);
      expect(await dueSoon(owner), 1);
    });
  });
}
