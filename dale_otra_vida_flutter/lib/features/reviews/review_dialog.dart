import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

/// Asks for a 1–5 rating of [memberName] for [listingId]. Returns true when
/// the review was saved.
Future<bool> showReviewDialog(
  BuildContext context, {
  required int listingId,
  required String memberName,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) =>
        _ReviewDialog(listingId: listingId, memberName: memberName),
  );
  return saved == true;
}

String ratingCaption(int rating) {
  return switch (rating) {
    1 => 'Mala experiencia',
    2 => 'Regular',
    3 => 'Bien',
    4 => 'Muy bien',
    5 => '¡Excelente!',
    _ => 'Toca una estrella',
  };
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.listingId, required this.memberName});

  final int listingId;
  final String memberName;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _rating = 0;
  bool _saving = false;
  String? _error;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await client.review.create(
        widget.listingId,
        _rating,
        comment: _comment.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on NotAllowedException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No pudimos guardar tu reseña.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Califica a ${widget.memberName}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Cómo te fue con la entrega? Tu reseña ayuda a que la '
              'comunidad confíe.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var star = 1; star <= 5; star++)
                  IconButton(
                    tooltip: '$star',
                    iconSize: 36,
                    onPressed: _saving
                        ? null
                        : () => setState(() => _rating = star),
                    icon: Icon(
                      star <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: star <= _rating
                          ? AppColors.accent
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
            Text(
              ratingCaption(_rating),
              style: AppTypography.bodyStrong,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              label: 'Comentario (opcional)',
              hint: 'Ej: Muy puntual y amable',
              controller: _comment,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                _error!,
                style: AppTypography.caption.copyWith(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: _rating == 0 || _saving ? null : _save,
          child: const Text('Enviar reseña'),
        ),
      ],
    );
  }
}
