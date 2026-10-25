import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_colors.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_spacing.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_typography.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_primary_button.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_secondary_button.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_segmented_control.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.controller});

  final EmailAuthController? controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final EmailAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? EmailAuthController(client: client);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            const _HeroBlock(),
            Expanded(
              child: SafeArea(
                top: false,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return _AuthBody(controller: _controller);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Dale Otra Vida',
              style: AppTypography.display.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Lo que ya no usas puede ser justo lo que otra persona necesita.',
              style: AppTypography.body.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBody extends StatelessWidget {
  const _AuthBody({required this.controller});

  final EmailAuthController controller;

  int get _selectedSegment {
    return switch (controller.currentScreen) {
      EmailFlowScreen.login ||
      EmailFlowScreen.requestPasswordReset ||
      EmailFlowScreen.verifyPasswordReset ||
      EmailFlowScreen.completePasswordReset => 0,
      EmailFlowScreen.startRegistration ||
      EmailFlowScreen.verifyRegistration ||
      EmailFlowScreen.completeRegistration => 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmentedControl(
            options: const ['Ingresar', 'Crear cuenta'],
            selectedIndex: _selectedSegment,
            onChanged: (index) {
              if (index == 0) {
                controller.navigateTo(EmailFlowScreen.login);
              } else {
                controller.navigateTo(EmailFlowScreen.startRegistration);
              }
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildStep(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    return switch (controller.currentScreen) {
      EmailFlowScreen.login => _LoginStep(controller: controller),
      EmailFlowScreen.startRegistration => _RegisterEmailStep(
        controller: controller,
      ),
      EmailFlowScreen.verifyRegistration => _RegisterVerifyStep(
        controller: controller,
      ),
      EmailFlowScreen.completeRegistration => _RegisterPasswordStep(
        controller: controller,
      ),
      EmailFlowScreen.requestPasswordReset => _ResetEmailStep(
        controller: controller,
      ),
      EmailFlowScreen.verifyPasswordReset => _ResetVerifyStep(
        controller: controller,
      ),
      EmailFlowScreen.completePasswordReset => _ResetPasswordStep(
        controller: controller,
      ),
    };
  }
}

class _BackHeader extends StatelessWidget {
  const _BackHeader({required this.controller});

  final EmailAuthController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: controller.canNavigateBack ? controller.navigateBack : null,
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Atrás'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

class _ControllerError extends StatelessWidget {
  const _ControllerError({required this.controller});

  final EmailAuthController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.errorMessage == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: Text(
        controller.errorMessage!,
        style: AppTypography.body.copyWith(color: AppColors.danger),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Text(
            text,
            style: AppTypography.caption,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }
}

class _LoginStep extends StatefulWidget {
  const _LoginStep({required this.controller});

  final EmailAuthController controller;

  @override
  State<_LoginStep> createState() => _LoginStepState();
}

class _LoginStepState extends State<_LoginStep> {
  String? _emailError;
  String? _passwordError;

  void _validateAndLogin() {
    setState(() {
      _emailError = _validateEmail(widget.controller.emailController.text);
      _passwordError = widget.controller.passwordController.text.isEmpty
          ? 'Ingresa tu contraseña'
          : null;
    });
    if (_emailError == null && _passwordError == null) {
      widget.controller.login();
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Ingresa tu correo electrónico';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Correo electrónico inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('login'),
        children: [
          AppTextField(
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            controller: widget.controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
          ),
          const SizedBox(height: AppSpacing.l),
          AppTextField(
            label: 'Contraseña',
            hint: '••••••••',
            controller: widget.controller.passwordController,
            obscure: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            errorText: _passwordError,
            onSubmitted: (_) => _validateAndLogin(),
          ),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                widget.controller.navigateTo(
                  EmailFlowScreen.requestPasswordReset,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.link,
                padding: EdgeInsets.zero,
              ),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          AppPrimaryButton(
            label: 'Ingresar',
            isLoading: widget.controller.isLoading,
            onPressed: _validateAndLogin,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _DividerWithText(text: 'o'),
          const SizedBox(height: AppSpacing.xl),
          AppSecondaryButton(
            label: 'Continuar con Google',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Muy pronto podrás ingresar con Google'),
                ),
              );
            },
          ),
          _ControllerError(controller: widget.controller),
        ],
      ),
    );
  }
}

class _RegisterEmailStep extends StatefulWidget {
  const _RegisterEmailStep({required this.controller});

  final EmailAuthController controller;

  @override
  State<_RegisterEmailStep> createState() => _RegisterEmailStepState();
}

class _RegisterEmailStepState extends State<_RegisterEmailStep> {
  String? _emailError;

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Ingresa tu correo electrónico';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Correo electrónico inválido';
    return null;
  }

  void _validateAndStart() {
    setState(() {
      _emailError = _validateEmail(widget.controller.emailController.text);
    });
    if (_emailError == null) {
      widget.controller.startRegistration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('register-email'),
        children: [
          _BackHeader(controller: widget.controller),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            controller: widget.controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
            onSubmitted: (_) => _validateAndStart(),
          ),
          const SizedBox(height: AppSpacing.l),
          AppPrimaryButton(
            label: 'Continuar',
            isLoading: widget.controller.isLoading,
            onPressed: _validateAndStart,
          ),
          _ControllerError(controller: widget.controller),
        ],
      ),
    );
  }
}

class _RegisterVerifyStep extends StatelessWidget {
  const _RegisterVerifyStep({required this.controller});

  final EmailAuthController controller;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('register-verify'),
        children: [
          _BackHeader(controller: controller),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Te enviamos un código a ${controller.emailController.text}',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.l),
          AppTextField(
            label: 'Código de 6 dígitos',
            hint: '000000',
            controller: controller.verificationCodeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
          ),
          const SizedBox(height: AppSpacing.l),
          AppPrimaryButton(
            label: 'Verificar',
            isLoading: controller.isLoading,
            onPressed: controller.verifyRegistrationCode,
          ),
          const SizedBox(height: AppSpacing.s),
          TextButton(
            onPressed: controller.isLoading
                ? null
                : controller.resendVerificationCode,
            style: TextButton.styleFrom(foregroundColor: AppColors.link),
            child: const Text('Reenviar código'),
          ),
          _ControllerError(controller: controller),
        ],
      ),
    );
  }
}

