import 'package:url_launcher/url_launcher.dart';

/// Opens the phone's Messages app with the emergency text pre-filled so the
/// user can send it with one tap.
///
/// NOTE: this app intentionally does NOT use the restricted `SEND_SMS`
/// permission (Google Play limits it to default SMS handler apps). Instead we
/// launch the system SMS composer via an `sms:` intent on every platform. The
/// trade-off is that the user taps "send" themselves — silent/background
/// auto-sending is not possible without `SEND_SMS`.
class SmsService {
  /// Kept for API compatibility with callers. No runtime SMS permission is
  /// needed when sending via the system composer, so this is always true.
  Future<bool> ensureSmsPermission() async => true;

  /// Open the Messages app with [message] pre-filled, addressed to every number
  /// in [phoneNumbers]. Returns whether the Messages app was opened, so the
  /// caller never reports an alert as sent when it wasn't.
  Future<bool> sendSos({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    if (phoneNumbers.isEmpty) return false;

    // Most Android/iOS dialers accept comma-separated recipients in the path.
    final String recipients = phoneNumbers.join(',');
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: recipients,
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
