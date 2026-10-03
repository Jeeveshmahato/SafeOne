import 'package:vibration/vibration.dart';

import '../models/emergency_contact.dart';
import 'location_service.dart';
import 'sms_service.dart';

/// The result of trying to send an SOS, so the screen can tell the user
/// exactly what happened (success message or a clear error).
class SosResult {
  final bool success;
  final String message;

  const SosResult({required this.success, required this.message});
}

/// The "brain" of the SOS feature. It runs all the steps in order:
///   1. Check there are contacts to alert.
///   2. Get the current location.
///   3. Build the alert message (with a map link).
///   4. Send the SMS to every contact.
///   5. Vibrate the phone so the user knows it worked.
///
/// It depends on the smaller services, which keeps each piece simple and easy
/// to test or change later.
class SosService {
  final LocationService _locationService;
  final SmsService _smsService;

  SosService({
    LocationService? locationService,
    SmsService? smsService,
  })  : _locationService = locationService ?? LocationService(),
        _smsService = smsService ?? SmsService();

  /// Send the EMERGENCY alert. [messageTemplate] is the text to send. If it
  /// contains the word "{location}", that is replaced with a live Google Maps
  /// link. If not, the link is added on the end so contacts always get it.
  Future<SosResult> sendSos(
    List<EmergencyContact> contacts, {
    required String messageTemplate,
    bool silent = false,
  }) {
    return _sendToContacts(
      contacts: contacts,
      messageTemplate: messageTemplate,
      successPrefix: 'Alert sent to',
      silent: silent,
    );
  }

  /// Send a reassuring "I have reached safely" message with the current
  /// location to all contacts. Reuses the same location + SMS steps as the SOS.
  Future<SosResult> sendCheckIn(List<EmergencyContact> contacts) {
    return _sendToContacts(
      contacts: contacts,
      messageTemplate: 'I have reached safely. My location: {location}',
      successPrefix: 'Check-in sent to',
    );
  }

  /// Send a "I'm on the move, here is where I am right now" update. This is
  /// used by the Follow Me feature, which calls it on a timer so contacts can
  /// watch the journey. Same location + SMS steps as the SOS.
  Future<SosResult> sendFollowMe(
    List<EmergencyContact> contacts, {
    String? note,
  }) {
    final prefix = (note == null || note.isEmpty) ? '' : '$note ';
    return _sendToContacts(
      contacts: contacts,
      messageTemplate: '${prefix}Following my journey. Live location: {location}',
      successPrefix: 'Location update sent to',
      silent: true,
    );
  }

  /// The shared logic behind both [sendSos] and [sendCheckIn]: get location,
  /// build the message, send the SMS, and buzz the phone. Keeping it in one
  /// place means there is only one set of steps to maintain and test.
  Future<SosResult> _sendToContacts({
    required List<EmergencyContact> contacts,
    required String messageTemplate,
    required String successPrefix,
    bool silent = false,
  }) async {
    // Step 1: make sure there is someone to alert.
    if (contacts.isEmpty) {
      return const SosResult(
        success: false,
        message: 'Please add at least one emergency contact first.',
      );
    }

    // Step 2: make sure we are allowed to send SMS (Android).
    final bool canSms = await _smsService.ensureSmsPermission();
    if (!canSms) {
      return const SosResult(
        success: false,
        message: 'SMS permission was denied. Cannot send the message.',
      );
    }

    try {
      // Step 3: get the location — best effort. An alert without a location
      // is far better than no alert, so a GPS failure never stops the SOS.
      final position = await _locationService.getBestEffortLocation();
      final String locationText = position == null
          ? '(location unavailable)'
          : _locationService.buildMapsLink(
              position.latitude,
              position.longitude,
            );

      // Step 4: build the message from the template.
      const String placeholder = '{location}';
      final String message = messageTemplate.contains(placeholder)
          ? messageTemplate.replaceAll(placeholder, locationText)
          : '$messageTemplate $locationText';

      // Step 5: open Messages addressed to everyone.
      final phoneNumbers = contacts.map((c) => c.phone).toList();
      final opened = await _smsService.sendSos(
        phoneNumbers: phoneNumbers,
        message: message,
      );
      if (!opened) {
        return const SosResult(
          success: false,
          message: "Couldn't open your Messages app. Call 112 or text your "
              'contacts directly.',
        );
      }

      // Step 6: buzz the phone to confirm (only if it can vibrate). Skipped
      // for a silent/stealth SOS so an attacker doesn't notice it was sent.
      if (!silent && await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 800);
      }

      return SosResult(
        success: true,
        message: position == null
            ? '$successPrefix ${contacts.length} contact(s), without location '
                '(turn on GPS for a map link).'
            : '$successPrefix ${contacts.length} contact(s).',
      );
    } catch (error) {
      // Any failure (location off, permission denied, etc.) ends up here with
      // a readable message we can show the user.
      return SosResult(
        success: false,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
