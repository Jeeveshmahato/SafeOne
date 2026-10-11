import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../models/emergency_contact.dart';
import 'location_service.dart';
import 'settings_repository.dart';
import 'sms_service.dart';

/// The result of trying to send an SOS, so the screen can tell the user
/// exactly what happened (success message or a clear error).
class SosResult {
  final bool success;
  final String message;

  const SosResult({required this.success, required this.message});
}

/// The location part of an alert: the maps link, noting its age when it's an
/// old "last known" fix (no fresh fix arrived in time), so contacts don't go
/// to where the person was hours ago thinking it's live. Null when there's no
/// location: the caller words that case. Matches SosLocation.describe
/// (Android), and like it sticks to plain SMS characters.
String? describeLocation(String? mapsLink, DateTime? fixTime, {DateTime? now}) {
  if (mapsLink == null) return null;
  if (fixTime == null) return mapsLink;
  final age = (now ?? DateTime.now()).difference(fixTime);
  if (age < const Duration(minutes: 5)) return mapsLink;
  final ago = age.inMinutes < 120
      ? '${age.inMinutes} min ago'
      : '${age.inHours} hours ago';
  return '$mapsLink (from $ago)';
}

/// "your contact" / "all 3 contacts", for result messages.
String contactsPhrase(int count) =>
    count == 1 ? 'your contact' : 'all $count contacts';

/// The location of the latest SOS, handed to the background service so its
/// follow-up updates (and a shutdown alert) can say where the person last was
/// if the phone can't get a new fix. Kept only while sharing is on: the
/// service deletes it when the user taps "I'm safe".
class LastFix {
  static const _key = 'last_fix';

  static Future<void> save(Position p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key,
        '${p.latitude},${p.longitude},${p.timestamp.millisecondsSinceEpoch},${p.accuracy}');
  }

  static Future<void> forget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
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
    String? messageWithoutLocation,
    bool silent = false,
  }) {
    return _sendToContacts(
      contacts: contacts,
      messageTemplate: messageTemplate,
      messageWithoutLocation: messageWithoutLocation ??
          (messageTemplate == SettingsRepository.defaultSosMessage
              ? SettingsRepository.defaultSosMessageNoLocation
              : null),
      sentLabel: 'SOS sent',
      silent: silent,
      rememberFix: true,
    );
  }

  /// Tell contacts the person is safe, with where they are. [arrived] words
  /// it for the end of a journey; otherwise it's the "I'm safe" after an SOS
  /// or check-in.
  Future<SosResult> sendCheckIn(
    List<EmergencyContact> contacts, {
    String? arrivedAt,
  }) {
    final safe = arrivedAt == null
        ? "I'm safe now, no need to worry."
        : "I've reached $arrivedAt safely, no need to worry.";
    return _sendToContacts(
      contacts: contacts,
      messageTemplate: '$safe I\'m here: {location}',
      messageWithoutLocation: safe,
      sentLabel: 'Sent',
      locationMatters: false,
    );
  }

  /// The shared logic behind both [sendSos] and [sendCheckIn]: get location,
  /// build the message, send the SMS, and buzz the phone. Keeping it in one
  /// place means there is only one set of steps to maintain and test.
  ///
  /// [messageWithoutLocation] is sent instead when there's no location at
  /// all; without one, the template gets a short note in place of the link.
  /// [locationMatters] says whether to nudge the user to turn location on.
  Future<SosResult> _sendToContacts({
    required List<EmergencyContact> contacts,
    required String messageTemplate,
    required String sentLabel,
    String? messageWithoutLocation,
    bool locationMatters = true,
    bool silent = false,
    bool rememberFix = false,
  }) async {
    // Step 1: make sure there is someone to alert.
    if (contacts.isEmpty) {
      return const SosResult(
        success: false,
        message: 'Add at least one emergency contact first.',
      );
    }

    // Step 2: make sure we are allowed to send SMS (Android).
    final bool canSms = await _smsService.ensureSmsPermission();
    if (!canSms) {
      return const SosResult(
        success: false,
        message: "SafeOne isn't allowed to send texts, so nothing was sent. "
            'Allow SMS for SafeOne in your phone settings.',
      );
    }

    try {
      // Step 3: get the location — best effort. An alert without a location
      // is far better than no alert, so a GPS failure never stops the SOS.
      final position = await _locationService.getBestEffortLocation();
      if (rememberFix && position != null) await LastFix.save(position);
      final String? locationText = describeLocation(
        position == null
            ? null
            : _locationService.buildMapsLink(
                position.latitude,
                position.longitude,
              ),
        position?.timestamp,
      );

      // Step 4: build the message from the template.
      const String placeholder = '{location}';
      final String message;
      if (locationText == null && messageWithoutLocation != null) {
        message = messageWithoutLocation;
      } else {
        final where = locationText ?? "(my phone couldn't get my location)";
        message = messageTemplate.contains(placeholder)
            ? messageTemplate.replaceAll(placeholder, where)
            : '${messageTemplate.trimRight()} $where';
      }

      // Step 5: send it — automatically to each contact when SMS permission
      // is granted, otherwise (or for any failures) via the Messages app.
      final phoneNumbers = contacts.map((c) => c.phone).toList();
      final outcome = await _smsService.sendSos(
        phoneNumbers: phoneNumbers,
        message: message,
      );
      if (!outcome.delivered) {
        return const SosResult(
          success: false,
          message: "Couldn't send the text or open Messages. Call 112, or "
              'text your contacts yourself.',
        );
      }

      // Step 6: buzz the phone to confirm (only if it can vibrate). Skipped
      // for a silent/stealth SOS so an attacker doesn't notice it was sent.
      if (!silent && await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 800);
      }

      // Step 7: say exactly what happened — never claim a message went out
      // when the user still has to tap Send.
      final total = contacts.length;
      final sentCount = outcome.sentAutomatically.length;
      final noLocation = position == null && locationMatters
          ? " Your location wasn't included. Turn on location so it's added "
              'next time.'
          : '';
      var text = '';
      if (sentCount == total) {
        text = '$sentLabel to ${contactsPhrase(total)}.$noLocation';
      } else if (sentCount > 0) {
        text = '$sentLabel to $sentCount of $total contacts. Tap Send in '
            'Messages for the rest.$noLocation';
      } else {
        text = 'Your message is ready in Messages. Tap Send to reach '
            '${contactsPhrase(total)}.$noLocation';
      }
      // Say why a tap was needed, so it's fixed before the next emergency.
      if (outcome.autoSmsOff) {
        text += ' To skip this step next time, turn on "Send SOS '
            'automatically" in Settings.';
      }
      return SosResult(success: true, message: text);
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
