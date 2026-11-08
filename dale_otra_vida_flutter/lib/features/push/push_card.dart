import 'package:flutter/material.dart';

import '../../core/push/push.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Invites the member to turn on push notifications for new messages. Shows
/// nothing when push is unsupported here or already on.
class PushCard extends StatefulWidget {
  const PushCard({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @override
  State<PushCard> createState() => _PushCardState();
}

class _PushCardState extends State<PushCard> {
  PushStatus? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Push.status().then((status) {
      if (mounted) setState(() => _status = status);
    });
  }

  Future<void> _enable() async {
    setState(() => _busy = true);
    PushStatus status;
    try {
      status = await Push.enable();
    } catch (_) {
      status = PushStatus.available;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = status;
    });
    final message = switch (status) {
      PushStatus.enabled => 'Listo: te avisaremos cuando te escriban.',
      PushStatus.denied =>
        'Las notificaciones están bloqueadas. Actívalas en los ajustes del '
            'navegador o del celular.',
      _ => 'No pudimos activar las notificaciones. Inténtalo de nuevo.',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status != PushStatus.available && status != PushStatus.denied) {
      return const SizedBox.shrink();
    }
    final denied = status == PushStatus.denied;

    return Padding(
      padding: widget.padding,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.categoryCircle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notificaciones', style: AppTypography.bodyStrong),
                  const SizedBox(height: 2),
                  Text(
                    denied
                        ? 'Bloqueadas. Actívalas en los ajustes del navegador.'
                        : 'Entérate al instante cuando te escriban.',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            if (!denied)
              TextButton(
                onPressed: _busy ? null : _enable,
                child: Text(
                  'Activar',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.link,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
