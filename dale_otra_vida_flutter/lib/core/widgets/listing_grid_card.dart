import 'package:cached_network_image/cached_network_image.dart';
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../format.dart';
import '../models/listing_type_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'type_badge.dart';

class ListingGridCard extends StatefulWidget {
  const ListingGridCard({
    super.key,
    required this.title,
    required this.type,
    required this.meta,
    required this.location,
    required this.distance,
    this.imageUrl,
    this.onTap,
    this.statusLabel,
  });

  factory ListingGridCard.fromView(
    ListingView view, {
    VoidCallback? onTap,
    String? statusLabel,
  }) {
    final listing = view.listing;
    final typeUi = ListingTypeUi.fromServer(listing.type);

    return ListingGridCard(
      title: listing.title,
      type: typeUi,
      meta: _metaFor(listing),
      location: listing.neighborhood,
      distance: view.distanceKm != null ? formatDistance(view.distanceKm!) : '',
      imageUrl: listing.photoUrls.isNotEmpty ? listing.photoUrls.first : null,
      onTap: onTap,
      statusLabel: statusLabel,
    );
  }

  final String title;
  final ListingTypeUi type;
  final String meta;
  final String location;
  final String distance;
  final String? imageUrl;
  final VoidCallback? onTap;

  /// Optional pill over the photo, e.g. "Vencida" or "Reservado".
  final String? statusLabel;

  @override
  State<ListingGridCard> createState() => _ListingGridCardState();
}

class _ListingGridCardState extends State<ListingGridCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    );

    final child = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _hover
              ? const [
                  BoxShadow(
                    color: Color(0x141E3A2F),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: borderRadius,
                    child: _buildImage(widget.imageUrl),
                  ),
                  if (widget.statusLabel != null)
                    Positioned(
                      top: AppSpacing.s,
                      left: AppSpacing.s,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.statusLabel!,
                          style: AppTypography.badge.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TypeBadge(type: widget.type),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    widget.title,
                    style: AppTypography.bodyStrong,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.meta,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _locationLine(widget.location, widget.distance),
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  Widget _buildImage(String? url) {
    return Container(
      color: AppColors.surfaceMuted,
      child: url != null && url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => const _PlaceholderIcon(),
              errorWidget: (context, url, error) => const _PlaceholderIcon(),
            )
          : const _PlaceholderIcon(),
    );
  }
}

String _metaFor(Listing listing) {
  final condition = conditionLabel(listing.condition);
  if (listing.expiresAt != null) {
    return 'Vence: ${formatDate(listing.expiresAt!)} · Estado: $condition';
  }
  return switch (listing.type) {
    ListingType.donate => 'Estado: $condition',
    ListingType.sell =>
      listing.price != null
          ? '${formatCop(listing.price!)} · Estado: $condition'
          : 'Estado: $condition',
    ListingType.lend =>
      listing.returnDate != null
          ? 'Hasta ${formatDate(listing.returnDate!)}'
          : 'Estado: $condition',
    ListingType.exchange =>
      listing.wantedInExchange != null && listing.wantedInExchange!.isNotEmpty
          ? 'Busca: ${listing.wantedInExchange}'
          : 'Estado: $condition',
  };
}

String _locationLine(String location, String distance) {
  if (distance.isEmpty) return location;
  final formattedDistance = distance.startsWith('a ')
      ? distance
      : 'a $distance';
  return '$location · $formattedDistance';
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image, color: AppColors.textHint, size: 32),
    );
  }
}
