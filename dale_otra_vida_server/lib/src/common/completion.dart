import '../generated/protocol.dart';

/// Whether a listing's exchange is over and both sides can rate it: once it
/// was handed over, and for a loan only once the owner closed it (returned
/// or not returned).
bool isCompletedDelivery(Listing listing) =>
    listing.status == ListingStatus.delivered &&
    (listing.type != ListingType.lend || listing.loanOutcome != null);
