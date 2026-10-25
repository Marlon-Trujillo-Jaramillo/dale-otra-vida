import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_secondary_button.dart';
import '../../screens/design_gallery_screen.dart';
import '../requests/my_requests_screen.dart';
import 'my_listings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profile});

  final MemberProfile profile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _requestCount;
  bool _loadingRequests = false;

  @override
  void initState() {
    super.initState();
    _loadRequestCount();
  }

  Future<void> _loadRequestCount() async {
    setState(() => _loadingRequests = true);
    try {
      final result = await client.request.mine();
      if (!mounted) return;
      setState(() => _requestCount = result.length);
    } catch (_) {
      if (!mounted) return;
      setState(() => _requestCount = null);
    } finally {
      if (mounted) {
        setState(() => _loadingRequests = false);
      }
    }
  }

  void _openMyListings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const MyListingsScreen(),
      ),
    );
  }

  void _openMyRequests(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => const MyRequestsScreen(),
          ),
        )
        .then((_) => _loadRequestCount());
  }

  Future<void> _signOut() async {
    await client.auth.signOutDevice();
  }

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);

    return Scaffold(
      appBar: size == ScreenSize.compact
          ? null
          : AppBar(
              title: Text('Perfil', style: AppTypography.title),
              centerTitle: true,
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal).copyWith(
            top: AppSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xl),
              _ProfileTile(
                icon: Icons.list_alt,
                title: 'Mis publicaciones',
                subtitle: 'Tus publicaciones activas',
                onTap: () => _openMyListings(context),
              ),
              const SizedBox(height: AppSpacing.s),
              _ProfileTile(
                icon: Icons.favorite_border,
                title: 'Mis solicitudes',
                subtitle: 'Lo que has pedido',
                trailing: _loadingRequests
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _requestCount != null && _requestCount! > 0
                    ? _CountBadge(count: _requestCount!)
                    : null,
                onTap: () => _openMyRequests(context),
              ),
              const SizedBox(height: AppSpacing.l),
              AppSecondaryButton(
                label: 'Cerrar sesión',
                onPressed: _signOut,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: AppSpacing.m),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          size: 72,
          initials: initialsFor(widget.profile.displayName),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.profile.displayName,
                style: AppTypography.headline,
              ),
              if (widget.profile.neighborhood != null &&
                  widget.profile.neighborhood!.isNotEmpty)
                Text(
                  widget.profile.neighborhood!,
                  style: AppTypography.body,
                ),
            ],
          ),
        ),
      ],
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
