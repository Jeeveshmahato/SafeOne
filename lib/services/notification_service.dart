import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../screens/fake_call_screen.dart';

/// Used so notifications (which arrive outside the widget tree) can still push
/// a screen. Wired into [MaterialApp.navigatorKey] in main.dart.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Handles all local notifications:
///  * the safety check-in reminder, and
///  * the **scheduled fake call** that rings even when the app is in the
///    background or fully closed.
///
/// The fake call uses an Android "full-screen intent" notification on a
/// high-importance call channel — the same mechanism real calling apps use to
/// show an incoming-call screen over the lock screen when the app isn't
/// running. Tapping it (or it auto-launching on a locked screen) opens the
/// existing [FakeCallScreen].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialised = false;

  static const _checkinChannelId = 'safety_checkin';
  // Channel id is bumped when its settings change (Android locks a channel's
  // config after first creation).
  // Old fake-call channel: it played the default *notification* sound, so a
  // scheduled call chimed once instead of ringing. Deleted on init.
  static const _legacyCallChannelId = 'fake_call_v3';
  static const _checkinId = 1001;
  static const _callId = 2001;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    if (_initialised) return;

    // Timezone database is required for zonedSchedule().
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {/* falls back to UTC */}

    const android = AndroidInitializationSettings('@drawable/ic_stat_safeone');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onResponse,
    );

    // Basic notification permission (Android 13+ / iOS). The heavier
    // background permissions are requested later, when the user actually
    // schedules a call (see [ensureCanRingWhenClosed]).
    await _android?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    try {
      await _android?.deleteNotificationChannel(_legacyCallChannelId);
    } catch (_) {/* already gone */}

    _initialised = true;
  }

  /// True only if Android will let us fire an EXACT alarm. When false, a
  /// scheduled call may be delayed a long time by Doze.
  Future<bool> exactAlarmsAllowed() async {
    return await _android?.canScheduleExactNotifications() ?? true;
  }

  /// True if notifications are enabled for the app.
  Future<bool> notificationsEnabled() async {
    await init();
    return await _android?.areNotificationsEnabled() ?? true;
  }

  /// Opens the system page to allow full-screen (incoming-call style) alerts.
  Future<void> requestFullScreenIntent() async {
    await init();
    try {
      await _android?.requestFullScreenIntentPermission();
    } catch (_) {/* not applicable */}
  }

  Future<void> requestExactAlarms() async {
    await init();
    try {
      await _android?.requestExactAlarmsPermission();
    } catch (_) {/* not applicable */}
  }

  /// If the app was launched by tapping the fake-call notification (cold
  /// start), open the call screen. Call this once after the first frame.
  Future<void> handleLaunch() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final response = details!.notificationResponse;
      _route(response?.payload, notificationId: response?.id);
    }
  }

  // ---------------------------------------------------------------------------
  // Safety check-in reminder
  // ---------------------------------------------------------------------------

  Future<void> showCheckinDue(String title, String body) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _checkinChannelId,
        'Safety check-in',
        channelDescription: 'Reminders for the safety check-in deadline.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(_checkinId, title, body, details);
  }

  Future<void> cancelCheckin() => _plugin.cancel(_checkinId);

  // ---------------------------------------------------------------------------
  // Scheduled fake call
  // ---------------------------------------------------------------------------

  /// Schedule the fake call to ring [delay] from now. Works even if the app is
  /// then closed or the phone is locked.
  /// Asks the user to exempt the app from battery optimization. Without this,
  /// aggressive OEMs (Motorola, Xiaomi, …) force-stop the app when it is
  /// swiped from recents, which cancels the scheduled alarm so the call never
  /// rings. Best-effort and silent if unavailable.
  Future<void> ensureCanRingWhenClosed() async {
    await init();
    // 1. Exact alarms — so it rings on time, not deferred by Doze.
    try {
      if (!await exactAlarmsAllowed()) {
        await _android?.requestExactAlarmsPermission();
      }
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (_) {/* not applicable */}
    // 2. Full-screen intent — so the call screen can wake a locked phone.
    try {
      await _android?.requestFullScreenIntentPermission();
    } catch (_) {/* not applicable */}
    // 3. Battery-optimization exemption — so swiping the app away doesn't
    //    force-stop it and cancel the alarm.
    try {
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (_) {/* not applicable */}
  }

  /// Builds the payload routed to [FakeCallScreen] when the notification is
  /// tapped or its full-screen intent auto-launches the app.
  String _callPayload({
    required String callerName,
    required String callerPhone,
    required int ringIndex,
    required bool shouldRepeat,
    int? autoEndSeconds,
    String? ringtoneUri,
  }) =>
      jsonEncode({
        'type': 'fake_call',
        'name': callerName,
        'phone': callerPhone,
        'ring': ringIndex,
        'repeat': shouldRepeat,
        'autoEnd': autoEndSeconds,
        'ringUri': ringtoneUri,
      });

  /// Android plays the system default ringtone for this URI.
  static const _defaultRingtoneUri = 'content://settings/system/ringtone';

  /// A short, stable id for a sound, used to give each ring sound its own
  /// notification channel (a channel's sound can't change once created).
  static String _soundKey(String value) {
    var hash = 0x811c9dc5; // FNV-1a, 32-bit
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }

  /// The full-screen "incoming call" notification. It rings with the chosen
  /// sound on the *ringtone* stream and keeps ringing (FLAG_INSISTENT) until
  /// answered or the 60 s timeout — like a real call, rather than playing a
  /// one-off notification chime.
  NotificationDetails _callDetails({
    required int ringIndex,
    String? ringtoneUri,
  }) {
    final siren = RingSound.values[ringIndex] == RingSound.policeSiren;
    final AndroidNotificationSound sound;
    final String channelId;
    final String channelName;
    if (siren) {
      sound = const RawResourceAndroidNotificationSound('police_siren');
      channelId = 'fake_call_siren_v1';
      channelName = 'Fake call (police siren)';
    } else {
      final uri = ringtoneUri ?? _defaultRingtoneUri;
      sound = UriAndroidNotificationSound(uri);
      channelId = 'fake_call_ring_${_soundKey(uri)}';
      channelName = 'Fake call (ringtone)';
    }
    const flagInsistent = 4; // Notification.FLAG_INSISTENT: loop the sound.
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Rings for a scheduled fake incoming call.',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        playSound: true,
        sound: sound,
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
        additionalFlags: Int32List.fromList(const [flagInsistent]),
        enableVibration: true,
        vibrationPattern:
            Int64List.fromList(const [0, 1000, 600, 1000, 600, 1000]),
        visibility: NotificationVisibility.public,
        // Keep ringing/visible until the user answers or declines.
        ongoing: true,
        autoCancel: false,
        timeoutAfter: 60000,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Schedule the fake incoming call to ring at [when] — even if the app is
  /// then closed/swiped-away or the phone is locked.
  ///
  /// CRITICAL: this uses [zonedSchedule] so Android's AlarmManager delivers the
  /// notification through the plugin's NATIVE broadcast receiver. No Flutter/
  /// Dart isolate needs to start at fire time. That is the whole point — routing
  /// this through a background isolate (android_alarm_manager_plus) failed on
  /// aggressive OEMs (Motorola/Xiaomi/…) that force-stop the app on swipe and
  /// then block the isolate from starting, so the call never rang.
  Future<void> scheduleFakeCall({
    required int id,
    required DateTime when,
    required String callerName,
    required String callerPhone,
    required int ringIndex,
    required bool shouldRepeat,
    int? autoEndSeconds,
    String? ringtoneUri,
  }) async {
    await init();
    // The OS rejects a time in the past; if it slipped (e.g. a slow prompt),
    // ring a moment from now instead of not at all.
    final earliest = DateTime.now().add(const Duration(seconds: 2));
    final at = when.isAfter(earliest) ? when : earliest;
    await _plugin.zonedSchedule(
      id,
      callerName,
      'Incoming call…',
      tz.TZDateTime.from(at, tz.local),
      _callDetails(ringIndex: ringIndex, ringtoneUri: ringtoneUri),
      // alarmClock = the most reliable exact mode; fires through Doze and
      // shows up in the system as a user-facing alarm the OS won't defer.
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: _callPayload(
        callerName: callerName,
        callerPhone: callerPhone,
        ringIndex: ringIndex,
        shouldRepeat: shouldRepeat,
        autoEndSeconds: autoEndSeconds,
        ringtoneUri: ringtoneUri,
      ),
    );
  }

  /// Post the incoming-call notification RIGHT NOW (full-screen, ringing).
  Future<void> showIncomingCall({
    required String callerName,
    required String callerPhone,
    required int ringIndex,
    required bool shouldRepeat,
    int? autoEndSeconds,
    String? ringtoneUri,
  }) async {
    await init();
    await _plugin.show(
      _callId,
      callerName,
      'Incoming call…',
      _callDetails(ringIndex: ringIndex, ringtoneUri: ringtoneUri),
      payload: _callPayload(
        callerName: callerName,
        callerPhone: callerPhone,
        ringIndex: ringIndex,
        shouldRepeat: shouldRepeat,
        autoEndSeconds: autoEndSeconds,
        ringtoneUri: ringtoneUri,
      ),
    );
  }

  /// Cancel a scheduled (or showing) fake call by its notification id.
  Future<void> cancelFakeCall(int id) => _plugin.cancel(id);

  /// Cancel every pending and shown notification (used by "Erase and start
  /// over", so no scheduled fake call or reminder outlives the data).
  Future<void> cancelAll() => _plugin.cancelAll();

  // ---------------------------------------------------------------------------
  // Routing
  // ---------------------------------------------------------------------------

  // Foreground/background tap.
  static void _onResponse(NotificationResponse response) {
    instance._route(response.payload, notificationId: response.id);
  }

  void _route(String? payload, {int? notificationId}) {
    if (payload == null || payload.isEmpty) return;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (data['type'] != 'fake_call') return;

    // The call screen takes over the ringing, so silence the notification's
    // looping ringtone first (otherwise both would ring at once).
    if (notificationId != null) _plugin.cancel(notificationId);

    final ringIndex = (data['ring'] as int?) ?? 0;
    final autoEnd = data['autoEnd'] as int?;

    void open() {
      final nav = rootNavigatorKey.currentState;
      if (nav == null) return;
      nav.push(MaterialPageRoute<void>(
        builder: (_) => FakeCallScreen(
          callerName: (data['name'] as String?) ?? 'Mom',
          callerPhone: (data['phone'] as String?) ?? '',
          shouldRepeat: (data['repeat'] as bool?) ?? false,
          autoEndSeconds: autoEnd,
          ringSound: RingSound.values[ringIndex],
          ringtoneUri: data['ringUri'] as String?,
        ),
      ));
    }

    // The navigator may not be ready yet on a cold start; retry next frame.
    if (rootNavigatorKey.currentState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => open());
    } else {
      open();
    }
  }
}
