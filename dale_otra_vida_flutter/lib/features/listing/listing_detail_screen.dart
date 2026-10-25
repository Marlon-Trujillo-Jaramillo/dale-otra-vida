import 'package:cached_network_image/cached_network_image.dart';
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../../client.dart';
import '../../core/format.dart';
import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.view});

  final ListingView view;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late ListingView _view;
  int _currentPhoto = 0;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _view = widget.view;
  }

  Future<void> _updateStatus(ListingStatus status) async {
    setState(() => _updating = true);
    try {
      final updated = await client.listing.updateStatus(
        _view.listing.id!,
        status,
      );
      if (!mounted) return;
      setState(
        () => _view = updated.copyWith(distanceKm: _view.distanceKm),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revisa los datos e inténtalo de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  Future<void> _withdraw() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirar publicación'),
        content: const Text(
          '¿Seguro que quieres retirar esta publicación? Ya no aparecerá en el feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Retirar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _updateStatus(ListingStatus.withdrawn);
  }

  void _showSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponible muy pronto')),
    );
  }

  void _openPhotoFullscreen(String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _PhotoViewerScreen(imageUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listing = _view.listing;
    final owner = _view.owner;
    final typeUi = ListingTypeUi.fromServer(listing.type);
    final categoryUi = CategoryUi.fromServer(listing.category);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildCarousel(context)),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildBadges(typeUi, categoryUi),
                        const SizedBox(height: AppSpacing.m),
                        Text(listing.title, style: AppTypography.headline),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Publicado el ${formatDate(listing.createdAt)}',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        _buildInfoCards(listing),
                        const SizedBox(height: AppSpacing.l),
                        _buildDescription(listing),
                        const SizedBox(height: AppSpacing.l),
                        _buildMeetingPoint(listing),
                        const SizedBox(height: AppSpacing.l),
                        _buildOwnerCard(owner),
                        const SizedBox(height: AppSpacing.xl),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    final photos = _view.listing.photoUrls;
    return Stack(
      children: [
        Container(
          height: 300,
          color: AppColors.surfaceMuted,
          child: photos.isEmpty
              ? const Center(
                  child: Icon(Icons.image, size: 64, color: AppColors.textHint),
                )
              : PageView.builder(
                  itemCount: photos.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPhoto = index),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openPhotoFullscreen(photos[index]),
                      child: CachedNetworkImage(
                        imageUrl: photos[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          top: AppSpacing.m,
          left: AppSpacing.screenHorizontal,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (photos.length > 1)
          Positioned(
            bottom: AppSpacing.m,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final selected = index == _currentPhoto;
                return Container(
                  width: selected ? 8 : 6,
                  height: selected ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildBadges(ListingTypeUi typeUi, CategoryUi categoryUi) {
    return Wrap(
      spacing: AppSpacing.s,
      children: [
        TypeBadge(type: typeUi),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            categoryUi.label,
            style: AppTypography.badge.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(Listing listing) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            label: 'Estado',
            value: conditionLabel(listing.condition),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: _typeSpecificCard(listing)),
      ],
    );
  }

  Widget _typeSpecificCard(Listing listing) {
    if (listing.expiresAt != null) {
      return _InfoCard(
        label: 'Fecha de vencimiento',
        value: formatDate(listing.expiresAt!),
        highlight: true,
      );
    }
    return switch (listing.type) {
      ListingType.donate => const SizedBox.shrink(),
      ListingType.sell => _InfoCard(
        label: 'Precio',
        value: listing.price != null ? formatCop(listing.price!) : 'Gratis',
      ),
      ListingType.lend => _InfoCard(
        label: 'Devolver antes de',
        value: listing.returnDate != null
            ? formatDate(listing.returnDate!)
            : 'A convenir',
      ),
      ListingType.exchange => _InfoCard(
        label: 'Busca a cambio',
        value: listing.wantedInExchange?.isNotEmpty == true
            ? listing.wantedInExchange!
            : 'A convenir',
      ),
    };
  }

  Widget _buildDescription(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción', style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.s),
        Text(listing.description, style: AppTypography.body),
      ],
    );
  }

  Widget _buildMeetingPoint(Listing listing) {
    final distance = _view.distanceKm != null
        ? formatDistance(_view.distanceKm!)
        : null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Punto de encuentro seguro',
                style: AppTypography.bodyStrong,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            listing.safeMeetingPoint ?? 'A convenir en un lugar público',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            distance != null
                ? '${listing.neighborhood} · $distance'
                : listing.neighborhood,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCard(MemberProfile owner) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppAvatar(initials: initialsFor(owner.displayName)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        owner.displayName,
                        style: AppTypography.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (owner.isVerified) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.verified,
                        color: AppColors.verified,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '★ ${owner.ratingAvg.toStringAsFixed(1)} · '
                  '${owner.reviewCount} reseñas · '
                  '${owner.deliveryCount} entregas',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final listing = _view.listing;
    final status = listing.status;

    Widget content;
    if (_view.isMine) {
      final actions = allowedOwnerActions(status);
      if (actions.isEmpty) {
        content = const SizedBox.shrink();
      } else {
        final mainAction = actions.first;
        final secondaryActions = actions
            .where((action) => action != OwnerAction.withdraw)
            .toList();
        content = Column(
          children: [
            for (final action in secondaryActions) ...[
              if (action == mainAction)
                AppPrimaryButton(
                  label: _actionLabel(action),
                  onPressed: _updating ? null : () => _executeAction(action),
                )
              else
                AppSecondaryButton(
                  label: _actionLabel(action),
                  onPressed: _updating ? null : () => _executeAction(action),
                ),
              const SizedBox(height: AppSpacing.s),
            ],
            if (actions.contains(OwnerAction.withdraw))
              TextButton(
                onPressed: _updating ? null : _withdraw,
                child: Text(
                  'Retirar',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
          ],
        );
      }
    } else {
      content = Row(
        children: [
          InkWell(
            onTap: _showSoonSnackBar,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.chat_bubble_outline),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: AppPrimaryButton(
              label: 'Lo quiero',
              onPressed: _showSoonSnackBar,
            ),
          ),
        ],
      );
    }

    final banner = status != ListingStatus.available
        ? Container(
            width: double.infinity,
            color: AppColors.surfaceMuted,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Text(
              _statusLabel(status),
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong,
            ),
          )
        : const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.m,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          banner,
          content,
        ],
      ),
    );
  }

  void _executeAction(OwnerAction action) {
    switch (action) {
      case OwnerAction.reserve:
        _updateStatus(ListingStatus.reserved);
      case OwnerAction.markAvailable:
        _updateStatus(ListingStatus.available);
      case OwnerAction.markDelivered:
        _updateStatus(ListingStatus.delivered);
      case OwnerAction.withdraw:
        _withdraw();
    }
  }
}

enum OwnerAction { reserve, markAvailable, markDelivered, withdraw }

List<OwnerAction> allowedOwnerActions(ListingStatus status) {
  return switch (status) {
    ListingStatus.available => [
      OwnerAction.reserve,
      OwnerAction.withdraw,
    ],
    ListingStatus.reserved => [
      OwnerAction.markAvailable,
      OwnerAction.markDelivered,
      OwnerAction.withdraw,
    ],
    ListingStatus.delivered || ListingStatus.withdrawn => [],
  };
}

String _actionLabel(OwnerAction action) {
  return switch (action) {
    OwnerAction.reserve => 'Reservar',
    OwnerAction.markAvailable => 'Marcar como disponible',
    OwnerAction.markDelivered => 'Marcar como entregado',
    OwnerAction.withdraw => 'Retirar',
  };
}

String _statusLabel(ListingStatus status) {
  return switch (status) {
    ListingStatus.available => '',
    ListingStatus.reserved => 'Reservado',
    ListingStatus.delivered => 'Entregado',
    ListingStatus.withdrawn => 'Retirado',
  };
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF6E3CF) : AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: highlight ? const Color(0xFF8A3D10) : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyStrong.copyWith(
              color: highlight ? const Color(0xFF8A3D10) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  const _PhotoViewerScreen({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: CachedNetworkImage(imageUrl: imageUrl),
              ),
            ),
            Positioned(
              top: AppSpacing.m,
              left: AppSpacing.screenHorizontal,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
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
