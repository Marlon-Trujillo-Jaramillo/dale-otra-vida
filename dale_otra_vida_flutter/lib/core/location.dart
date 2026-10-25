import 'dart:async';

import 'package:geolocator/geolocator.dart';

({double lat, double lng})? _cachedLocation;
DateTime? _cachedAt;
Future<({double lat, double lng})?>? _inFlight;

Future<({double lat, double lng})?> currentApproxLocation() async {
  try {
    final cached = _cachedLocation;
    final cachedAt = _cachedAt;
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < const Duration(minutes: 5)) {
      return cached;
    }

    final inFlight = _inFlight;
    if (inFlight != null) return await inFlight;

    _inFlight = _fetch();
    try {
      return await _inFlight!;
    } finally {
      _inFlight = null;
    }
  } catch (_) {
    return null;
  }
}

Future<({double lat, double lng})?> _fetch() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );

    _cachedLocation = (lat: position.latitude, lng: position.longitude);
    _cachedAt = DateTime.now();
    return _cachedLocation;
  } catch (_) {
    return null;
  }
}
