import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';

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

    final unread = await AppNotification.db.find(
      session,
      where: (t) => t.userId.equals(profile.id!) & t.readAt.equals(null),
    );

    final now = DateTime.now().toUtc();
    for (final notification in unread) {
      await AppNotification.db.updateRow(
        session,
        notification.copyWith(readAt: now),
      );
    }
  }
}
