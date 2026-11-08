import 'package:dale_otra_vida_client/dale_otra_vida_client.dart';
import 'package:latlong2/latlong.dart';

/// Medellín downtown, used when the member's location is unknown.
const medellin = LatLng(6.2442, -75.5812);

/// The server only searches areas up to 2° on each side.
const maxAreaSpan = 2.0;

bool isAreaTooLarge({
  required double south,
  required double west,
  required double north,
  required double east,
}) {
  return north - south > maxAreaSpan || east - west > maxAreaSpan;
}

/// "3 publicaciones en esta zona", "1 publicación…", "Nada en esta zona".
String areaCountLabel(int count) {
  if (count == 0) return 'Nada publicado en esta zona';
  if (count == 1) return '1 publicación en esta zona';
  return '$count publicaciones en esta zona';
}

/// Side of a public zone in degrees (about 1.1 km), the same grid the server
/// uses: other members' listings arrive already moved to their zone centre.
const zoneSizeDegrees = 0.01;

/// Radius of the circle drawn for a zone: big enough to read as "around
/// here", never as an address.
const zoneRadiusMeters = 550.0;

/// Listings that share a ~1 km zone, shown as one circle on the map.
class MapZone {
  MapZone(this.key, this.center, this.listings);

  final String key;
  final LatLng center;
  final List<ListingView> listings;

  /// The neighborhood most of its listings mention.
  String get neighborhood {
    final counts = <String, int>{};
    for (final view in listings) {
      final name = view.listing.neighborhood.trim();
      if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + 1;
    }
    if (counts.isEmpty) return 'Esta zona';
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

int _cell(double value) => (value / zoneSizeDegrees).floor();

double _cellCenter(int cell) => (cell + 0.5) * zoneSizeDegrees;

/// The zone a point falls in, also for the member's own listings, which keep
/// their real location.
({String key, LatLng center}) zoneOf(double latitude, double longitude) {
  final lat = _cell(latitude);
  final lng = _cell(longitude);
  return (key: '$lat:$lng', center: LatLng(_cellCenter(lat), _cellCenter(lng)));
}

/// Groups listings into zones, keeping the listing order inside each one.
List<MapZone> groupIntoZones(List<ListingView> listings) {
  final zones = <String, MapZone>{};
  for (final view in listings) {
    final zone = zoneOf(view.listing.latitude, view.listing.longitude);
    zones
        .putIfAbsent(zone.key, () => MapZone(zone.key, zone.center, []))
        .listings
        .add(view);
  }
  return zones.values.toList();
}
