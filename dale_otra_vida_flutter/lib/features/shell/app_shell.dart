import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:dale_otra_vida_flutter/client.dart';
import 'package:dale_otra_vida_flutter/core/format.dart';
import 'package:dale_otra_vida_flutter/core/layout/breakpoints.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_colors.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_spacing.dart';
import 'package:dale_otra_vida_flutter/core/theme/app_typography.dart';
import 'package:dale_otra_vida_flutter/core/widgets/app_avatar.dart';
import 'package:dale_otra_vida_flutter/core/widgets/empty_state.dart';
import 'package:dale_otra_vida_flutter/features/home/home_controller.dart';
import 'package:dale_otra_vida_flutter/features/home/home_screen.dart';
import 'package:dale_otra_vida_flutter/features/notifications/notifications_badge_controller.dart';
import 'package:dale_otra_vida_flutter/features/notifications/notifications_screen.dart';
import 'package:dale_otra_vida_flutter/features/profile/profile_screen.dart';
import 'package:dale_otra_vida_flutter/features/publish/publish_screen.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.initialProfile,
    this.fetchFeed,
    this.badgeController,
  });

  final MemberProfile? initialProfile;
  final ListingFeedFetch? fetchFeed;
  final NotificationsBadgeController? badgeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  MemberProfile? _profile;
  bool _loadingProfile = true;
  String? _profileError;

  final _homeKey = GlobalKey<HomeScreenState>();
  late final NotificationsBadgeController _badgeController;

  @override
  void initState() {
    super.initState();
    _badgeController =
        widget.badgeController ??
        NotificationsBadgeController(
          fetchUnreadCount: () => client.notification.unreadCount(),
        );
    _badgeController.start();

    final initial = widget.initialProfile;
    if (initial != null) {
      _profile = initial;
      _loadingProfile = false;
    } else {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    if (widget.badgeController == null) {
      _badgeController.dispose();
    } else {
      _badgeController.stop();
    }
    super.dispose();
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

    final size = ScreenSize.of(context);
    final Future<bool?> published = size == ScreenSize.compact
        ? Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (context) => PublishScreen(profile: profile),
              fullscreenDialog: true,
            ),
          )
        : showDialog<bool>(
            context: context,
            builder: (context) => _PublishDialog(profile: profile),
          );

    published.then((published) {
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

  void _openNotifications() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => const NotificationsScreen(),
          ),
        )
        .then((_) {
          if (mounted) {
            _badgeController.refresh();
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
        badgeController: _badgeController,
      ),
      const _PlaceholderTab(
        icon: Icons.chat_bubble_outline,
        title: 'Mensajes',
        message: 'Aquí verás tus conversaciones.',
      ),
      ProfileScreen(profile: _profile!),
    ];

    final size = ScreenSize.of(context);

    if (size == ScreenSize.compact) {
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

    if (size == ScreenSize.medium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.primary,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              extended: false,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(
                color: AppColors.onPrimary,
              ),
              selectedLabelTextStyle: AppTypography.caption.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.onPrimary,
              ),
              unselectedLabelTextStyle: AppTypography.caption.copyWith(
                color: AppColors.onPrimary,
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'rail_publish',
                      onPressed: _openPublish,
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 2,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Publicar',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: AnimatedBuilder(
                animation: _badgeController,
                builder: (context, child) {
                  return _RailBell(
                    countLabel: _badgeController.label,
                    hasUnread: _badgeController.hasUnread,
                    onTap: _openNotifications,
                  );
                },
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Inicio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: Text('Mensajes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Perfil'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: tabs,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: ContentWidth(
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.eco_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Text(
                        'Dale Otra Vida',
                        style: AppTypography.title.copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _TopNavButton(
                    label: 'Inicio',
                    selected: _currentIndex == 0,
                    onTap: () => _onTabSelected(0),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  _TopNavButton(
                    label: 'Mensajes',
                    selected: _currentIndex == 1,
                    onTap: () => _onTabSelected(1),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  _TopNavButton(
                    label: 'Perfil',
                    selected: _currentIndex == 2,
                    onTap: () => _onTabSelected(2),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  AnimatedBuilder(
                    animation: _badgeController,
                    builder: (context, child) {
                      return _BellIconButton(
                        countLabel: _badgeController.label,
                        hasUnread: _badgeController.hasUnread,
                        onTap: _openNotifications,
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.s),
                  FilledButton.icon(
                    onPressed: _openPublish,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Publicar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  AppAvatar(
                    size: 32,
                    initials: initialsFor(_profile!.displayName),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: tabs,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishDialog extends StatelessWidget {
  const _PublishDialog({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.l,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: PublishScreen(profile: profile),
        ),
      ),
    );
  }
}

class _TopNavButton extends StatelessWidget {
  const _TopNavButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.bodyStrong.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 2,
              width: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
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

class _BellIconButton extends StatelessWidget {
  const _BellIconButton({
    required this.countLabel,
    required this.hasUnread,
    required this.onTap,
  });

  final String countLabel;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
          if (hasUnread)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.accentStrong,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    countLabel,
                    style: AppTypography.badge.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RailBell extends StatelessWidget {
  const _RailBell({
    required this.countLabel,
    required this.hasUnread,
    required this.onTap,
  });

  final String countLabel;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: AppColors.onPrimary,
            ),
            if (hasUnread)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.accentStrong,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      countLabel,
                      style: AppTypography.badge.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
