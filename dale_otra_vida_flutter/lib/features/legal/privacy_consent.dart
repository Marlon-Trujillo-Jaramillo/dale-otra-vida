import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/legal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// "Acepto la política de datos" with a link to read it. Unticked by default:
/// the authorization has to be the member's own choice (Ley 1581).
class PrivacyConsent extends StatelessWidget {
  const PrivacyConsent({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Its own transparent Material so the tap ripple shows on top of the
    // coloured cards that hold it (onboarding on wide screens).
    return Material(
      type: MaterialType.transparency,
      child: _tile(),
    );
  }

  Widget _tile() {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text.rich(
        TextSpan(
          style: AppTypography.body,
          children: [
            const TextSpan(
              text: 'Autorizo el tratamiento de mis datos según la ',
            ),
            TextSpan(
              text: 'política de datos',
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.link,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = openPrivacyPolicy,
            ),
            const TextSpan(text: ' de Dale Otra Vida.'),
          ],
        ),
      ),
    );
  }
}

bool _asking = false;

/// Asks members who haven't accepted the current policy version (accounts
/// from before it existed, or after it changed). It can't be dismissed: the
/// app needs the authorization to process their data.
Future<void> askPrivacyAcceptance(BuildContext context, int? acceptedVersion) {
  if (acceptedVersion == privacyVersion || _asking) return Future.value();
  _asking = true;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PopScope(canPop: false, child: _PolicyDialog()),
  ).whenComplete(() => _asking = false);
}

class _PolicyDialog extends StatefulWidget {
  const _PolicyDialog();

  @override
  State<_PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<_PolicyDialog> {
  bool _accepted = false;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await client.profile.acceptPrivacy(privacyVersion);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'No pudimos guardarlo. Revisa tu conexión.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuestra política de datos'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para seguir usando Dale Otra Vida necesitamos tu autorización '
              'para tratar tus datos: qué guardamos, para qué, con quién se '
              'comparten y cómo ejercer tus derechos.',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton.icon(
              onPressed: openPrivacyPolicy,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Leer la política'),
            ),
            PrivacyConsent(
              value: _accepted,
              onChanged: _saving ? null : (v) => setState(() => _accepted = v),
            ),
            if (_error != null)
              Text(
                _error!,
                style: AppTypography.caption.copyWith(color: AppColors.danger),
              ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _accepted && !_saving ? _save : null,
          child: const Text('Aceptar y continuar'),
        ),
      ],
    );
  }
}
