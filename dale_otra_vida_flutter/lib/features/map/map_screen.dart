import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../app/navigation.dart';
import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/location.dart';
import '../../core/models/listing_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import 'map_logic.dart';
import 'tiles.dart';

/// Listings around the member on a map, grouped into ~1 km zones: one big
/// circle per zone with its neighborhood, never a pin on a house.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  ({double lat, double lng})? _location;
  List<ListingView> _listings = [];
  MapZone? _zone;
  ListingTypeUi? _type;
  bool _loading = false;
  bool _tooFar = false;
  String? _error;
  Timer? _debounce;
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    final location = await currentApproxLocation();
    if (!mounted || location == null) return;
    setState(() => _location = location);
    _mapController.move(LatLng(location.lat, location.lng), 15);
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load(camera));
  }

  Future<void> _load([MapCamera? camera]) async {
    final bounds = (camera ?? _mapController.camera).visibleBounds;
    final tooFar = isAreaTooLarge(
      south: bounds.south,
      west: bounds.west,
      north: bounds.north,
      east: bounds.east,
    );
    if (tooFar) {
      setState(() {
        _tooFar = true;
        _listings = [];
        _zone = null;
      });
      return;
    }

    final gen = ++_gen;
    setState(() {
      _tooFar = false;
      _loading = true;
      _error = null;
    });
    try {
      final listings = await client.listing.inArea(
        south: bounds.south,
        west: bounds.west,
        north: bounds.north,
        east: bounds.east,
        type: _type?.toServer,
        latitude: _location?.lat,
        longitude: _location?.lng,
      );
      if (!mounted || gen != _gen) return;
      setState(() {
        _listings = listings;
      });
    } catch (_) {
      if (mounted && gen == _gen) {
        setState(() => _error = 'No pudimos cargar el mapa.');
      }
    } finally {
      if (mounted && gen == _gen) setState(() => _loading = false);
    }
  }

  void _setType(ListingTypeUi? type) {
    setState(() => _type = _type == type ? null : type);
    _load();
  }

  void _selectZone(MapZone zone) {
    setState(() => _zone = zone);
    _mapController.move(zone.center, _mapController.camera.zoom);
  }

  /// The selected zone as it is in the latest results, if still there.
  MapZone? get _currentZone {
    final key = _zone?.key;
    if (key == null) return null;
    for (final zone in groupIntoZones(_listings)) {
      if (zone.key == key) return zone;
    }
    return null;
  }

  Future<void> _openDetail(ListingView view) async {
    await openListing(context, view);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final wide = !ScreenSize.of(context).isCompact;
    final map = _buildMap(wide: wide);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mapa', style: AppTypography.title),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: wide
          ? Row(
              children: [
                SizedBox(width: 380, child: _buildSideList()),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
                Expanded(child: map),
              ],
            )
          : map,
    );
  }

  Widget _buildMap({required bool wide}) {
    final location = _location;
    final zones = groupIntoZones(_listings);
    final selectedZone = _currentZone;
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: location == null
                ? medellin
                : LatLng(location.lat, location.lng),
            initialZoom: 14,
            minZoom: 5,
            maxZoom: 18,
            onMapReady: _load,
            onPositionChanged: _onPositionChanged,
            onTap: (_, _) => setState(() => _zone = null),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            osmTileLayer(),
            if (location != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(location.lat, location.lng),
                    radius: 9,
                    color: const Color(0xFF2B6CB0),
                    borderColor: Colors.white,
                    borderStrokeWidth: 3,
                  ),
                ],
              ),
            CircleLayer(
              circles: [
                for (final zone in zones)
                  CircleMarker(
                    point: zone.center,
                    radius: zoneRadiusMeters,
                    useRadiusInMeter: true,
                    color: AppColors.accent.withValues(
                      alpha: zone.key == selectedZone?.key ? 0.4 : 0.22,
                    ),
                    borderColor: AppColors.accentStrong,
                    borderStrokeWidth: zone.key == selectedZone?.key ? 3 : 1.5,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (final zone in zones)
                  Marker(
                    point: zone.center,
                    width: 170,
                    height: 40,
                    child: _ZoneLabel(
                      zone: zone,
                      selected: zone.key == selectedZone?.key,
                      onTap: () => _selectZone(zone),
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text(osmAttribution),
              backgroundColor: Color(0xCCFBF9F5),
            ),
          ],
        ),
        Positioned(
          top: AppSpacing.m,
          left: 0,
          right: 0,
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                  ),
                  children: [
                    for (final type in ListingTypeUi.values) ...[
                      _TypeChip(
                        type: type,
                        selected: _type == type,
                        onTap: () => _setType(type),
                      ),
                      const SizedBox(width: AppSpacing.s),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              _StatusPill(
                loading: _loading,
                text: _tooFar
                    ? 'Acerca el mapa para ver publicaciones'
                    : _error ?? areaCountLabel(_listings.length),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSpacing.l,
          bottom: selectedZone != null && !wide ? 170 : AppSpacing.xxl,
          child: FloatingActionButton.small(
            heroTag: 'map_locate',
            tooltip: 'Mi ubicación',
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            onPressed: _locate,
            child: const Icon(Icons.my_location),
          ),
        ),
        if (selectedZone != null && !wide)
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.l,
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final many = selectedZone.listings.length > 1;
                  final cardWidth = many
                      ? constraints.maxWidth * 0.82
                      : constraints.maxWidth - AppSpacing.l * 2;
                  return SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                      ),
                      itemCount: selectedZone.listings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.m),
                      itemBuilder: (context, index) {
                        final view = selectedZone.listings[index];
                        return SizedBox(
                          width: cardWidth,
                          child: Material(
                            color: Colors.transparent,
                            elevation: 6,
                            shadowColor: const Color(0x331E3A2F),
                            borderRadius: BorderRadius.circular(16),
                            child: ListingCard.fromView(
                              view,
                              onTap: () => _openDetail(view),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSideList() {
    if (_tooFar) {
      return const EmptyState(
        icon: Icons.zoom_in_map,
        title: 'Acerca el mapa',
        message: 'Así te mostramos lo que hay cerca.',
      );
    }
    if (_listings.isEmpty) {
      return EmptyState(
        icon: Icons.map_outlined,
        title: _loading ? 'Buscando…' : 'Nada en esta zona',
        message: 'Mueve el mapa para explorar otros barrios.',
      );
    }
    final zone = _currentZone;
    final listings = zone?.listings ?? _listings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (zone != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.s,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Zona ${zone.neighborhood}',
                    style: AppTypography.bodyStrong,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _zone = null),
                  child: const Text('Ver todo'),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: listings.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.m),
            itemBuilder: (context, index) {
              final view = listings[index];
              return ListingCard.fromView(
                view,
                onTap: () => _openDetail(view),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel({
    required this.zone,
    required this.selected,
    required this.onTap,
  });

  final MapZone zone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = zone.listings.length;
    final background = selected ? AppColors.primary : AppColors.surface;
    final foreground = selected ? AppColors.onPrimary : AppColors.textPrimary;

    return Center(
      child: Semantics(
        button: true,
        label: '${zone.neighborhood}: $count publicaciones',
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.accentStrong),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x401E3A2F),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      zone.neighborhood,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: AppTypography.badge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ListingTypeUi type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      elevation: 2,
      shadowColor: const Color(0x261E3A2F),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Center(
            child: Text(
              type.label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.loading, required this.text});

  final bool loading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) ...[
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
          ],
          Text(
            text,
            style: AppTypography.caption.copyWith(color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }
}
