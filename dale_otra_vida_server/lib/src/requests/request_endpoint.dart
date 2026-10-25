import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';
import '../listings/listing_views.dart';
import '../notifications/notify.dart';

/// "Lo quiero" requests on listings.
class RequestEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates or reopens a request on an available listing.
  ///
  /// Ensures a conversation with the owner exists, stores a system message
  /// (plus the optional [message]) and notifies the owner. An existing
  /// pending or accepted request is returned unchanged; a cancelled one is
  /// reopened with a fresh createdAt and only the new [message] (null if
  /// none), never the old one.
  Future<ListingRequest> create(
    Session session,
    int listingId, {
    String? message,
  }) async {
    final profile = await currentProfile(session);

    var text = message?.trim();
    if (text != null && text.isEmpty) text = null;
    if (text != null && text.length > 300) {
      throw ArgumentError('El mensaje no puede superar los 300 caracteres.');
    }

    return await session.db.transaction((transaction) async {
      // Always lock the listing row first.
      final listing = await Listing.db.findById(
        session,
        listingId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (listing == null) {
        throw ArgumentError('Publicación no encontrada.');
      }
      if (listing.status != ListingStatus.available) {
        throw ArgumentError('La publicación no está disponible.');
      }
      if (listing.ownerId == profile.id!) {
        throw NotAllowedException(
          message: 'No puedes pedir tu propia publicación.',
        );
      }

      final existing = await ListingRequest.db.findFirstRow(
        session,
        where: (t) =>
            t.listingId.equals(listingId) & t.requesterId.equals(profile.id!),
        transaction: transaction,
      );
      if (existing != null) {
        if (existing.status == RequestStatus.pending ||
            existing.status == RequestStatus.accepted) {
          return existing;
        }
        if (existing.status == RequestStatus.rejected) {
          throw NotAllowedException(
            message: 'El dueño ya respondió a tu solicitud.',
          );
        }
        // A cancelled request is reopened below with a fresh createdAt.
      }

      final now = DateTime.now().toUtc();

      // Ensure a conversation between the owner and the requester exists.
      var conversation = await Conversation.db.findFirstRow(
        session,
        where: (t) =>
            t.listingId.equals(listingId) & t.requesterId.equals(profile.id!),
        transaction: transaction,
      );
      conversation ??= await Conversation.db.insertRow(
        session,
        Conversation(
          listingId: listingId,
          ownerId: listing.ownerId,
          requesterId: profile.id!,
        ),
        transaction: transaction,
      );

      var lastMessage = await ChatMessage.db.insertRow(
        session,
        ChatMessage(
          conversationId: conversation.id!,
          senderId: null,
          kind: MessageKind.system,
          text: '${profile.displayName} quiere esta publicación.',
          createdAt: now,
        ),
        transaction: transaction,
      );
      if (text != null) {
        lastMessage = await ChatMessage.db.insertRow(
          session,
          ChatMessage(
            conversationId: conversation.id!,
            senderId: profile.id,
            kind: MessageKind.text,
            text: text,
            createdAt: now,
          ),
          transaction: transaction,
        );
      }

      await Conversation.db.updateRow(
        session,
        conversation.copyWith(
          lastMessageAt: lastMessage.createdAt,
          lastMessagePreview: lastMessage.text,
        ),
        transaction: transaction,
      );

      final request = existing == null
          ? await ListingRequest.db.insertRow(
              session,
              ListingRequest(
                listingId: listingId,
                requesterId: profile.id!,
                message: text,
                createdAt: now,
              ),
              transaction: transaction,
            )
          : await ListingRequest.db.updateRow(
              session,
              existing.copyWith(
                status: RequestStatus.pending,
                createdAt: now,
                message: text,
              ),
              transaction: transaction,
            );

      await notify(
        session,
        userId: listing.ownerId,
        kind: NotificationKind.newRequest,
        title: 'Nueva solicitud',
        body: '${profile.displayName} quiere «${listing.title}»',
        refId: listingId,
        transaction: transaction,
      );

      return request;
    });
  }

  /// Returns the newest 100 requests on one of the caller's listings,
  /// pending first and then newest first, with the requester's public
  /// profile and the chat conversation id.
  Future<List<RequestView>> forListing(Session session, int listingId) async {
    final profile = await currentProfile(session);

    final listing = await Listing.db.findById(session, listingId);
    if (listing == null) {
      throw ArgumentError('Publicación no encontrada.');
    }
    if (listing.ownerId != profile.id!) {
      throw NotAllowedException(
        message: 'No eres el dueño de esta publicación.',
      );
    }

    final requests = await ListingRequest.db.find(
      session,
      where: (t) => t.listingId.equals(listingId),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: 100,
    );

    final requesterIds = requests.map((r) => r.requesterId).toSet();
    final requesters = requesterIds.isEmpty
        ? <MemberProfile>[]
        : await MemberProfile.db.find(
            session,
            where: (t) => t.id.inSet(requesterIds),
          );
    final requesterById = {
      for (final requester in requesters)
        requester.id!: requester.copyWith(latitude: null, longitude: null),
    };

    final conversations = await Conversation.db.find(
      session,
      where: (t) => t.listingId.equals(listingId),
    );
    final conversationIdByRequesterId = {
      for (final conversation in conversations)
        conversation.requesterId: conversation.id,
    };

    final views = [
      for (final request in requests)
        RequestView(
          request: request,
          requester: requesterById[request.requesterId]!,
          conversationId: conversationIdByRequesterId[request.requesterId],
        ),
    ];

    int statusRank(RequestStatus status) =>
        status == RequestStatus.pending ? 0 : 1;

    views.sort((a, b) {
      final byStatus =
          statusRank(a.request.status) - statusRank(b.request.status);
      if (byStatus != 0) return byStatus;
      final byCreated = b.request.createdAt.compareTo(a.request.createdAt);
      if (byCreated != 0) return byCreated;
      return b.request.id!.compareTo(a.request.id!);
    });

    return views;
  }

  /// Returns the newest 100 requests of the caller, newest first, with the
  /// listing view and the chat conversation id.
  Future<List<MyRequestView>> mine(Session session) async {
    final profile = await currentProfile(session);

    final requests = await ListingRequest.db.find(
      session,
      where: (t) => t.requesterId.equals(profile.id!),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: 100,
    );
    if (requests.isEmpty) return [];

    final listingIds = requests.map((r) => r.listingId).toSet();
    final listings = await Listing.db.find(
      session,
      where: (t) => t.id.inSet(listingIds),
    );
    final listingViews = await toViews(session, listings, profile);
    final listingViewById = {
      for (final view in listingViews) view.listing.id!: view,
    };

    final conversations = await Conversation.db.find(
      session,
      where: (t) =>
          t.listingId.inSet(listingIds) & t.requesterId.equals(profile.id!),
    );
    final conversationIdByListingId = {
      for (final conversation in conversations)
        conversation.listingId: conversation.id,
    };

    return [
      for (final request in requests)
        MyRequestView(
          request: request,
          listing: listingViewById[request.listingId]!,
          conversationId: conversationIdByListingId[request.listingId],
        ),
    ];
  }

  /// Accepts a pending request, reserves the listing and rejects every
  /// other pending request on it.
  ///
  /// Throws [NotAllowedException] when another request on the listing was
  /// already accepted while this call waited for the listing lock.
  Future<ListingRequest> accept(Session session, int requestId) async {
    final profile = await currentProfile(session);

    return await session.db.transaction((transaction) async {
      // Unlocked read to find which listing to lock.
      final initial = await ListingRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
      );
      if (initial == null) {
        throw ArgumentError('Solicitud no encontrada.');
      }

      // Always lock the listing row first.
      final listing = await _ownedListing(
        session,
        initial,
        profile,
        transaction,
      );

      // Re-read the request under lock and validate the fresh rows.
      final request = await ListingRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (request == null) {
        throw ArgumentError('Solicitud no encontrada.');
      }

      // While we waited for the listing lock another request may have
      // been accepted on this listing. This check runs before the own
      // status check so the loser of a double accept reports the
      // reservation, not its auto-rejected request.
      final otherAccepted = await ListingRequest.db.findFirstRow(
        session,
        where: (t) =>
            t.listingId.equals(listing.id!) &
            t.status.equals(RequestStatus.accepted) &
            t.id.notEquals(requestId),
        transaction: transaction,
      );
      if (otherAccepted != null) {
        throw NotAllowedException(
          message: 'Esta publicación ya fue reservada.',
        );
      }

      if (request.status != RequestStatus.pending) {
        throw ArgumentError('La solicitud ya fue respondida.');
      }
      if (listing.status != ListingStatus.available) {
        throw ArgumentError('La publicación no está disponible.');
      }

      final now = DateTime.now().toUtc();

      final accepted = await ListingRequest.db.updateRow(
        session,
        request.copyWith(status: RequestStatus.accepted),
        transaction: transaction,
      );

      await Listing.db.updateRow(
        session,
        listing.copyWith(status: ListingStatus.reserved, updatedAt: now),
        transaction: transaction,
      );

      final others = await ListingRequest.db.find(
        session,
        where: (t) =>
            t.listingId.equals(listing.id!) &
            t.status.equals(RequestStatus.pending) &
            t.id.notEquals(requestId),
        transaction: transaction,
      );
      for (final other in others) {
        await ListingRequest.db.updateRow(
          session,
          other.copyWith(status: RequestStatus.rejected),
          transaction: transaction,
        );
      }

      // System message in the accepted conversation.
      final conversation = await Conversation.db.findFirstRow(
        session,
        where: (t) =>
            t.listingId.equals(listing.id!) &
            t.requesterId.equals(request.requesterId),
        transaction: transaction,
      );
      if (conversation != null) {
        final systemMessage = await ChatMessage.db.insertRow(
          session,
          ChatMessage(
            conversationId: conversation.id!,
            senderId: null,
            kind: MessageKind.system,
            text:
                '${profile.displayName} reservó esta publicación para ti. '
                'Acuerden un punto de encuentro seguro.',
            createdAt: now,
          ),
          transaction: transaction,
        );
        await Conversation.db.updateRow(
          session,
          conversation.copyWith(
            lastMessageAt: systemMessage.createdAt,
            lastMessagePreview: systemMessage.text,
          ),
          transaction: transaction,
        );
      }

      await notify(
        session,
        userId: request.requesterId,
        kind: NotificationKind.requestAccepted,
        title: '¡Te lo reservaron!',
        body: 'Coordina la entrega de «${listing.title}» por el chat.',
        refId: listing.id,
        transaction: transaction,
      );
      for (final other in others) {
        await notify(
          session,
          userId: other.requesterId,
          kind: NotificationKind.requestRejected,
          title: 'Solicitud no disponible',
          body: '«${listing.title}» fue reservado para otra persona.',
          refId: listing.id,
          transaction: transaction,
        );
      }

      return accepted;
    });
  }

  /// Rejects a pending request on one of the caller's listings.
  Future<ListingRequest> reject(Session session, int requestId) async {
    final profile = await currentProfile(session);

    return await session.db.transaction((transaction) async {
      // Unlocked read to find which listing to lock.
      final initial = await ListingRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
      );
      if (initial == null) {
        throw ArgumentError('Solicitud no encontrada.');
      }

      // Always lock the listing row first.
      final listing = await _ownedListing(
        session,
        initial,
        profile,
        transaction,
      );

      // Re-read the request under lock and validate the fresh row.
      final request = await ListingRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (request == null) {
        throw ArgumentError('Solicitud no encontrada.');
      }

      if (request.status != RequestStatus.pending) {
        throw ArgumentError('La solicitud ya fue respondida.');
      }

      await notify(
        session,
        userId: request.requesterId,
        kind: NotificationKind.requestRejected,
        title: 'Solicitud rechazada',
        body: 'El dueño eligió a otra persona para «${listing.title}».',
        refId: listing.id,
        transaction: transaction,
      );

      return ListingRequest.db.updateRow(
        session,
        request.copyWith(status: RequestStatus.rejected),
        transaction: transaction,
      );
    });
  }

  /// Cancels one of the caller's requests. Cancelling an accepted request
  /// makes the listing available again and notifies the owner — unless the
  /// listing already progressed: a delivered listing cannot be reopened
  /// (throws [NotAllowedException]) and a withdrawn one is cancelled
  /// silently.
  Future<ListingRequest> cancel(Session session, int requestId) async {
    final profile = await currentProfile(session);

    return await session.db.transaction((transaction) async {
      // Unlocked read to find which listing to lock.
      final initial = await ListingRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
      );
      if (initial == null) {
        throw ArgumentError('Solicitud no encontrada.');
      }

      // Always lock the listing row first.
      final listing = await Listing.db.findById(
        session,
        initial.listingId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );

      // Re-read the request under lock and validate the fresh row.
      final request = await ListingRequest.db.findById(
        session,
        requestId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (request == null) {
        throw ArgumentError('Solicitud no encontrada.');
      }
      if (request.requesterId != profile.id!) {
        throw NotAllowedException(
          message: 'No puedes cancelar esta solicitud.',
        );
      }

      if (request.status != RequestStatus.pending &&
          request.status != RequestStatus.accepted) {
        throw ArgumentError('La solicitud ya fue respondida.');
      }

      final wasAccepted = request.status == RequestStatus.accepted;

      if (wasAccepted && listing != null) {
        if (listing.status == ListingStatus.delivered) {
          throw NotAllowedException(
            message: 'La entrega ya se completó.',
          );
        }
      }

      final cancelled = await ListingRequest.db.updateRow(
        session,
        request.copyWith(status: RequestStatus.cancelled),
        transaction: transaction,
      );

      // Only a still-reserved listing is reopened (and its owner notified);
      // a withdrawn or otherwise changed listing is left alone.
      if (wasAccepted &&
          listing != null &&
          listing.status == ListingStatus.reserved) {
        await Listing.db.updateRow(
          session,
          listing.copyWith(
            status: ListingStatus.available,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: transaction,
        );

        await notify(
          session,
          userId: listing.ownerId,
          kind: NotificationKind.requestCancelled,
          title: 'Reserva cancelada',
          body:
              '${profile.displayName} canceló su solicitud de '
              '«${listing.title}».',
          refId: listing.id,
          transaction: transaction,
        );
      }

      return cancelled;
    });
  }

  /// Loads the listing of [request] with a FOR UPDATE lock and verifies the
  /// caller owns it.
  ///
  /// The lock is always taken on the listing row before any request row,
  /// so every mutating transaction serializes on the listing.
  Future<Listing> _ownedListing(
    Session session,
    ListingRequest request,
    MemberProfile profile,
    Transaction transaction,
  ) async {
    final listing = await Listing.db.findById(
      session,
      request.listingId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (listing == null) {
      throw ArgumentError('Publicación no encontrada.');
    }
    if (listing.ownerId != profile.id!) {
      throw NotAllowedException(
        message: 'No eres el dueño de esta publicación.',
      );
    }
    return listing;
  }
}
