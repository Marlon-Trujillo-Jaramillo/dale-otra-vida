import 'dart:async';

import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../client.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/location.dart';
import '../../core/models/category_ui.dart';
import '../../core/models/listing_type_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../listing/listing_detail_screen.dart';
import 'map_logic.dart';
import 'tiles.dart';

/// Listings around the member on a map. Markers sit on each listing's
/// rounded (~100 m) location, never an exact address.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  ({double lat, double lng})? _location;
  List<ListingView> _listings = [];
  ListingView? _selected;
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
        _selected = null;
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
        if (_selected != null &&
            !listings.any((l) => l.listing.id == _selected!.listing.id)) {
          _selected = null;
        }
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

  void _select(ListingView view) {
    setState(() => _selected = view);
    _mapController.move(
      LatLng(view.listing.latitude, view.listing.longitude),
      _mapController.camera.zoom,
    );
  }

  Future<void> _openDetail(ListingView view) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ListingDetailScreen(view: view),
      ),
    );
    _load();
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
            onTap: (_, _) => setState(() => _selected = null),
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
            MarkerLayer(
              markers: [
                for (final view in _listings)
                  Marker(
                    point: LatLng(
                      view.listing.latitude,
                      view.listing.longitude,
                    ),
                    width: 44,
                    height: 52,
                    alignment: Alignment.topCenter,
                    child: _ListingPin(
                      view: view,
                      selected: _selected?.listing.id == view.listing.id,
                      onTap: () => _select(view),
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
          bottom: _selected != null && !wide ? 150 : AppSpacing.xxl,
          child: FloatingActionButton.small(
            heroTag: 'map_locate',
            tooltip: 'Mi ubicación',
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            onPressed: _locate,
            child: const Icon(Icons.my_location),
          ),
        ),
        if (_selected != null && !wide)
          Positioned(
            left: AppSpacing.l,
            right: AppSpacing.l,
            bottom: AppSpacing.l,
            child: SafeArea(
              top: false,
              child: Material(
                color: Colors.transparent,
                elevation: 6,
                shadowColor: const Color(0x331E3A2F),
                borderRadius: BorderRadius.circular(16),
                child: ListingCard.fromView(
                  _selected!,
                  onTap: () => _openDetail(_selected!),
                ),
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
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: _listings.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final view = _listings[index];
        final selected = _selected?.listing.id == view.listing.id;
        return MouseRegion(
          onEnter: (_) => setState(() => _selected = view),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListingCard.fromView(
              view,
              onTap: () => _openDetail(view),
            ),
          ),
        );
      },
    );
  }
}

class _ListingPin extends StatelessWidget {
  const _ListingPin({
    required this.view,
    required this.selected,
    required this.onTap,
  });

  final ListingView view;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = ListingTypeUi.fromServer(view.listing.type);
    final category = CategoryUi.fromServer(view.listing.category);
    final background = selected ? AppColors.primary : type.badgeBackground;
    final foreground = selected ? AppColors.onPrimary : type.badgeText;

    return Semantics(
      button: true,
      label: view.listing.title,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: selected ? 1.15 : 1,
            duration: const Duration(milliseconds: 160),
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x401E3A2F),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(category.icon, size: 20, color: foreground),
                ),
                CustomPaint(
                  size: const Size(12, 8),
                  painter: _PinTailPainter(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PinTailPainter oldDelegate) => oldDelegate.color != color;
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
