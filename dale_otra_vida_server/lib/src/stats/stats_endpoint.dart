import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Community-wide impact numbers.
class StatsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CommunityImpact> community(Session session) async {
    final now = DateTime.now().toUtc();
    return CommunityImpact(
      deliveredCount: await Listing.db.count(
        session,
        where: (t) => t.status.equals(ListingStatus.delivered),
      ),
      foodSavedCount: await Listing.db.count(
        session,
        where: (t) =>
            t.status.equals(ListingStatus.delivered) &
            t.category.equals(Category.food),
      ),
      activeCount: await Listing.db.count(
        session,
        where: (t) =>
            t.status.equals(ListingStatus.available) &
            (t.category.notEquals(Category.food) | (t.expiresAt > now)),
      ),
      memberCount: await MemberProfile.db.count(session),
    );
  }
}