class _RegisterPasswordStep extends StatefulWidget {
  const _RegisterPasswordStep({required this.controller});

  final EmailAuthController controller;

  @override
  State<_RegisterPasswordStep> createState() => _RegisterPasswordStepState();
}

class _RegisterPasswordStepState extends State<_RegisterPasswordStep> {
  final _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength =>
      widget.controller.passwordController.text.length >= 8;

  bool get _passwordsMatch =>
      widget.controller.passwordController.text ==
          _confirmPasswordController.text &&
      _confirmPasswordController.text.isNotEmpty;

  void _validateAndFinish() {
    setState(() {
      _passwordError = _hasMinLength
          ? null
          : 'La contraseña debe tener al menos 8 caracteres';
      _confirmError = _passwordsMatch ? null : 'Las contraseñas no coinciden';
    });
    if (_passwordError == null && _confirmError == null) {
      widget.controller.finishRegistration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('register-password'),
        children: [
          _BackHeader(controller: widget.controller),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: 'Contraseña',
            hint: 'Mínimo 8 caracteres',
            controller: widget.controller.passwordController,
            obscure: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            errorText: _passwordError,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.s),
          _RequirementRow(
            met: _hasMinLength,
            label: 'Al menos 8 caracteres',
          ),
          const SizedBox(height: AppSpacing.l),
          AppTextField(
            label: 'Confirmar contraseña',
            hint: 'Repite tu contraseña',
            controller: _confirmPasswordController,
            obscure: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            errorText: _confirmError,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _validateAndFinish(),
          ),
          const SizedBox(height: AppSpacing.l),
          AppPrimaryButton(
            label: 'Crear cuenta',
            isLoading: widget.controller.isLoading,
            onPressed: _validateAndFinish,
          ),
          _ControllerError(controller: widget.controller),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: met ? AppColors.verified : AppColors.textHint,
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: met ? AppColors.textSecondary : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

class _ResetEmailStep extends StatefulWidget {
  const _ResetEmailStep({required this.controller});

  final EmailAuthController controller;

  @override
  State<_ResetEmailStep> createState() => _ResetEmailStepState();
}

class _ResetEmailStepState extends State<_ResetEmailStep> {
  String? _emailError;

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Ingresa tu correo electrónico';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Correo electrónico inválido';
    return null;
  }

  void _validateAndStart() {
    setState(() {
      _emailError = _validateEmail(widget.controller.emailController.text);
    });
    if (_emailError == null) {
      widget.controller.startPasswordReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('reset-email'),
        children: [
          _BackHeader(controller: widget.controller),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Restablecer contraseña',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            controller: widget.controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
            onSubmitted: (_) => _validateAndStart(),
          ),
          const SizedBox(height: AppSpacing.l),
          AppPrimaryButton(
            label: 'Enviar código',
            isLoading: widget.controller.isLoading,
            onPressed: _validateAndStart,
          ),
          _ControllerError(controller: widget.controller),
        ],
      ),
    );
  }
}

class _ResetVerifyStep extends StatelessWidget {
  const _ResetVerifyStep({required this.controller});

  final EmailAuthController controller;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('reset-verify'),
        children: [
          _BackHeader(controller: controller),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Ingresa el código que enviamos a ${controller.emailController.text}',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.l),
          AppTextField(
            label: 'Código de 6 dígitos',
            hint: '000000',
            controller: controller.verificationCodeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
          ),
          const SizedBox(height: AppSpacing.l),
          AppPrimaryButton(
            label: 'Verificar',
            isLoading: controller.isLoading,
            onPressed: controller.verifyPasswordResetCode,
          ),
          _ControllerError(controller: controller),
        ],
      ),
    );
  }
}

class _ResetPasswordStep extends StatefulWidget {
  const _ResetPasswordStep({required this.controller});

  final EmailAuthController controller;

  @override
  State<_ResetPasswordStep> createState() => _ResetPasswordStepState();
}

class _ResetPasswordStepState extends State<_ResetPasswordStep> {
  String? _passwordError;

  bool get _hasMinLength =>
      widget.controller.passwordController.text.length >= 8;

  void _validateAndFinish() {
    setState(() {
      _passwordError = _hasMinLength
          ? null
          : 'La contraseña debe tener al menos 8 caracteres';
    });
    if (_passwordError == null) {
      widget.controller.finishPasswordReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        key: const ValueKey('reset-password'),
        children: [
          _BackHeader(controller: widget.controller),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Crea una nueva contraseña',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.m),
          AppTextField(
            label: 'Nueva contraseña',
            hint: 'Mínimo 8 caracteres',
            controller: widget.controller.passwordController,
            obscure: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            errorText: _passwordError,
            onSubmitted: (_) => _validateAndFinish(),
          ),
          const SizedBox(height: AppSpacing.l),
          AppPrimaryButton(
            label: 'Guardar contraseña',
            isLoading: widget.controller.isLoading,
            onPressed: _validateAndFinish,
          ),
          _ControllerError(controller: widget.controller),
        ],
      ),
    );
  }
}
