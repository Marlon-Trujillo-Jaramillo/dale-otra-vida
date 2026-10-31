import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../core/models/account_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// "¿Quién publica?": person, business or organization, as large rows.
class AccountTypeSelector extends StatelessWidget {
  const AccountTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AccountType value;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('¿Quién publica?', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.s),
        for (final type in AccountType.values) ...[
          _TypeRow(
            type: type,
            selected: type == value,
            onTap: () => onChanged(type),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AccountType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.onPrimary : AppColors.textPrimary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Icon(accountTypeIcon(type), color: foreground),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accountTypeLabel(type),
                        style: AppTypography.bodyStrong.copyWith(
                          color: foreground,
                        ),
                      ),
                      Text(
                        accountTypeDescription(type),
                        style: AppTypography.caption.copyWith(
                          color: selected
                              ? AppColors.onPrimary.withValues(alpha: 0.8)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: AppColors.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
