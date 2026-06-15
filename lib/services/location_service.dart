import 'package:geolocator/geolocator.dart';

/// Gets the phone's current GPS location.
///
/// It also handles asking the user for location permission. If permission is
/// denied or GPS is off, it throws a clear error message that the app can show.
class LocationService {
  /// Returns the current position, or throws an Exception with a friendly
  /// message explaining what went wrong (so the UI can show it).
  Future<Position> getCurrentLocation() async {
    // 1. Is the phone's location (GPS) switched on at all?
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location is turned off. Please turn on GPS.');
    }

    // 2. Has the user given this app permission to use location?
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Ask for it.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Please enable it in the phone Settings.',
      );
    }

    // 3. Permission granted and GPS on -> get the actual position.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Builds a Google Maps link for a location, e.g.
  /// https://maps.google.com/?q=12.34,56.78
  /// Anyone who receives this can tap it to see the spot on a map.
  String buildMapsLink(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }
}
