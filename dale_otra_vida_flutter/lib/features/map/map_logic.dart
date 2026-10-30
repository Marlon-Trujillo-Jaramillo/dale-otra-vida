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
