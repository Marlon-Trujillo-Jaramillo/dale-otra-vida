import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../models/account_type_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Small pill telling whether a profile is a person, a business or an
/// organization.
class AccountTypeBadge extends StatelessWidget {
  const AccountTypeBadge({super.key, required this.type});

  final AccountType type;

  @override
  Widget build(BuildContext context) {
    final highlighted = type != AccountType.person;
    final foreground = highlighted ? AppColors.link : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF6E3CF) : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(accountTypeIcon(type), size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            accountTypeLabel(type),
            style: AppTypography.badge.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
