import 'package:flutter/material.dart';

import '../../core/install/install_app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

/// Installs the web app: Chrome's own dialog when it is ready, otherwise the
/// manual steps for the browser.
Future<void> startInstall(BuildContext context) async {
  final state = installState();
  if (state == InstallState.prompt) {
    final accepted = await promptInstall();
    if (accepted) dismissInstallBanner();
    return;
  }
  if (state == InstallState.none) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    builder: (context) => _InstallSteps(ios: state == InstallState.ios),
  );
}

class _InstallSteps extends StatelessWidget {
  const _InstallSteps({required this.ios});

  final bool ios;

  @override
  Widget build(BuildContext context) {
    final steps = ios
        ? const [
            (Icons.ios_share, 'Toca Compartir (el cuadro con la flecha).'),
            (Icons.add_box_outlined, 'Elige «Agregar a pantalla de inicio».'),
            (Icons.check_circle_outline, 'Toca «Agregar». ¡Listo!'),
          ]
        : const [
            (Icons.more_vert, 'Abre el menú ⋮ del navegador.'),
            (
              Icons.install_mobile,
              'Elige «Instalar app» o «Agregar a la pantalla principal».',
            ),
            (Icons.check_circle_outline, 'Confirma. ¡Listo!'),
          ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Instala Dale Otra Vida', style: AppTypography.headline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ios
                  ? 'En iPhone se instala desde Safari o Chrome en 3 pasos.'
                  : 'Tendrás el ícono en tu pantalla, como cualquier app.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            for (final (index, step) in steps.indexed) ...[
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.categoryCircle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(step.$1, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      '${index + 1}. ${step.$2}',
                      style: AppTypography.body,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
            ],
            const SizedBox(height: AppSpacing.s),
            AppPrimaryButton(
              label: 'Entendido',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dismissible card on the home feed inviting phone browsers to install the
/// app. Hidden once installed or closed.
class InstallBanner extends StatefulWidget {
  const InstallBanner({super.key});

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  late bool _visible =
      installState() != InstallState.none && !installBannerDismissed();

  void _close() {
    dismissInstallBanner();
    setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.m,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.m,
          AppSpacing.xs,
          AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.install_mobile, color: AppColors.accent),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                'Instala la app en tu celular',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await startInstall(context);
                if (mounted && installState() == InstallState.none) {
                  setState(() => _visible = false);
                }
              },
              child: Text(
                'Instalar',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Cerrar',
              onPressed: _close,
              icon: const Icon(Icons.close, color: AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
