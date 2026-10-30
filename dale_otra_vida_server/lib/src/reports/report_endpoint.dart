import 'package:serverpod/serverpod.dart';

import '../common/current_profile.dart';
import '../generated/protocol.dart';

/// Reports of members or listings for moderation.
class ReportEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Reports a member, a listing or both. Repeating the same report within
  /// a day returns the existing one.
  Future<Report> create(
    Session session,
    ReportReason reason, {
    int? reportedUserId,
    int? listingId,
    String? details,
  }) async {
    final profile = await currentProfile(session);

    if (reportedUserId == null && listingId == null) {
      throw NotAllowedException(message: 'Indica qué quieres reportar.');
    }
    if (reportedUserId == profile.id) {
      throw NotAllowedException(message: 'No puedes reportarte a ti mismo.');
    }
    var text = details?.trim();
    if (text != null && text.isEmpty) text = null;
    if (text != null && text.length > 500) {
      throw NotAllowedException(
        message: 'Los detalles no pueden superar los 500 caracteres.',
      );
    }

    if (listingId != null) {
      final listing = await Listing.db.findById(session, listingId);
      if (listing == null) {
        throw NotAllowedException(message: 'Publicación no encontrada.');
      }
      if (listing.ownerId == profile.id) {
        throw NotAllowedException(
          message: 'No puedes reportar tu propia publicación.',
        );
      }
      if (reportedUserId != null && reportedUserId != listing.ownerId) {
        throw NotAllowedException(
          message: 'La publicación no pertenece a ese usuario.',
        );
      }
    }
    if (reportedUserId != null &&
        await MemberProfile.db.findById(session, reportedUserId) == null) {
      throw NotAllowedException(message: 'Usuario no encontrado.');
    }

    final since = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final existing = await Report.db.findFirstRow(
      session,
      where: (t) {
        var expr = t.reporterId.equals(profile.id!) & (t.createdAt > since);
        expr = expr & t.reportedUserId.equals(reportedUserId);
        expr = expr & t.listingId.equals(listingId);
        return expr;
      },
    );
    if (existing != null) return existing;

    return Report.db.insertRow(
      session,
      Report(
        reporterId: profile.id!,
        reportedUserId: reportedUserId,
        listingId: listingId,
        reason: reason,
        details: text,
      ),
    );
  }
}
