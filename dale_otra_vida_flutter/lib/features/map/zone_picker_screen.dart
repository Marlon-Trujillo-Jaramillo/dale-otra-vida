import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'map_logic.dart';
import 'tiles.dart';

/// Lets the member place a listing by moving the map instead of using GPS.
/// The circle follows the ~1 km zone under the centre, which is all other
/// members will ever see. Returns the centre, or null when cancelled.
class ZonePickerScreen extends StatefulWidget {
  const ZonePickerScreen({super.key, this.initial});

  final LatLng? initial;

  @override
  State<ZonePickerScreen> createState() => _ZonePickerScreenState();
}

class _ZonePickerScreenState extends State<ZonePickerScreen> {
  late LatLng _center = widget.initial ?? medellin;

  @override
  Widget build(BuildContext context) {
    final zone = zoneOf(_center.latitude, _center.longitude);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Elige tu zona', style: AppTypography.title),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: widget.initial == null ? 12.5 : 14,
              minZoom: 10,
              maxZoom: 16,
              onPositionChanged: (camera, _) =>
                  setState(() => _center = camera.center),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              osmTileLayer(),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: zone.center,
                    radius: zoneRadiusMeters,
                    useRadiusInMeter: true,
                    color: AppColors.accent.withValues(alpha: 0.3),
                    borderColor: AppColors.accentStrong,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              const SimpleAttributionWidget(
                source: Text(osmAttribution),
                backgroundColor: Color(0xCCFBF9F5),
              ),
            ],
          ),
          // The point being chosen: always the middle of the map.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.m,
            left: AppSpacing.l,
            right: AppSpacing.l,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Mueve el mapa hasta tu barrio. Los demás solo verán el '
                'círculo de la zona (~1 km), nunca tu dirección.',
                style: AppTypography.caption,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.l,
            right: AppSpacing.l,
            bottom: AppSpacing.l,
            child: SafeArea(
              top: false,
              child: AppPrimaryButton(
                label: 'Usar esta zona',
                onPressed: () => Navigator.of(context).pop(_center),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
