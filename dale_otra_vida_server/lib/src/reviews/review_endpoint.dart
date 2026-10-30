import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';
import '../notifications/notify.dart';

/// Ratings that the owner and the receiver leave each other after a delivery.
class ReviewEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Rates the other side of a delivered listing, once per listing.
  Future<Review> create(
    Session session,
    int listingId,
    int rating, {
    String? comment,
  }) async {
    final profile = await currentProfile(session);

    if (rating < 1 || rating > 5) {
      throw NotAllowedException(
        message: 'La calificación debe estar entre 1 y 5.',
      );
    }
    var text = comment?.trim();
    if (text != null && text.isEmpty) text = null;
    if (text != null && text.length > 300) {
      throw NotAllowedException(
        message: 'El comentario no puede superar los 300 caracteres.',
      );
    }

    return await session.db.transaction((transaction) async {
      final listing = await Listing.db.findById(
        session,
        listingId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (listing == null || listing.status != ListingStatus.delivered) {
        throw NotAllowedException(
          message: 'Solo puedes calificar entregas completadas.',
        );
      }

      final revieweeId = await reviewTarget(
        session,
        listing,
        profile.id!,
        transaction: transaction,
      );
      if (revieweeId == null) {
        throw NotAllowedException(
          message: 'No participaste en esta entrega.',
        );
      }

      final existing = await Review.db.findFirstRow(
        session,
        where: (t) =>
            t.listingId.equals(listingId) & t.reviewerId.equals(profile.id!),
        transaction: transaction,
      );
      if (existing != null) {
        throw NotAllowedException(message: 'Ya calificaste esta entrega.');
      }

      final review = await Review.db.insertRow(
        session,
        Review(
          listingId: listingId,
          reviewerId: profile.id!,
          revieweeId: revieweeId,
          rating: rating,
          comment: text,
        ),
        transaction: transaction,
      );

      final reviewee = await MemberProfile.db.findById(
        session,
        revieweeId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (reviewee != null) {
        final count = reviewee.reviewCount + 1;
        await MemberProfile.db.updateRow(
          session,
          reviewee.copyWith(
            reviewCount: count,
            ratingAvg:
                (reviewee.ratingAvg * reviewee.reviewCount + rating) / count,
          ),
          columns: (t) => [t.reviewCount, t.ratingAvg],
          transaction: transaction,
        );
      }

      await notify(
        session,
        userId: revieweeId,
        kind: NotificationKind.newReview,
        title: 'Nueva reseña',
        body:
            '${profile.displayName} te calificó con $rating '
            '${rating == 1 ? 'estrella' : 'estrellas'} por «${listing.title}».',
        refId: profile.id,
        transaction: transaction,
      );

      return review;
    });
  }

  /// Newest reviews received by a member.
  Future<List<ReviewView>> forMember(
    Session session,
    int profileId, {
    int? limit,
    int? offset,
  }) async {
    return reviewViews(
      session,
      profileId,
      limit: (limit ?? 20).clamp(1, 50),
      offset: (offset ?? 0) < 0 ? 0 : offset ?? 0,
    );
  }
}

/// The member [callerId] reviews on a delivered [listing]: the receiver
/// for the owner, the owner for the receiver; null for anyone else.
Future<int?> reviewTarget(
  Session session,
  Listing listing,
  int callerId, {
  Transaction? transaction,
}) async {
  final accepted = await ListingRequest.db.findFirstRow(
    session,
    where: (t) =>
        t.listingId.equals(listing.id!) &
        t.status.equals(RequestStatus.accepted),
    transaction: transaction,
  );
  if (accepted == null) return null;
  if (callerId == listing.ownerId) return accepted.requesterId;
  if (callerId == accepted.requesterId) return listing.ownerId;
  return null;
}

/// Reviews received by [profileId] with the reviewers' public profiles.
Future<List<ReviewView>> reviewViews(
  Session session,
  int profileId, {
  int limit = 20,
  int offset = 0,
}) async {
  final reviews = await Review.db.find(
    session,
    where: (t) => t.revieweeId.equals(profileId),
    orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
    limit: limit,
    offset: offset,
  );
  if (reviews.isEmpty) return [];

  final reviewers = await MemberProfile.db.find(
    session,
    where: (t) => t.id.inSet(reviews.map((r) => r.reviewerId).toSet()),
  );
  final reviewerById = {
    for (final reviewer in reviewers)
      reviewer.id!: reviewer.copyWith(latitude: null, longitude: null),
  };

  return [
    for (final review in reviews)
      if (reviewerById[review.reviewerId] != null)
        ReviewView(review: review, reviewer: reviewerById[review.reviewerId]!),
  ];
}
