import 'dart:math' as math;

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Whether a delivered loan is still out (handed over, not closed yet).
bool isLoanOut(Listing listing) =>
    listing.type == ListingType.lend &&
    listing.status == ListingStatus.delivered &&
    listing.loanOutcome == null;

/// Days past the return date, counting a started day as a full one (for
/// the late fee); 0 while on time.
int loanDaysLate(Listing listing, {DateTime? now}) {
  final due = listing.returnDate;
  if (due == null) return 0;
  final late = (now ?? DateTime.now()).toUtc().difference(due.toUtc());
  return late.isNegative ? 0 : late.inDays + 1;
}

/// The agreed late charge so far, capped at the guarantee when there is one.
int? loanLateFeeOwed(Listing listing, {DateTime? now}) {
  final fee = listing.lateFeePerDay;
  final days = loanDaysLate(listing, now: now);
  if (fee == null || days == 0) return null;
  final owed = fee * days;
  final deposit = listing.depositAmount;
  return deposit == null ? owed : math.min(owed, deposit);
}

/// Status line of a loan: "Prestado · vuelve el 12 nov 2026",
/// "Vencido hace 3 días", "Devuelto", "No devuelto". Null when it is not a
/// delivered loan.
String? loanStatusLabel(Listing listing, {DateTime? now}) {
  if (listing.type != ListingType.lend ||
      listing.status != ListingStatus.delivered) {
    return null;
  }
  switch (listing.loanOutcome) {
    case LoanOutcome.returned:
      return 'Devuelto';
    case LoanOutcome.notReturned:
      return 'No devuelto';
    case null:
      final due = listing.returnDate;
      if (loanDaysLate(listing, now: now) > 0 && due != null) {
        // Full days for the label; any started day counts for the fee.
        final days = (now ?? DateTime.now()).toUtc().difference(due).inDays;
        if (days == 0) return 'Vencido hoy';
        return 'Vencido hace $days ${days == 1 ? 'día' : 'días'}';
      }
      return due == null
          ? 'Prestado'
          : 'Prestado · vuelve el ${formatDate(due)}';
  }
}

/// The terms the owner set for a loan, as shown on the listing and in the
/// request sheet.
class LoanTermsCard extends StatelessWidget {
  const LoanTermsCard({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final due = listing.returnDate;
    final deposit = listing.depositAmount;
    final fee = listing.lateFeePerDay;
    final conditions = listing.loanConditions;
    final owed = isLoanOut(listing) ? loanLateFeeOwed(listing) : null;

    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$label: ', style: AppTypography.bodyStrong),
                  TextSpan(text: value, style: AppTypography.body),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Condiciones del préstamo', style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.m),
          row(
            Icons.event_outlined,
            'Devolver antes de',
            due == null ? 'A convenir' : formatDate(due),
          ),
          row(
            Icons.savings_outlined,
            'Garantía',
            deposit == null
                ? 'Sin garantía'
                : '${formatCop(deposit)}, se devuelve completa al regresarlo',
          ),
          row(
            Icons.timer_outlined,
            'Recargo por retraso',
            fee == null
                ? 'Sin recargo'
                : '${formatCop(fee)} por día'
                      '${deposit == null ? '' : ', máximo el valor de la garantía'}',
          ),
          if (conditions != null && conditions.isNotEmpty)
            row(Icons.rule_outlined, 'Condiciones', conditions),
          if (owed != null)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE3D6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Recargo acordado hasta hoy: ${formatCop(owed)}.',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ),
          Text(
            'La app no cobra dinero: la garantía y el recargo se acuerdan y '
            'se pagan en persona.',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
