import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../core/models/listing_type_ui.dart';

enum QuickReply { proposeSafePoint, stillAvailable, markDelivered, review }

/// Merges [incoming] into [current] without duplicates, oldest first.
List<ChatMessage> mergeMessages(
  List<ChatMessage> current,
  Iterable<ChatMessage> incoming,
) {
  final byId = {for (final m in current) m.id: m};
  for (final m in incoming) {
    byId[m.id] = m;
  }
  return byId.values.toList()..sort((a, b) {
    final byDate = a.createdAt.compareTo(b.createdAt);
    if (byDate != 0) return byDate;
    return (a.id ?? 0).compareTo(b.id ?? 0);
  });
}

/// The withdrawn listing or the rejected request closes a conversation.
bool isConversationClosed(ConversationView view) {
  return view.listing.listing.status == ListingStatus.withdrawn ||
      view.request?.status == RequestStatus.rejected;
}

/// Quick replies shown above the composer.
List<QuickReply> quickRepliesFor(ConversationView view) {
  if (isConversationClosed(view)) return [];
  final status = view.listing.listing.status;
  return [
    if (view.canReview) QuickReply.review,
    if (status != ListingStatus.delivered) QuickReply.proposeSafePoint,
    if (!view.isOwner && status == ListingStatus.available)
      QuickReply.stillAvailable,
    if (view.isOwner &&
        status == ListingStatus.reserved &&
        view.request?.status == RequestStatus.accepted)
      QuickReply.markDelivered,
  ];
}

String quickReplyLabel(QuickReply reply) {
  return switch (reply) {
    QuickReply.proposeSafePoint => 'Proponer punto seguro',
    QuickReply.stillAvailable => '¿Sigue disponible?',
    QuickReply.markDelivered => 'Marcar como entregado',
    QuickReply.review => 'Calificar',
  };
}

/// "Donar · Vence 12 nov 2026", "Vender · $ 20.000", …
String listingSubtitle(Listing listing) {
  final type = ListingTypeUi.fromServer(listing.type).label;
  final expiresAt = listing.expiresAt;
  final returnDate = listing.returnDate;
  final price = listing.price;
  if (expiresAt != null) return '$type · Vence ${formatDate(expiresAt)}';
  if (price != null) return '$type · ${formatCop(price)}';
  if (returnDate != null) return '$type · Hasta ${formatDate(returnDate)}';
  return type;
}

String listingStatusLabel(ListingStatus status) {
  return switch (status) {
    ListingStatus.available => 'Disponible',
    ListingStatus.reserved => 'Reservado',
    ListingStatus.delivered => 'Entregado',
    ListingStatus.withdrawn => 'Retirado',
  };
}

/// "14:05" today, "Ayer 14:05", otherwise "03/11 14:05".
String formatMessageTime(DateTime date, {DateTime? now}) {
  final local = date.toLocal();
  final today = (now ?? DateTime.now()).toLocal();
  final time = DateFormat('HH:mm').format(local);
  final day = DateTime(local.year, local.month, local.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  final difference = todayDay.difference(day).inDays;
  if (difference == 0) return time;
  if (difference == 1) return 'Ayer $time';
  return '${DateFormat('dd/MM').format(local)} $time';
}

/// "4,8" — the prototype uses a decimal comma.
String formatRating(double rating) =>
    rating.toStringAsFixed(1).replaceAll('.', ',');
