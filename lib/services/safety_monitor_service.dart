import 'package:flutter/services.dart';

/// Controls the native always-on foreground service (SafetyMonitorService.kt)
/// that keeps the hands-free SOS triggers — shake, volume, power — working when
/// the screen is locked or the app is in the background.
///
/// Which triggers are active is read by the native side from the SAME
/// SharedPreferences the app writes (shake_enabled / volume_trigger /
/// power_trigger), so toggling a trigger off takes effect immediately without
/// restarting the service. We only need to start the service when at least one
/// trigger is on, and stop it when none are.
class SafetyMonitorService {
  static const _channel = MethodChannel('women_safety/safety_monitor');

  /// Start the foreground service (shows the persistent "Safety mode active"
  /// notification). Safe to call repeatedly.
  static Future<void> start() async {
    try {
      await _channel.invokeMethod('start');
    } catch (_) {/* not on Android / channel missing */}
  }

  /// Stop the foreground service and dismiss its notification.
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {/* not on Android / channel missing */}
  }

  /// Start if any background trigger is enabled, otherwise stop.
  static Future<void> sync({
    required bool shake,
    required bool volume,
    required bool power,
  }) {
    return (shake || volume || power) ? start() : stop();
  }

  /// Schedule the safety check-in deadline natively. If the user doesn't call
  /// [cancelCheckin] (tap "I'm safe") before [deadline], the native receiver
  /// sends the SOS — works even if the app is closed or the phone is locked,
  /// unlike the old android_alarm_manager background-isolate approach which OEMs
  /// block once the app is swiped away.
  static Future<void> scheduleCheckin(DateTime deadline) async {
    try {
      await _channel.invokeMethod('scheduleCheckin', {
        'epochMillis': deadline.millisecondsSinceEpoch,
      });
    } catch (_) {/* not on Android / channel missing */}
  }

  static Future<void> cancelCheckin() async {
    try {
      await _channel.invokeMethod('cancelCheckin');
    } catch (_) {/* not on Android / channel missing */}
  }

  /// Start live-location ("Follow Me") sharing: the native foreground service
  /// sends the location to contacts every [interval] until [stopLiveShare].
  /// Runs in the foreground service so it survives the app being swiped away —
  /// unlike the old android_alarm_manager background isolate which OEMs killed.
  static Future<void> startLiveShare({
    Duration interval = const Duration(minutes: 2),
  }) async {
    try {
      await _channel.invokeMethod('startLiveShare', {
        'intervalMillis': interval.inMilliseconds,
      });
    } catch (_) {/* not on Android / channel missing */}
  }

  static Future<void> stopLiveShare() async {
    try {
      await _channel.invokeMethod('stopLiveShare');
    } catch (_) {/* not on Android / channel missing */}
  }
}
