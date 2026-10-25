import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_colors.dart';
import 'package:dale_otra_vida_flutter/core/widgets/widgets.dart';
import 'package:dale_otra_vida_flutter/features/auth/auth_screen.dart';
import 'package:dale_otra_vida_flutter/features/onboarding/onboarding_screen.dart';
import 'package:dale_otra_vida_flutter/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Routes between sign-in, onboarding and the app based on auth state and
/// whether the member already has a profile.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<MemberProfile?>? _profile;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {
      _profile = client.auth.isAuthenticated ? client.profile.me() : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (profile == null) return const AuthScreen();

    return FutureBuilder<MemberProfile?>(
      future: profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'No pudimos conectarnos',
                message: 'Revisa tu conexión e inténtalo de nuevo.',
                actionLabel: 'Reintentar',
                onAction: _onAuthChanged,
              ),
            ),
          );
        }
        if (snapshot.data == null) {
          return OnboardingScreen(onCompleted: _onAuthChanged);
        }
        return const AppShell();
      },
    );
  }
}
