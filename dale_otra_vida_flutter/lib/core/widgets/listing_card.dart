import 'package:cached_network_image/cached_network_image.dart';
import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';

import '../format.dart';
import '../models/listing_type_ui.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'type_badge.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.title,
    required this.type,
    required this.meta,
    required this.location,
    required this.distance,
    this.imageUrl,
    this.onTap,
  });

  factory ListingCard.fromView(ListingView view, {VoidCallback? onTap}) {
    final listing = view.listing;
    final typeUi = ListingTypeUi.fromServer(listing.type);

    return ListingCard(
      title: listing.title,
      type: typeUi,
      meta: _metaFor(listing),
      location: listing.neighborhood,
      distance: view.distanceKm != null ? formatDistance(view.distanceKm!) : '',
      imageUrl: listing.photoUrls.isNotEmpty ? listing.photoUrls.first : null,
      onTap: onTap,
    );
  }

  final String title;
  final ListingTypeUi type;
  final String meta;
  final String location;
  final String distance;
  final String? imageUrl;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(imageUrl),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TypeBadge(type: type),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: AppTypography.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(meta, style: AppTypography.caption),
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
                          _locationLine(location, distance),
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
  }

  Widget _buildImage(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 84,
        height: 84,
        color: AppColors.surfaceMuted,
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const _PlaceholderIcon(),
                errorWidget: (context, url, error) => const _PlaceholderIcon(),
              )
            : const _PlaceholderIcon(),
      ),
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
    return const Icon(
      Icons.image,
      color: AppColors.textHint,
      size: 32,
    );
  }
}
