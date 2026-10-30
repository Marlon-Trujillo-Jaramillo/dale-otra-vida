import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';
import 'notify.dart';

/// In-app notifications for the signed-in member.
class NotificationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the notifications of the caller, newest first.
  Future<List<AppNotification>> list(
    Session session, {
    int limit = 30,
    int offset = 0,
  }) async {
    final profile = await currentProfile(session);

    limit = limit.clamp(1, 50);
    offset = math.max(0, offset);

    return AppNotification.db.find(
      session,
      where: (t) => t.userId.equals(profile.id!),
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
      limit: limit,
      offset: offset,
    );
  }

  /// Returns how many notifications the caller has not read yet.
  Future<int> unreadCount(Session session) async {
    final profile = await currentProfile(session);
    await _remindExpiring(session, profile);

    return AppNotification.db.count(
      session,
      where: (t) => t.userId.equals(profile.id!) & t.readAt.equals(null),
    );
  }

  /// Marks one notification of the caller as read.
  ///
  /// Notifications owned by other members are silently ignored.
  Future<void> markRead(Session session, int id) async {
    final profile = await currentProfile(session);

    final notification = await AppNotification.db.findFirstRow(
      session,
      where: (t) => t.id.equals(id) & t.userId.equals(profile.id!),
    );
    if (notification == null || notification.readAt != null) return;

    await AppNotification.db.updateRow(
      session,
      notification.copyWith(readAt: DateTime.now().toUtc()),
    );
  }

  /// Marks every unread notification of the caller as read.
  Future<void> markAllRead(Session session) async {
    final profile = await currentProfile(session);

    await AppNotification.db.updateWhere(
      session,
      where: (t) => t.userId.equals(profile.id!) & t.readAt.equals(null),
      columnValues: (t) => [t.readAt(DateTime.now().toUtc())],
      noReturn: true,
    );
  }

  /// Notifies the caller once about each open food listing of theirs that
  /// expires within a day. Runs on the badge poll, so no scheduler is needed.
  Future<void> _remindExpiring(Session session, MemberProfile profile) async {
    final now = DateTime.now().toUtc();
    final expiring = await Listing.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(profile.id!) &
          t.category.equals(Category.food) &
          (t.status.equals(ListingStatus.available) |
              t.status.equals(ListingStatus.reserved)) &
          (t.expiresAt > now) &
          (t.expiresAt <= now.add(const Duration(days: 1))),
    );
    if (expiring.isEmpty) return;

    final reminded = await AppNotification.db.find(
      session,
      where: (t) =>
          t.userId.equals(profile.id!) &
          t.kind.equals(NotificationKind.listingExpiring) &
          t.refId.inSet(expiring.map((l) => l.id!).toSet()),
    );
    final remindedIds = reminded.map((n) => n.refId).toSet();

    for (final listing in expiring) {
      if (remindedIds.contains(listing.id)) continue;
      await notify(
        session,
        userId: profile.id!,
        kind: NotificationKind.listingExpiring,
        title: 'Tu publicación vence pronto',
        body:
            '«${listing.title}» vence en menos de un día. Si sigue en buen '
            'estado, actualiza la fecha.',
        refId: listing.id,
      );
    }
  }
}
