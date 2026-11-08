import 'dart:math' as math;

/// Rounds a coordinate to ~100 m (three decimal places).
double? roundCoordinate(double? value) =>
    value == null ? null : (value * 1000).roundToDouble() / 1000;

/// Side of a public zone in degrees: about 1.1 km in Medellín.
const zoneSizeDegrees = 0.01;

/// Centre of the ~1 km zone that contains [value]. Other members see this
/// instead of the listing's location, so a pin points at the neighborhood,
/// never at a house.
double zoneCenter(double value) {
  final center =
      ((value / zoneSizeDegrees).floorToDouble() + 0.5) * zoneSizeDegrees;
  return (center * 10000).roundToDouble() / 10000;
}

/// Half-kilometre steps (at least 0.5 km), so distances can't be combined
/// to pinpoint a listing.
double roundDistanceKm(double km) =>
    math.max(0.5, (km * 2).roundToDouble() / 2);

/// Returns true when both values are finite and inside the valid ranges.
bool isValidCoordinate(double lat, double lng) =>
    lat.isFinite &&
    lng.isFinite &&
    lat >= -90 &&
    lat <= 90 &&
    lng >= -180 &&
    lng <= 180;

/// Calculates the great-circle distance between two points on Earth.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  final clampedA = a.clamp(0.0, 1.0);
  final c = 2 * math.atan2(math.sqrt(clampedA), math.sqrt(1 - clampedA));

  return earthRadiusKm * c;
}

double _toRadians(double degrees) => degrees * math.pi / 180.0;
