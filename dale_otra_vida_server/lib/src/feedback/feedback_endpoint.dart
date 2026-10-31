import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';

/// Opinions from testers, read later from the database.
class FeedbackEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// At most this many opinions per member per day, against spam.
  static const _dailyLimit = 20;

  Future<void> send(
    Session session,
    String message, {
    int? rating,
    String? screen,
    String? platform,
  }) async {
    final profile = await currentProfile(session);

    final text = message.trim();
    if (text.length < 3) {
      throw NotAllowedException(message: 'Cuéntanos un poco más.');
    }
    if (text.length > 1000) {
      throw NotAllowedException(
        message: 'El comentario no puede superar los 1000 caracteres.',
      );
    }
    if (rating != null && (rating < 1 || rating > 5)) {
      throw NotAllowedException(message: 'Calificación inválida.');
    }

    final since = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final today = await AppFeedback.db.count(
      session,
      where: (t) => t.profileId.equals(profile.id!) & (t.createdAt > since),
    );
    if (today >= _dailyLimit) {
      throw NotAllowedException(
        message: 'Ya recibimos muchos comentarios tuyos hoy. ¡Gracias!',
      );
    }

    String? short(String? value, int max) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      return trimmed.length <= max ? trimmed : trimmed.substring(0, max);
    }

    await AppFeedback.db.insertRow(
      session,
      AppFeedback(
        profileId: profile.id!,
        rating: rating,
        message: text,
        screen: short(screen, 40),
        platform: short(platform, 20),
      ),
    );
  }
}
