import 'package:flutter/material.dart';

import '../models/listing_type_ui.dart';
import '../theme/app_typography.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final ListingTypeUi type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: type.badgeBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.label,
        style: AppTypography.badge.copyWith(color: type.badgeText),
      ),
    );
  }
}
