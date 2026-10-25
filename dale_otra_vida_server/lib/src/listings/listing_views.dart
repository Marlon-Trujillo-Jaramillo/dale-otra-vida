import 'package:serverpod/serverpod.dart';

import '../common/geo.dart';
import '../generated/protocol.dart';

/// Builds the public view of a single listing for [caller].
Future<ListingView> toView(
  Session session,
  Listing listing,
  MemberProfile caller, {
  double? latitude,
  double? longitude,
}) async {
  final views = await toViews(
    session,
    [listing],
    caller,
    latitude: latitude,
    longitude: longitude,
  );
  return views.first;
}

/// Builds the public views of several listings for [caller] with batched
/// queries: owners without coordinates, resolved photo URLs, the caller's
/// own request on each listing, and the pending request count on the
/// caller's own listings.
Future<List<ListingView>> toViews(
  Session session,
  List<Listing> listings,
  MemberProfile caller, {
  double? latitude,
  double? longitude,
}) async {
  final ownerIds = listings.map((l) => l.ownerId).toSet();
  final owners = ownerIds.isEmpty
      ? <MemberProfile>[]
      : await MemberProfile.db.find(
          session,
          where: (t) => t.id.inSet(ownerIds),
        );
  final ownerById = {
    for (final owner in owners)
      owner.id!: owner.copyWith(latitude: null, longitude: null),
  };

  // The caller's request on each listing, whatever its status.
  final listingIds = listings.map((l) => l.id!).toSet();
  final myRequests = listingIds.isEmpty
      ? <ListingRequest>[]
      : await ListingRequest.db.find(
          session,
          where: (t) =>
              t.listingId.inSet(listingIds) & t.requesterId.equals(caller.id!),
        );
  final myRequestByListingId = {
    for (final request in myRequests) request.listingId: request,
  };

  // Pending requests only matter on the caller's own listings.
  final ownListingIds = listings
      .where((l) => l.ownerId == caller.id)
      .map((l) => l.id!)
      .toSet();
  final pendingRequests = ownListingIds.isEmpty
      ? <ListingRequest>[]
      : await ListingRequest.db.find(
          session,
          where: (t) =>
              t.listingId.inSet(ownListingIds) &
              t.status.equals(RequestStatus.pending),
        );
  final pendingCountByListingId = <int, int>{};
  for (final request in pendingRequests) {
    pendingCountByListingId[request.listingId] =
        (pendingCountByListingId[request.listingId] ?? 0) + 1;
  }

  return Future.wait(
    listings.map((listing) async {
      final photoUrls = await Future.wait(
        listing.photoUrls.map((path) async {
          final uri = await session.storage.publicDownloadUrl(
            storageId: 'public',
            path: path,
          );
          return uri.toString();
        }),
      );

      double? distanceKm;
      if (latitude != null && longitude != null) {
        distanceKm = haversineKm(
          latitude,
          longitude,
          listing.latitude,
          listing.longitude,
        );
      }

      return ListingView(
        listing: listing.copyWith(photoUrls: photoUrls),
        owner: ownerById[listing.ownerId]!,
        distanceKm: distanceKm,
        isMine: listing.ownerId == caller.id,
        myRequest: myRequestByListingId[listing.id],
        pendingRequestCount: pendingCountByListingId[listing.id] ?? 0,
      );
    }),
  );
}
