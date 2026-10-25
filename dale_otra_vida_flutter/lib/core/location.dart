import 'dart:async';

import 'package:geolocator/geolocator.dart';

({double lat, double lng})? _cachedLocation;
DateTime? _cachedAt;

Future<({double lat, double lng})?> currentApproxLocation() async {
  final cached = _cachedLocation;
  final cachedAt = _cachedAt;
  if (cached != null &&
      cachedAt != null &&
      DateTime.now().difference(cachedAt) < const Duration(minutes: 5)) {
    return cached;
  }

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    ).timeout(const Duration(seconds: 8));

    _cachedLocation = (lat: position.latitude, lng: position.longitude);
    _cachedAt = DateTime.now();
    return _cachedLocation;
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  }
}
