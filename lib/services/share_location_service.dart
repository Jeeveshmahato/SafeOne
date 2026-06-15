import 'package:share_plus/share_plus.dart';

import 'location_service.dart';

/// Shares the user's current location to ANY app (WhatsApp, Messages, email…)
/// using the phone's normal share sheet. This is for non-emergency sharing,
/// e.g. telling a friend where you are.
class ShareLocationService {
  final LocationService _locationService;

  ShareLocationService({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  /// Get the current location and open the share sheet with a map link.
  /// Throws a readable Exception if the location can't be obtained.
  Future<void> shareCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    final link = _locationService.buildMapsLink(
      position.latitude,
      position.longitude,
    );
    await SharePlus.instance.share(
      ShareParams(text: 'My current location: $link'),
    );
  }
}
