import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Inserts an in-app notification for a member.
///
/// [userId] is the MemberProfile id. Pass the active [transaction] when the
/// notification is part of a larger unit of work.
Future<void> notify(
  Session session, {
  required int userId,
  required NotificationKind kind,
  required String title,
  required String body,
  int? refId,
  Transaction? transaction,
}) async {
  await AppNotification.db.insertRow(
    session,
    AppNotification(
      userId: userId,
      kind: kind,
      title: title,
      body: body,
      refId: refId,
    ),
    transaction: transaction,
  );
}
