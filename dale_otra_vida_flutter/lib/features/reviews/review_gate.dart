import 'package:flutter/material.dart';

import '../../client.dart';
import 'review_dialog.dart';

bool _asking = false;

/// Asks, one by one, for every delivery the member hasn't rated yet. The
/// dialogs can't be dismissed, so each delivery ends with a review. Runs on
/// app start, when the app comes back, and right after a delivery.
Future<void> askPendingReviews(BuildContext context) async {
  if (_asking) return;
  _asking = true;
  try {
    final pending = await client.review.pending();
    for (final review in pending) {
      if (!context.mounted) return;
      await showReviewDialog(
        context,
        listingId: review.listingId,
        memberName: review.member.displayName,
        listingTitle: review.listingTitle,
        mandatory: true,
      );
    }
    if (pending.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por calificar!')),
      );
    }
  } catch (_) {
    // Offline or signed out: ask again next time.
  } finally {
    _asking = false;
  }
}
