import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../app/navigation.dart';
import '../../client.dart';
import '../../core/install/install_app.dart';
import '../../core/legal.dart';
import '../../core/push/push.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../../screens/design_gallery_screen.dart';
import '../feedback/feedback_sheet.dart';
import '../install/install_prompt.dart';
import '../push/push_card.dart';
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
    await openListing(context, listing);
    if (mounted) _load();
  }

  Future<void> _editProfile() async {
    final current = _view?.profile;
    if (current == null) return;
    // The public view hides coordinates; edits never touch them. The edit
    // screen confirms the save itself; reload to show it here and in the
    // shell's greeting and avatar.
    await openEditProfile(context, current);
    if (!mounted) return;
    try {
      final saved = await client.profile.me();
      if (saved != null && mounted) widget.onProfileChanged?.call(saved);
    } catch (_) {
      // The profile below reloads anyway.
    }
    if (mounted) _load();
  }

  void _openMyRequests(BuildContext context) {
    openMyRequests(context).then((_) {
      if (mounted) _load();
    });
  }

  /// Whether this member reviews identity checks; the server decides.
  late final Future<bool> _isAdmin = client.identity.isAdmin().catchError(
    (_) => false,
  );

  Future<void> _openIdentity(BuildContext context) async {
    await openIdentity(context);
    if (mounted) _load();
  }

  Future<void> _signOut() async {
    await Push.signOut();
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
          const SizedBox(height: AppSpacing.s),
          _ProfileTile(
            icon: Icons.rate_review_outlined,
            title: 'Danos tu opinión',
            subtitle: 'Cuéntanos qué te gustó o qué mejorarías',
            onTap: () => showFeedbackSheet(context, screen: 'perfil'),
          ),
          if (installState() != InstallState.none) ...[
            const SizedBox(height: AppSpacing.s),
            _ProfileTile(
              icon: Icons.install_mobile,
              title: 'Instalar la app',
              subtitle: 'Tenla en tu pantalla de inicio',
              onTap: () => startInstall(context),
            ),
          ],
          if (!(_view?.profile.isVerified ?? widget.profile.isVerified)) ...[
            const SizedBox(height: AppSpacing.s),
            _ProfileTile(
              icon: Icons.verified_user_outlined,
              title: 'Verificar identidad',
              subtitle: 'Necesaria para pedir préstamos',
              onTap: () => _openIdentity(context),
            ),
          ],
          FutureBuilder<bool>(
            future: _isAdmin,
            builder: (context, snapshot) => snapshot.data == true
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.s),
                    child: _ProfileTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Revisar identidades',
                      subtitle: 'Solo administradores',
                      onTap: () => openIdentityReview(context),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const PushCard(padding: EdgeInsets.only(top: AppSpacing.s)),
          const SizedBox(height: AppSpacing.s),
          const _ProfileTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de datos',
            subtitle: 'Tus derechos: escribe a $privacyContactEmail',
            onTap: openPrivacyPolicy,
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
