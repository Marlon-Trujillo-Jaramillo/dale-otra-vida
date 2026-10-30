import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';
import '../listings/listing_views.dart';
import '../notifications/notify.dart';
import 'chat_messages.dart';

/// Chat between a listing owner and one interested member.
class ChatEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the caller's newest 100 conversations, most recent first.
  Future<List<ConversationView>> conversations(Session session) async {
    final profile = await currentProfile(session);
    final conversations = await Conversation.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(profile.id!) | t.requesterId.equals(profile.id!),
      orderByList: (t) => [t.lastMessageAt.desc(), t.id.desc()],
      limit: 100,
    );
    return _toViews(session, conversations, profile);
  }

  /// Returns one of the caller's conversations.
  Future<ConversationView> conversation(
    Session session,
    int conversationId,
  ) async {
    final profile = await currentProfile(session);
    final conversation = await _participantConversation(
      session,
      conversationId,
      profile,
    );
    final views = await _toViews(session, [conversation], profile);
    return views.first;
  }

  /// Returns a page of messages, newest first. Pass the id of the oldest
  /// message already loaded as [beforeId] to get the previous page.
  Future<List<ChatMessage>> messages(
    Session session,
    int conversationId, {
    int? beforeId,
    int? limit,
  }) async {
    final profile = await currentProfile(session);
    await _participantConversation(session, conversationId, profile);

    return ChatMessage.db.find(
      session,
      where: (t) => beforeId == null
          ? t.conversationId.equals(conversationId)
          : t.conversationId.equals(conversationId) & (t.id < beforeId),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: (limit ?? 50).clamp(1, 100),
    );
  }

  /// Sends a text message (the default [kind]) or a safe meeting point
  /// proposal.
  Future<ChatMessage> send(
    Session session,
    int conversationId,
    String text, {
    MessageKind? kind,
  }) async {
    final profile = await currentProfile(session);
    final messageKind = kind ?? MessageKind.text;

    if (messageKind == MessageKind.system) {
      throw NotAllowedException(message: 'Tipo de mensaje no permitido.');
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw NotAllowedException(message: 'El mensaje no puede estar vacío.');
    }
    if (trimmed.length > 1000) {
      throw NotAllowedException(message: 'El mensaje es demasiado largo.');
    }

    final (conversation, message) = await session.db.transaction((
      transaction,
    ) async {
      final conversation = await _participantConversation(
        session,
        conversationId,
        profile,
        transaction: transaction,
        lock: true,
      );
      await _ensureOpen(session, conversation, transaction);

      final message = await insertChatMessage(
        session,
        conversation,
        senderId: profile.id,
        kind: messageKind,
        text: trimmed,
        transaction: transaction,
      );
      return (conversation, message);
    });

    await publishChatMessage(session, conversation, message);

    final recipientId = conversation.ownerId == profile.id
        ? conversation.requesterId
        : conversation.ownerId;
    final alreadyNotified = await AppNotification.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(recipientId) &
          t.kind.equals(NotificationKind.newMessage) &
          t.refId.equals(conversationId) &
          t.readAt.equals(null),
    );
    if (alreadyNotified == null) {
      await notify(
        session,
        userId: recipientId,
        kind: NotificationKind.newMessage,
        title: 'Nuevo mensaje de ${profile.displayName}',
        body: messagePreview(messageKind, trimmed),
        refId: conversationId,
      );
    }

    return message;
  }

  /// Marks the other participant's messages, and the caller's new message
  /// notifications for this conversation, as read.
  Future<void> markRead(Session session, int conversationId) async {
    final profile = await currentProfile(session);
    await _participantConversation(session, conversationId, profile);

    final now = DateTime.now().toUtc();
    await ChatMessage.db.updateWhere(
      session,
      where: (t) =>
          t.conversationId.equals(conversationId) &
          t.senderId.notEquals(profile.id!) &
          t.senderId.notEquals(null) &
          t.readAt.equals(null),
      columnValues: (t) => [t.readAt(now)],
    );
    await AppNotification.db.updateWhere(
      session,
      where: (t) =>
          t.userId.equals(profile.id!) &
          t.kind.equals(NotificationKind.newMessage) &
          t.refId.equals(conversationId) &
          t.readAt.equals(null),
      columnValues: (t) => [t.readAt(now)],
    );
  }

  /// Total unread messages across the caller's conversations.
  Future<int> unreadTotal(Session session) async {
    final profile = await currentProfile(session);
    final conversations = await Conversation.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(profile.id!) | t.requesterId.equals(profile.id!),
    );
    if (conversations.isEmpty) return 0;
    return ChatMessage.db.count(
      session,
      where: (t) =>
          t.conversationId.inSet(conversations.map((c) => c.id!).toSet()) &
          t.senderId.notEquals(profile.id!) &
          t.senderId.notEquals(null) &
          t.readAt.equals(null),
    );
  }

  /// Streams new messages of one conversation.
  Stream<ChatMessage> subscribe(Session session, int conversationId) async* {
    final profile = await currentProfile(session);
    await _participantConversation(session, conversationId, profile);
    yield* session.messages.createStream<ChatMessage>(
      chatChannel(conversationId),
    );
  }

  /// Streams every new message in any of the caller's conversations.
  Stream<ChatMessage> inbox(Session session) async* {
    final profile = await currentProfile(session);
    yield* session.messages.createStream<ChatMessage>(
      inboxChannel(profile.id!),
    );
  }

  Future<Conversation> _participantConversation(
    Session session,
    int conversationId,
    MemberProfile profile, {
    Transaction? transaction,
    bool lock = false,
  }) async {
    final conversation = await Conversation.db.findById(
      session,
      conversationId,
      transaction: transaction,
      lockMode: lock ? LockMode.forUpdate : null,
    );
    if (conversation == null ||
        (conversation.ownerId != profile.id &&
            conversation.requesterId != profile.id)) {
      throw NotAllowedException(message: 'No participas en esta conversación.');
    }
    return conversation;
  }

  /// Throws when the listing was withdrawn or the request was rejected.
  Future<void> _ensureOpen(
    Session session,
    Conversation conversation,
    Transaction transaction,
  ) async {
    final listing = await Listing.db.findById(
      session,
      conversation.listingId,
      transaction: transaction,
    );
    final request = await ListingRequest.db.findFirstRow(
      session,
      where: (t) =>
          t.listingId.equals(conversation.listingId) &
          t.requesterId.equals(conversation.requesterId),
      transaction: transaction,
    );
    if (listing == null ||
        listing.status == ListingStatus.withdrawn ||
        request?.status == RequestStatus.rejected) {
      throw NotAllowedException(message: 'Esta conversación está cerrada.');
    }
  }

  Future<List<ConversationView>> _toViews(
    Session session,
    List<Conversation> conversations,
    MemberProfile profile,
  ) async {
    if (conversations.isEmpty) return [];

    final listingIds = conversations.map((c) => c.listingId).toSet();
    final listings = await Listing.db.find(
      session,
      where: (t) => t.id.inSet(listingIds),
    );
    final listingViews = await toViews(session, listings, profile);
    final listingViewById = {
      for (final view in listingViews) view.listing.id!: view,
    };

    final otherIds = {
      for (final c in conversations)
        c.ownerId == profile.id ? c.requesterId : c.ownerId,
    };
    final others = await MemberProfile.db.find(
      session,
      where: (t) => t.id.inSet(otherIds),
    );
    final otherById = {
      for (final other in others)
        other.id!: other.copyWith(latitude: null, longitude: null),
    };

    final unread = await ChatMessage.db.find(
      session,
      where: (t) =>
          t.conversationId.inSet(conversations.map((c) => c.id!).toSet()) &
          t.senderId.notEquals(profile.id!) &
          t.senderId.notEquals(null) &
          t.readAt.equals(null),
    );
    final unreadByConversationId = <int, int>{};
    for (final message in unread) {
      unreadByConversationId[message.conversationId] =
          (unreadByConversationId[message.conversationId] ?? 0) + 1;
    }

    final requesterIds = conversations.map((c) => c.requesterId).toSet();
    final requests = await ListingRequest.db.find(
      session,
      where: (t) =>
          t.listingId.inSet(listingIds) & t.requesterId.inSet(requesterIds),
    );
    final requestByKey = {
      for (final request in requests)
        (request.listingId, request.requesterId): request,
    };

    // Delivered listings the caller has not rated yet.
    final deliveredIds = {
      for (final listing in listings)
        if (listing.status == ListingStatus.delivered) listing.id!,
    };
    final myReviews = deliveredIds.isEmpty
        ? <Review>[]
        : await Review.db.find(
            session,
            where: (t) =>
                t.listingId.inSet(deliveredIds) &
                t.reviewerId.equals(profile.id!),
          );
    final reviewedIds = myReviews.map((r) => r.listingId).toSet();

    return [
      for (final c in conversations)
        ConversationView(
          conversation: c,
          listing: listingViewById[c.listingId]!,
          other:
              otherById[c.ownerId == profile.id ? c.requesterId : c.ownerId]!,
          isOwner: c.ownerId == profile.id,
          unreadCount: unreadByConversationId[c.id] ?? 0,
          request: requestByKey[(c.listingId, c.requesterId)],
          canReview:
              deliveredIds.contains(c.listingId) &&
              !reviewedIds.contains(c.listingId) &&
              requestByKey[(c.listingId, c.requesterId)]?.status ==
                  RequestStatus.accepted,
        ),
    ];
  }
}
