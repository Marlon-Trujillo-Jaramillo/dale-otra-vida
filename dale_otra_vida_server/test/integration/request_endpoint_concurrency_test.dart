import 'dart:math' as math;
import 'dart:typed_data';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import 'package:dale_otra_vida_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  // Rollbacks are disabled so both endpoint calls run as real, concurrent
  // database transactions on separate pool connections: the FOR UPDATE row
  // locks are exercised for real. Each group gets its own database and every
  // test creates fresh rows, so the committed state never leaks between
  // tests.
  withServerpod(
    'Given Request endpoint under concurrency',
    (sessionBuilder, endpoints) {
      late TestSessionBuilder memberA;
      late TestSessionBuilder memberB;
      late TestSessionBuilder memberC;
      late MemberProfile profileA;

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
        await endpoints.profile.saveMe(memberB, displayName: 'Luis');

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
        await endpoints.profile.saveMe(memberC, displayName: 'Caro');
      });

      String testUuidV4() {
        final random = math.Random.secure();
        final bytes = List<int>.generate(16, (_) => random.nextInt(256));
        bytes[6] = (bytes[6] & 0x0F) | 0x40;
        bytes[8] = (bytes[8] & 0x3F) | 0x80;
        final hex = bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join();
        return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
            '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
      }

      Future<ListingView> createOwnedListing() async {
        final path = 'listings/${profileA.id!}/${testUuidV4()}.jpg';
        final session = memberA.build();
        await session.storage.storeFile(
          storageId: 'public',
          path: path,
          byteData: ByteData(8),
        );
        return endpoints.listing.create(
          memberA,
          Listing(
            ownerId: profileA.id!,
            title: 'Título de prueba',
            description: 'Descripción de prueba suficientemente larga.',
            type: ListingType.donate,
            category: Category.books,
            condition: ItemCondition.good,
            photoUrls: [path],
            neighborhood: 'Robledo',
            latitude: 6.25,
            longitude: -75.56,
          ),
        );
      }

      /// Runs [call] and returns its value, or the error it threw.
      Future<Object> capture(Future<Object> Function() call) async {
        try {
          return await call();
        } catch (e) {
          return e;
        }
      }

      group('when two accepts race on different pending requests', () {
        test(
          'exactly one wins, the loser throws NotAllowedException and the listing ends reserved',
          () async {
            final listing = await createOwnedListing();
            final requestB = await endpoints.request.create(
              memberB,
              listing.listing.id!,
            );
            final requestC = await endpoints.request.create(
              memberC,
              listing.listing.id!,
            );

            final results = await Future.wait([
              capture(() => endpoints.request.accept(memberA, requestB.id!)),
              capture(() => endpoints.request.accept(memberA, requestC.id!)),
            ]);

            final winners = results.whereType<ListingRequest>().toList();
            final losers = results.whereType<NotAllowedException>().toList();
            expect(winners, hasLength(1));
            expect(losers, hasLength(1));
            expect(losers.single.message, 'Esta publicación ya fue reservada.');
            expect(winners.single.status, RequestStatus.accepted);

            final listingRow = await Listing.db.findById(
              sessionBuilder.build(),
              listing.listing.id!,
            );
            expect(listingRow!.status, ListingStatus.reserved);

            final accepted = await ListingRequest.db.find(
              sessionBuilder.build(),
              where: (t) =>
                  t.listingId.equals(listing.listing.id!) &
                  t.status.equals(RequestStatus.accepted),
            );
            expect(accepted, hasLength(1));

            // The loser's request was auto-rejected by the winner.
            final loserRequestId = winners.single.id == requestB.id
                ? requestC.id!
                : requestB.id!;
            final loserRequest = await ListingRequest.db.findById(
              sessionBuilder.build(),
              loserRequestId,
            );
            expect(loserRequest!.status, RequestStatus.rejected);
          },
        );
      });

      group('when an accept and a cancel race on the same request', () {
        test('the final state is consistent, never mixed', () async {
          final listing = await createOwnedListing();
          final requestB = await endpoints.request.create(
            memberB,
            listing.listing.id!,
          );

          final results = await Future.wait([
            capture(() => endpoints.request.accept(memberA, requestB.id!)),
            capture(() => endpoints.request.cancel(memberB, requestB.id!)),
          ]);
          // Either call may legitimately throw; both futures must settle.
          expect(results, hasLength(2));

          final requestRow = await ListingRequest.db.findById(
            sessionBuilder.build(),
            requestB.id!,
          );
          final listingRow = await Listing.db.findById(
            sessionBuilder.build(),
            listing.listing.id!,
          );

          final acceptedAndReserved =
              requestRow!.status == RequestStatus.accepted &&
              listingRow!.status == ListingStatus.reserved;
          final cancelledAndAvailable =
              requestRow.status == RequestStatus.cancelled &&
              listingRow!.status == ListingStatus.available;
          expect(
            acceptedAndReserved || cancelledAndAvailable,
            isTrue,
            reason:
                'expected accepted+reserved or cancelled+available, got '
                '${requestRow.status} + ${listingRow!.status}',
          );
        });
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
