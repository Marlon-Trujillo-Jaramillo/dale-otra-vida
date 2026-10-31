import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../chat/chat_logic.dart';
import '../listing/listing_detail_logic.dart';

enum ProfileTab { listings, history, reviews }

/// Profile layout from the prototype: header, trust stats, tabs with
/// listings, delivery history and reviews. Shared by the Perfil tab and
/// other members' profiles.
class ProfileBody extends StatelessWidget {
  const ProfileBody({
    super.key,
    required this.view,
    required this.tab,
    required this.onTabChanged,
    required this.onOpenListing,
    this.actions,
    this.onReport,
  });

  final PublicProfileView view;
  final ProfileTab tab;
  final ValueChanged<ProfileTab> onTabChanged;
  final ValueChanged<ListingView> onOpenListing;

  /// Extra content under the stats, e.g. the member's own shortcuts.
  final Widget? actions;

  /// Shown as "Reportar usuario" at the bottom when set.
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final profile = view.profile;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ContentWidth(
            maxWidth: 960,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),
                memberAvatar(profile.displayName, profile.avatarUrl, size: 88),
                const SizedBox(height: AppSpacing.m),
                Text(
                  profile.displayName,
                  style: AppTypography.headline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                _Subtitle(profile: profile),
                const SizedBox(height: AppSpacing.xl),
                _Stats(profile: profile),
                if (actions != null) ...[
                  const SizedBox(height: AppSpacing.l),
                  actions!,
                ],
                const SizedBox(height: AppSpacing.xl),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: AppSegmentedControl(
                    options: [
                      'Publicaciones',
                      'Historial',
                      'Reseñas (${view.reviews.length})',
                    ],
                    selectedIndex: tab.index,
                    onChanged: (index) =>
                        onTabChanged(ProfileTab.values[index]),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
        ),
        ..._buildTab(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: onReport == null
                ? const SizedBox.shrink()
                : Center(
                    child: TextButton.icon(
                      onPressed: onReport,
                      icon: const Icon(
                        Icons.flag_outlined,
                        color: AppColors.danger,
                        size: 18,
                      ),
                      label: Text(
                        'Reportar usuario',
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTab(BuildContext context) {
    switch (tab) {
      case ProfileTab.listings:
        return [
          _ListingGrid(
            listings: view.listings,
            labelFor: view.isMe ? ownListingLabel : _publicLabel,
            emptyTitle: view.isMe
                ? 'Aún no has publicado nada'
                : 'No tiene publicaciones activas',
            emptyMessage: view.isMe
                ? 'Toca + para darle otra vida a algo que ya no usas.'
                : 'Vuelve pronto para ver lo que comparte.',
            onOpen: onOpenListing,
          ),
        ];
      case ProfileTab.history:
        return [
          _ListingGrid(
            listings: view.history,
            labelFor: (_, {now}) => 'Entregado',
            emptyTitle: 'Sin entregas todavía',
            emptyMessage: 'Aquí aparecerá lo que ya encontró un nuevo hogar.',
            onOpen: onOpenListing,
          ),
        ];
      case ProfileTab.reviews:
        if (view.reviews.isEmpty) {
          return [
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.star_outline_rounded,
                title: 'Sin reseñas todavía',
                message: 'Las reseñas llegan después de cada entrega.',
              ),
            ),
          ];
        }
        return [
          SliverToBoxAdapter(
            child: ContentWidth(
              maxWidth: 720,
              child: Column(
                children: [
                  for (final review in view.reviews) ...[
                    _ReviewTile(view: review),
                    const SizedBox(height: AppSpacing.m),
                  ],
                ],
              ),
            ),
          ),
        ];
    }
  }

  static String? _publicLabel(Listing listing, {DateTime? now}) =>
      listing.status == ListingStatus.reserved ? 'Reservado' : null;
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    final neighborhood = profile.neighborhood;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.xs,
      children: [
        AccountTypeBadge(type: profile.accountType),
        if (profile.isVerified)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 16, color: AppColors.verified),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Usuario verificado',
                style: AppTypography.caption.copyWith(
                  color: AppColors.verified,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        if (neighborhood != null && neighborhood.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 2),
              Text(neighborhood, style: AppTypography.caption),
            ],
          ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.headline),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              stat(
                profile.reviewCount == 0
                    ? '–'
                    : formatRating(profile.ratingAvg),
                'Calificación',
              ),
              const VerticalDivider(color: AppColors.borderLight),
              stat('${profile.reviewCount}', 'Reseñas'),
              const VerticalDivider(color: AppColors.borderLight),
              stat('${profile.deliveryCount}', 'Entregas'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingGrid extends StatelessWidget {
  const _ListingGrid({
    required this.listings,
    required this.labelFor,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onOpen,
  });

  final List<ListingView> listings;
  final String? Function(Listing listing, {DateTime? now}) labelFor;
  final String emptyTitle;
  final String emptyMessage;
  final ValueChanged<ListingView> onOpen;

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: emptyTitle,
          message: emptyMessage,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: ContentWidth(
        maxWidth: 960,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: listingGridDelegate(maxTileWidth: 260, minColumns: 2),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final view = listings[index];
            return ListingGridCard.fromView(
              view,
              statusLabel: labelFor(view.listing),
              onTap: () => onOpen(view),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.view});

  final ReviewView view;

  @override
  Widget build(BuildContext context) {
    final review = view.review;
    final comment = review.comment;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          memberAvatar(
            view.reviewer.displayName,
            view.reviewer.avatarUrl,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        view.reviewer.displayName,
                        style: AppTypography.bodyStrong,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      formatRelative(review.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    for (var star = 1; star <= 5; star++)
                      Icon(
                        star <= review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 18,
                        color: star <= review.rating
                            ? AppColors.accent
                            : AppColors.border,
                      ),
                  ],
                ),
                if (comment != null && comment.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(comment, style: AppTypography.body),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
