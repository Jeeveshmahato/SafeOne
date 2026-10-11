import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// The running check-in, as the native side saved it, or null if none is
  /// running. Lets the timer screen pick up where it was after the app was
  /// closed.
  static Future<CheckinStatus?> checkinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // The alarm receiver ends the check-in in the background.
    await prefs.reload();
    final deadline = prefs.getInt('checkin_deadline_ms') ?? 0;
    if (!(prefs.getBool('checkin_active') ?? false) || deadline <= 0) {
      return null;
    }
    final started = prefs.getInt('checkin_started_ms') ?? 0;
    final end = DateTime.fromMillisecondsSinceEpoch(deadline);
    return CheckinStatus(
      // Check-ins started before the start time was saved: count from now.
      startedAt: started > 0
          ? DateTime.fromMillisecondsSinceEpoch(started)
          : DateTime.now(),
      deadline: end,
    );
  }

  /// Start sharing the location with contacts every [interval] (at least a
  /// minute) until [stopLiveShare]. Runs in the native foreground service, on
  /// alarms, so it carries on with the app closed or the phone asleep.
  ///
  /// [mode] sets the wording: [LiveShareMode.sos] after an SOS (the first
  /// update follows after [interval]), [LiveShareMode.followMe] and
  /// [LiveShareMode.journey] (both text straight away). A journey also needs
  /// [destination] and [deadline]: contacts are alerted if the user hasn't
  /// tapped "I arrived" by then. Starting replaces any running session.
  static Future<bool> startLiveShare({
    Duration interval = const Duration(minutes: 2),
    LiveShareMode mode = LiveShareMode.sos,
    String? destination,
    DateTime? deadline,
  }) async {
    try {
      await _channel.invokeMethod('startLiveShare', {
        'intervalMillis': interval.inMilliseconds,
        'mode': mode.key,
        'destination': destination,
        'deadlineMillis': deadline?.millisecondsSinceEpoch,
      });
      return true;
    } catch (_) {
      return false; // not on Android / channel missing
    }
  }

  /// What's being shared right now, as the service last saved it.
  static Future<LiveShareStatus> liveShareStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // The service changes these in the background.
    await prefs.reload();
    final active = prefs.getBool('live_sharing_active') ?? false;
    DateTime? time(String key) {
      final ms = prefs.getInt(key);
      return ms == null || ms == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(ms);
    }

    return LiveShareStatus(
      active: active,
      mode: !active
          ? null
          : LiveShareMode.values.firstWhere(
              (m) => m.key == prefs.getString('live_share_mode'),
              orElse: () => LiveShareMode.sos,
            ),
      updatesSent: prefs.getInt('live_share_count') ?? 0,
      lastSentAt: time('live_share_last_sent_ms'),
      startedAt: time('live_share_started_ms'),
      destination: prefs.getString('journey_destination'),
      deadline: time('journey_deadline_ms'),
      overdue: prefs.getBool('journey_overdue') ?? false,
    );
  }

  static Future<void> stopLiveShare() async {
    try {
      await _channel.invokeMethod('stopLiveShare');
    } catch (_) {/* not on Android / channel missing */}
  }
}

/// What started the live sharing; it decides how the texts are worded.
enum LiveShareMode {
  sos('sos'),
  followMe('follow_me'),
  journey('journey');

  const LiveShareMode(this.key);

  /// The value the native service stores.
  final String key;
}

class LiveShareStatus {
  final bool active;
  final LiveShareMode? mode;
  final int updatesSent;
  final DateTime? lastSentAt;
  final DateTime? startedAt;
  final String? destination;
  final DateTime? deadline;

  /// A journey whose arrival time passed: contacts were alerted.
  final bool overdue;

  const LiveShareStatus({
    required this.active,
    required this.mode,
    required this.updatesSent,
    required this.lastSentAt,
    required this.startedAt,
    required this.destination,
    required this.deadline,
    required this.overdue,
  });
}

/// A running safety check-in.
class CheckinStatus {
  final DateTime startedAt;
  final DateTime deadline;

  const CheckinStatus({required this.startedAt, required this.deadline});
}
