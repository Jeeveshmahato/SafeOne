import 'dart:io' show Platform;

import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sends the emergency text message to the contacts.
///
/// IMPORTANT difference between phones:
/// - On ANDROID we can send the SMS automatically in the background.
/// - On iPHONE Apple does NOT allow this, so we instead open the Messages app
///   with the text pre-filled, and the user taps "send" themselves.
class SmsService {
  final Telephony _telephony = Telephony.instance;

  /// Make sure we are allowed to send SMS (Android only). Returns true if OK.
  Future<bool> ensureSmsPermission() async {
    if (!Platform.isAndroid) {
      // iOS doesn't use this permission; it opens the Messages app instead.
      return true;
    }
    final PermissionStatus status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Send [message] to every number in [phoneNumbers].
  ///
  /// On Android each one is sent automatically. On iOS we can only open the
  /// Messages app once (with the first contact) for the user to send manually.
  Future<void> sendSos({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    if (phoneNumbers.isEmpty) return;

    if (Platform.isAndroid) {
      // Send silently to each contact, one by one.
      for (final number in phoneNumbers) {
        await _telephony.sendSms(to: number, message: message);
      }
    } else {
      // iOS / others: open the Messages app with the text ready to send.
      final String recipients = phoneNumbers.join(',');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipients,
        queryParameters: {'body': message},
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }
}
