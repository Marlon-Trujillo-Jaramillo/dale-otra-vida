import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';

enum RequesterActionState {
  canRequest,
  pending,
  accepted,
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
    return RequesterActionState.accepted;
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
