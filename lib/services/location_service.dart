import 'package:geolocator/geolocator.dart';

/// Gets the phone's current GPS location.
///
/// It also handles asking the user for location permission. If permission is
/// denied or GPS is off, it throws a clear error message that the app can show.
class LocationService {
  /// Makes sure the location can be used, asking for permission if needed.
  /// Returns a message to show the user if it can't, or null when it's ready.
  Future<String?> checkReady() async {
    // 1. Is the phone's location (GPS) switched on at all?
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location is off. Turn it on in quick settings and try again.';
    }

    // 2. Has the user given this app permission to use location?
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Ask for it.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "SafeOne can't see your location without permission.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "SafeOne isn't allowed to use your location. Turn it on in "
          'Settings > Apps > SafeOne > Permissions.';
    }
    return null;
  }

  /// Returns the current position, or throws an Exception with a friendly
  /// message explaining what went wrong (so the UI can show it).
  Future<Position> getCurrentLocation() async {
    final problem = await checkReady();
    if (problem != null) throw Exception(problem);

    // 3. Permission granted and GPS on -> get the actual position.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// For emergencies: returns the best position available without ever
  /// blocking the alert. Tries a fresh fix for up to [timeout] (a fresh
  /// high-accuracy fix can take a long time indoors), then falls back to the
  /// last known position, and finally returns null — so the caller can still
  /// send the SOS without a location instead of not sending it at all.
  Future<Position?> getBestEffortLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await getCurrentLocation().timeout(timeout);
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Builds a Google Maps link for a location, e.g.
  /// https://maps.google.com/?q=12.34,56.78
  /// Anyone who receives this can tap it to see the spot on a map.
  String buildMapsLink(double latitude, double longitude) {
    // 6 decimals is about 10 cm: plenty, and keeps the SMS short.
    return 'https://maps.google.com/?q='
        '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
  }
}
