import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../format.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Round member picture: the uploaded photo, or the initials on accent.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.imageUrl,
  });

  final String initials;
  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.title.copyWith(
            color: AppColors.textPrimary,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}

/// Avatar of a member from their name and optional photo.
AppAvatar memberAvatar(
  String displayName,
  String? avatarUrl, {
  double size = 48,
}) => AppAvatar(
  initials: initialsFor(displayName),
  imageUrl: avatarUrl,
  size: size,
);
