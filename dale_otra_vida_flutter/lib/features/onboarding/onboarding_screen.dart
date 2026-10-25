import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_colors.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_spacing.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_typography.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_primary_button.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _displayNameController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  bool _isLoading = false;
  String? _displayNameError;
  String? _serverError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  String? _validateDisplayName(String value) {
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 60) {
      return 'El nombre debe tener máximo 60 caracteres';
    }
    return null;
  }

  Future<void> _continue() async {
    final nameError = _validateDisplayName(_displayNameController.text);
    setState(() {
      _displayNameError = nameError;
      _serverError = null;
    });
    if (nameError != null) return;

    setState(() => _isLoading = true);
    try {
      await client.profile.saveMe(
        displayName: _displayNameController.text.trim(),
        neighborhood: _neighborhoodController.text.trim().isEmpty
            ? null
            : _neighborhoodController.text.trim(),
      );
      widget.onCompleted();
    } catch (e) {
      setState(() => _serverError = 'No pudimos guardar tu perfil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cuéntanos de ti',
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: '¿Cómo te llamas?',
                  hint: 'Tu nombre o apodo',
                  controller: _displayNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  errorText: _displayNameError,
                ),
                const SizedBox(height: AppSpacing.l),
                AppTextField(
                  label: 'Barrio',
                  hint: 'Opcional',
                  controller: _neighborhoodController,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _continue(),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppPrimaryButton(
                  label: 'Continuar',
                  isLoading: _isLoading,
                  onPressed: _continue,
                ),
                if (_serverError != null) ...[
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    _serverError!,
                    style: AppTypography.body.copyWith(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
