import 'package:url_launcher/url_launcher.dart';

import 'location_service.dart';

/// Opens Google Maps showing a certain kind of place (police, hospital, …)
/// near the user's current location.
///
/// This is completely FREE and needs no API key: it just opens the public
/// Google Maps "search" web link, which every Android phone can handle. If we
/// can get the GPS position we centre the search on the user; if not, we fall
/// back to a plain "near me" search that Maps resolves on its own.
class NearbyPlacesService {
  final LocationService _locationService = LocationService();

  /// Opens Google Maps searching for [query] (e.g. "police station") around
  /// the user. Throws an Exception with a friendly message if Maps can't be
  /// opened at all.
  Future<void> openNearby(String query) async {
    Uri uri;

    try {
      // Try to centre the search on the user's real position.
      final position = await _locationService.getCurrentLocation();
      // The /@lat,lng,15z part tells Maps where to look and how far to zoom.
      uri = Uri.parse(
        'https://www.google.com/maps/search/'
        '${Uri.encodeComponent(query)}/'
        '@${position.latitude},${position.longitude},15z',
      );
    } catch (_) {
      // No GPS / permission denied: let Maps figure out "near me" by itself.
      uri = Uri.parse(
        'https://www.google.com/maps/search/'
        '${Uri.encodeComponent('$query near me')}',
      );
    }

    final bool opened =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      throw Exception('Could not open Google Maps on this phone.');
    }
  }
}
