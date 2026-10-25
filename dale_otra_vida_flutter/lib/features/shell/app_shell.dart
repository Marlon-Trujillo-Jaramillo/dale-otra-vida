import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_colors.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_spacing.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_typography.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_secondary_button.dart';
import 'package:dale_otra_vida_flutter/core/widgets/empty_state.dart';
import 'package:dale_otra_vida_flutter/features/home/home_controller.dart';
import 'package:dale_otra_vida_flutter/features/home/home_screen.dart';
import 'package:dale_otra_vida_flutter/features/publish/publish_screen.dart';
import 'package:dale_otra_vida_flutter/screens/design_gallery_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.initialProfile,
    this.fetchFeed,
  });

  final MemberProfile? initialProfile;
  final ListingFeedFetch? fetchFeed;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  MemberProfile? _profile;
  bool _loadingProfile = true;
  String? _profileError;

  final _homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProfile;
    if (initial != null) {
      _profile = initial;
      _loadingProfile = false;
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });
    try {
      _profile = await client.profile.me();
    } catch (e) {
      _profileError = 'No pudimos cargar tu perfil.';
    } finally {
      _loadingProfile = false;
      if (mounted) setState(() {});
    }
  }

  void _openPublish() {
    final profile = _profile;
    if (profile == null) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute<bool>(
            builder: (context) => PublishScreen(profile: profile),
            fullscreenDialog: true,
          ),
        )
        .then((published) {
          _homeKey.currentState?.refresh();
          if (published == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Publicado! Gracias por darle otra vida.'),
              ),
            );
          }
        });
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final error = _profileError;
    if (error != null || _profile == null) {
      return Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'No pudimos cargar tu perfil',
            message: 'Revisa tu conexión e inténtalo de nuevo.',
            actionLabel: 'Reintentar',
            onAction: _loadProfile,
          ),
        ),
      );
    }

    final tabs = [
      HomeScreen(
        key: _homeKey,
        profile: _profile!,
        fetchFeed: widget.fetchFeed,
      ),
      const _PlaceholderTab(
        icon: Icons.chat_bubble_outline,
        title: 'Mensajes',
        message: 'Aquí verás tus conversaciones.',
      ),
      const _ProfilePlaceholder(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPublish,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomTab(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Inicio',
                        selected: _currentIndex == 0,
                        onTap: () => _onTabSelected(0),
                      ),
                    ),
                    Expanded(
                      child: _BottomTab(
                        icon: Icons.chat_bubble_outline,
                        activeIcon: Icons.chat_bubble,
                        label: 'Mensajes',
                        selected: _currentIndex == 1,
                        onTap: () => _onTabSelected(1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: _BottomTab(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Perfil',
                  selected: _currentIndex == 2,
                  onTap: () => _onTabSelected(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.onPrimary
        : AppColors.onPrimary.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? activeIcon : icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: EmptyState(
        icon: icon,
        title: title,
        message: message,
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyState(
            icon: Icons.person_outline,
            title: 'Perfil',
            message: 'Aquí verás y editarás tu perfil.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: AppSecondaryButton(
              label: 'Cerrar sesión',
              onPressed: () async => client.auth.signOutDevice(),
            ),
          ),
          if (kDebugMode)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const DesignGalleryScreen(),
                  ),
                );
              },
              child: const Text('Design Gallery'),
            ),
        ],
      ),
    );
  }
}
