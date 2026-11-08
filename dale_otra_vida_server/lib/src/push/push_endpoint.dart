import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';
import 'fcm.dart';

/// Registers the devices that receive push notifications.
class PushEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Whether the server can send pushes (Firebase is configured).
  Future<bool> enabled(Session session) async => fcmConfigured(session);

  /// Saves [token] for the caller. A token that moved to another account on
  /// the same device now belongs to the caller.
  Future<void> register(Session session, String token, String platform) async {
    final profile = await currentProfile(session);
    final trimmed = token.trim();
    if (trimmed.isEmpty || trimmed.length > 4096) {
      throw NotAllowedException(message: 'Token inválido.');
    }
    const platforms = {'web', 'android', 'ios'};
    if (!platforms.contains(platform)) {
      throw NotAllowedException(message: 'Plataforma inválida.');
    }

    await session.db.transaction((transaction) async {
      final existing = await PushToken.db.findFirstRow(
        session,
        where: (t) => t.token.equals(trimmed),
        transaction: transaction,
      );
      final now = DateTime.now().toUtc();
      if (existing == null) {
        await PushToken.db.insertRow(
          session,
          PushToken(
            profileId: profile.id!,
            token: trimmed,
            platform: platform,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      } else {
        await PushToken.db.updateRow(
          session,
          existing.copyWith(
            profileId: profile.id!,
            platform: platform,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      }
    });
  }

  /// Forgets [token], e.g. on sign out. Only the caller's own tokens.
  Future<void> unregister(Session session, String token) async {
    final profile = await currentProfile(session);
    await PushToken.db.deleteWhere(
      session,
      where: (t) =>
          t.token.equals(token.trim()) & t.profileId.equals(profile.id!),
    );
  }
}
