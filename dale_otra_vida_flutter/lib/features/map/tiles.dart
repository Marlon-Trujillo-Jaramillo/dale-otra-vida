import 'package:flutter_map/flutter_map.dart';

/// Standard OpenStreetMap tiles. The usage policy asks for a real user agent
/// and visible attribution ([osmAttribution]).
TileLayer osmTileLayer() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'co.daleotravida.app',
  maxNativeZoom: 19,
);

const osmAttribution = 'OpenStreetMap contributors';
