import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';

enum RequesterActionState {
  canRequest,
  pending,
  accepted,

  /// Accepted and then delivered: nothing left to cancel.
  delivered,
  rejected,
  unavailable,
}

RequesterActionState requesterActionState(ListingView view) {
  final listing = view.listing;
  final myRequest = view.myRequest;

  final status = myRequest?.status;

  if (status == RequestStatus.pending) {
    return RequesterActionState.pending;
  }
  if (status == RequestStatus.accepted) {
    return listing.status == ListingStatus.delivered
        ? RequesterActionState.delivered
        : RequesterActionState.accepted;
  }
  if (status == RequestStatus.rejected) {
    return RequesterActionState.rejected;
  }

  // No request or cancelled: depends on listing availability.
  if (listing.status == ListingStatus.available) {
    return RequesterActionState.canRequest;
  }

  return RequesterActionState.unavailable;
}

/// Food past its expiry date is hidden from the feed.
bool isExpired(Listing listing, {DateTime? now}) {
  final expiresAt = listing.expiresAt;
  if (listing.category != Category.food || expiresAt == null) return false;
  return !expiresAt.isAfter(now ?? DateTime.now());
}

/// Pill shown on the owner's own listing cards, or null when it is visible
/// in the feed as usual.
/// Card label of a delivered loan: "Prestado", "Vencido", "Devuelto" or
/// "No devuelto". Null for anything else.
String? loanShortLabel(Listing listing, {DateTime? now}) {
  if (listing.type != ListingType.lend ||
      listing.status != ListingStatus.delivered) {
    return null;
  }
  return switch (listing.loanOutcome) {
    LoanOutcome.returned => 'Devuelto',
    LoanOutcome.notReturned => 'No devuelto',
    null =>
      listing.returnDate != null &&
              !listing.returnDate!.isAfter(now ?? DateTime.now())
          ? 'Vencido'
          : 'Prestado',
  };
}

String? ownListingLabel(Listing listing, {DateTime? now}) {
  return switch (listing.status) {
    ListingStatus.reserved => 'Reservado',
    ListingStatus.delivered => loanShortLabel(listing, now: now) ?? 'Entregado',
    ListingStatus.withdrawn => 'Retirado',
    ListingStatus.available => isExpired(listing, now: now) ? 'Vencida' : null,
  };
}
