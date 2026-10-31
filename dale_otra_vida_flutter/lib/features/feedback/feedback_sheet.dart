import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

/// Asks testers how the app feels: a 1–5 mood and a comment. [screen] says
/// where it was opened from.
Future<void> showFeedbackSheet(
  BuildContext context, {
  required String screen,
}) async {
  final form = _FeedbackForm(screen: screen);
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
      const SnackBar(content: Text('¡Gracias! Leemos cada comentario.')),
    );
  }
}

const _moods = [
  (Icons.sentiment_very_dissatisfied_outlined, 'Muy mal'),
  (Icons.sentiment_dissatisfied_outlined, 'Mal'),
  (Icons.sentiment_neutral_outlined, 'Normal'),
  (Icons.sentiment_satisfied_outlined, 'Bien'),
  (Icons.sentiment_very_satisfied_outlined, 'Muy bien'),
];

String feedbackPlatform() =>
    kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();

class _FeedbackForm extends StatefulWidget {
  const _FeedbackForm({required this.screen});

  final String screen;

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  int? _rating;
  bool _sending = false;
  String? _error;
  final _message = TextEditingController();

  @override
  void initState() {
    super.initState();
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await client.feedback.send(
        _message.text,
        rating: _rating,
        screen: widget.screen,
        platform: feedbackPlatform(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on NotAllowedException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No pudimos enviarlo. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _message.text.trim().length >= 3 && !_sending;
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
            Text('¿Cómo te va con la app?', style: AppTypography.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Estamos probando Dale Otra Vida. Lo que nos cuentes nos ayuda '
              'a mejorarla.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _moods.length; i++)
                  _MoodButton(
                    icon: _moods[i].$1,
                    label: _moods[i].$2,
                    selected: _rating == i + 1,
                    onTap: () => setState(() => _rating = i + 1),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            AppTextField(
              label: 'Tu comentario',
              hint: '¿Qué te gustó? ¿Qué te confundió o falló?',
              controller: _message,
              maxLength: 1000,
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
              label: 'Enviar',
              isLoading: _sending,
              onPressed: canSend ? _send : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: selected ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
