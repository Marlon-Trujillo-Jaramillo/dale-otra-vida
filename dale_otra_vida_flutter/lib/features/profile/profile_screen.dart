import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../screens/design_gallery_screen.dart';
import '../requests/my_requests_screen.dart';
import '../listing/listing_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_body.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    this.onProfileChanged,
  });

  final MemberProfile profile;

  /// Lets the shell refresh the greeting and top-bar avatar after edits.
  final ValueChanged<MemberProfile>? onProfileChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PublicProfileView? _view;
  bool _failed = false;
  ProfileTab _tab = ProfileTab.listings;
  int? _requestCount;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final results = await Future.wait([
        client.profile.publicProfile(widget.profile.id!),
        client.request.mine(),
      ]);
      if (!mounted) return;
      setState(() {
        _view = results[0] as PublicProfileView;
        _requestCount = (results[1] as List<MyRequestView>).length;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = _view == null);
    }
  }

  Future<void> _openListing(ListingView listing) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ListingDetailScreen(view: listing),
      ),
    );
    _load();
  }

  Future<void> _editProfile() async {
    final current = _view?.profile;
    if (current == null) return;
    // The public view hides coordinates; edits never touch them.
    final saved = await Navigator.of(context).push<MemberProfile>(
      MaterialPageRoute<MemberProfile>(
        builder: (context) => EditProfileScreen(profile: current),
      ),
    );
    if (saved == null || !mounted) return;
    widget.onProfileChanged?.call(saved);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
    _load();
  }

  void _openMyRequests(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => const MyRequestsScreen(),
          ),
        )
        .then((_) => _load());
  }

  Future<void> _signOut() async {
    await client.auth.signOutDevice();
  }

  @override
  Widget build(BuildContext context) {
    final view = _view;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: view == null
            ? _failed
                  ? EmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: 'No pudimos cargar tu perfil',
                      message: 'Revisa tu conexión e inténtalo de nuevo.',
                      actionLabel: 'Reintentar',
                      onAction: _load,
                    )
                  : const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ProfileBody(
                  view: view,
                  tab: _tab,
                  onTabChanged: (tab) => setState(() => _tab = tab),
                  onOpenListing: _openListing,
                  actions: _buildActions(context),
                ),
              ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileTile(
            icon: Icons.edit_outlined,
            title: 'Editar perfil',
            subtitle: 'Foto, nombre, barrio y tipo de cuenta',
            onTap: _editProfile,
          ),
          const SizedBox(height: AppSpacing.s),
          _ProfileTile(
            icon: Icons.favorite_border,
            title: 'Mis solicitudes',
            subtitle: 'Lo que has pedido',
            trailing: _requestCount != null && _requestCount! > 0
                ? _CountBadge(count: _requestCount!)
                : null,
            onTap: () => _openMyRequests(context),
          ),
          const SizedBox(height: AppSpacing.m),
          AppSecondaryButton(label: 'Cerrar sesión', onPressed: _signOut),
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

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentStrong,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.badge.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
              child: Icon(icon, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyStrong),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.s),
              trailing!,
            ],
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
