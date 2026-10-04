import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// What happened when an SOS SMS was sent.
class SmsOutcome {
  const SmsOutcome({
    required this.sentAutomatically,
    required this.composerOpened,
    this.failed = const [],
  });

  /// Numbers the phone confirmed it sent, with no tap needed.
  final List<String> sentAutomatically;

  /// True if the Messages app was opened (for the user to tap Send) — either
  /// because SMS permission isn't granted, or for numbers that failed.
  final bool composerOpened;

  /// Numbers that couldn't be sent automatically.
  final List<String> failed;

  /// True if the alert went out or is ready to send in Messages.
  bool get delivered => sentAutomatically.isNotEmpty || composerOpened;
}

/// Sends the emergency SMS.
///
/// With the SEND_SMS permission (Google Play's "Physical safety / emergency
/// alerts" exception), each contact gets their own SMS straight from the
/// phone — no tap needed, no group MMS, nothing revealed between contacts.
/// Without it, or for any number that fails, it opens the Messages app with
/// the text pre-filled so the user can send it with one tap.
class SmsService {
  static const MethodChannel _channel = MethodChannel('com.safeone.app/sms');

  /// Whether SOS messages can be sent automatically right now.
  static Future<bool> canSendAutomatically() async {
    try {
      return await _channel.invokeMethod<bool>('canSend') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Asks for SMS permission (call it ahead of time, never mid-emergency).
  static Future<PermissionStatus> requestPermission() =>
      Permission.sms.request();

  static Future<PermissionStatus> permissionStatus() => Permission.sms.status;

  /// Kept for API compatibility with callers: sending never blocks on a
  /// permission prompt (it falls back to Messages instead).
  Future<bool> ensureSmsPermission() async => true;

  /// Sends [message] to every number in [phoneNumbers].
  Future<SmsOutcome> sendSos({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    if (phoneNumbers.isEmpty) {
      return const SmsOutcome(sentAutomatically: [], composerOpened: false);
    }

    var sent = <String>[];
    var failed = List<String>.of(phoneNumbers);
    if (await canSendAutomatically()) {
      try {
        final result = await _channel.invokeMapMethod<String, dynamic>(
          'send',
          {'numbers': phoneNumbers, 'message': message},
        );
        sent = List<String>.from(result?['sent'] as List? ?? const []);
        failed = List<String>.from(result?['failed'] as List? ?? const []);
      } on PlatformException {
        // Fall through to the Messages app for everyone.
      }
    }

    final composerOpened =
        failed.isNotEmpty && await _openComposer(failed, message);
    return SmsOutcome(
      sentAutomatically: sent,
      composerOpened: composerOpened,
      failed: failed,
    );
  }

  /// Opens the Messages app pre-filled, addressed to [numbers].
  Future<bool> _openComposer(List<String> numbers, String message) async {
    // Most Android/iOS SMS apps accept comma-separated recipients.
    final smsUri = Uri(
      scheme: 'sms',
      path: numbers.join(','),
      queryParameters: {'body': message},
    );
    // Launch directly: `canLaunchUrl` can wrongly report false on some
    // Android 11+ devices, which would silently drop the alert.
    try {
      return await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
