import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import 'tiles.dart';

/// Small, static map with a circle around an approximate location.
class ZoneMap extends StatelessWidget {
  const ZoneMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 140,
  });

  final double latitude;
  final double longitude;
  final double height;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
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
                  radius: 250,
                  useRadiusInMeter: true,
                  color: AppColors.accent.withValues(alpha: 0.25),
                  borderColor: AppColors.accentStrong,
                  borderStrokeWidth: 2,
                ),
              ],
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
