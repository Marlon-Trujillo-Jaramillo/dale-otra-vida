import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

String reportReasonLabel(ReportReason reason) {
  return switch (reason) {
    ReportReason.spam => 'Spam o publicidad',
    ReportReason.scam => 'Estafa o pide datos bancarios',
    ReportReason.inappropriate => 'Contenido o trato inapropiado',
    ReportReason.unsafeFood => 'Alimento en mal estado',
    ReportReason.other => 'Otro motivo',
  };
}

/// Reports a member and/or a listing: bottom sheet on phones, dialog on wide
/// screens. Shows a thank-you SnackBar when sent.
Future<void> showReportSheet(
  BuildContext context, {
  required String title,
  int? reportedUserId,
  int? listingId,
}) async {
  final form = _ReportForm(
    title: title,
    reportedUserId: reportedUserId,
    listingId: listingId,
  );
  final sent = ScreenSize.of(context).isCompact
      ? await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          backgroundColor: AppColors.background,
          builder: (context) => form,
        )
      : await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: AppColors.background,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: form,
            ),
          ),
        );
  if (sent == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gracias por avisarnos. Revisaremos tu reporte.'),
      ),
    );
  }
}

class _ReportForm extends StatefulWidget {
  const _ReportForm({
    required this.title,
    this.reportedUserId,
    this.listingId,
  });

  final String title;
  final int? reportedUserId;
  final int? listingId;

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  ReportReason? _reason;
  bool _sending = false;
  String? _error;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await client.report.create(
        reason,
        reportedUserId: widget.reportedUserId,
        listingId: widget.listingId,
        details: _details.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on NotAllowedException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No pudimos enviar el reporte.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.l,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tu reporte es anónimo. Cuéntanos qué pasó.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.m),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (value) => setState(() => _reason = value),
              child: Column(
                children: [
                  for (final reason in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: reason,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        reportReasonLabel(reason),
                        style: AppTypography.body,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            AppTextField(
              label: 'Detalles (opcional)',
              hint: 'Lo que nos ayude a entender el caso',
              controller: _details,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                _error!,
                style: AppTypography.caption.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            AppPrimaryButton(
              label: 'Enviar reporte',
              isLoading: _sending,
              onPressed: _reason == null || _sending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
