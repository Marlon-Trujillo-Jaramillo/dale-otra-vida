import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'map_logic.dart';
import 'tiles.dart';

/// Small, static map with the ~1 km zone of a listing (the same zones as the
/// map screen) and its neighborhood. Never a point on an address.
class ZoneMap extends StatelessWidget {
  const ZoneMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
    this.height = 160,
  });

  final double latitude;
  final double longitude;

  /// The neighborhood shown in the middle of the zone.
  final String? label;
  final double height;

  @override
  Widget build(BuildContext context) {
    // The owner's own listing keeps its real spot; snap it like the rest.
    final center = zoneOf(latitude, longitude).center;
    final label = this.label?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            osmTileLayer(),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: center,
                  radius: zoneRadiusMeters,
                  useRadiusInMeter: true,
                  color: AppColors.accent.withValues(alpha: 0.25),
                  borderColor: AppColors.accentStrong,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            if (label != null && label.isNotEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.accentStrong),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            // A one-line credit that shrinks with the map, unlike the
            // package widget, which overflows on narrow cards.
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                color: const Color(0xCCFBF9F5),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: const Text(
                  '© $osmAttribution',
                  style: TextStyle(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
