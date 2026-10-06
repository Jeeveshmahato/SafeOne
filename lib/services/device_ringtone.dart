import 'package:flutter/services.dart';

import 'app_lock_service.dart';

import 'call_sound.dart';
import 'ringtone_service.dart';

/// A ringtone the user picked from the phone's ringtone list.
class PickedRingtone {
  const PickedRingtone({required this.uri, this.title});

  /// The ringtone's content URI. Never null for a real pick.
  final String uri;

  /// Display name such as "Pixel Sounds", if the phone provides one.
  final String? title;
}

/// Access to the phone's own ringtones (Android `RingtoneManager`), used so a
/// fake call rings with a real ringtone instead of a notification sound.
class DeviceRingtone {
  DeviceRingtone._();

  static const MethodChannel _channel =
      MethodChannel('com.safeone.app/ringtone');

  /// Opens the system ringtone picker. It lists the phone's ringtones and lets
  /// the user add their own sound file, with no storage permission needed.
  /// Returns null if the user cancels.
  static Future<PickedRingtone?> pick({String? current}) async {
    // The picker is a system screen opened by SafeOne itself; returning from
    // it must not count as leaving the app (which would ask for the PIN).
    AppLockService.systemPromptActive = true;
    try {
      final result = await _channel
          .invokeMapMethod<String, dynamic>('pick', {'current': current});
      final uri = result?['uri'] as String?;
      if (uri == null) return null;
      return PickedRingtone(uri: uri, title: result?['title'] as String?);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    } finally {
      AppLockService.systemPromptActive = false;
    }
  }

  /// The display name of [uri], or of the phone's default ringtone if null.
  static Future<String?> title(String? uri) async {
    try {
      return await _channel.invokeMethod<String>('title', {'uri': uri});
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static Future<bool> _play(String? uri) async {
    try {
      return await _channel.invokeMethod<bool>('play', {'uri': uri}) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> _stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // nothing to stop
    } on MissingPluginException {
      // not on Android
    }
  }
}

/// Rings with a phone ringtone ([uri], or the phone's default when null) on
/// the ringtone volume, looping like a real call. If no ringtone can be played
/// it falls back to the ring sound bundled with the app.
class DeviceRingtoneSound implements CallSound {
  DeviceRingtoneSound(this.uri);

  final String? uri;
  RingtoneService? _fallback;
  bool _active = false;

  @override
  bool get isActive => _active;

  @override
  Future<void> start() async {
    if (_active) return;
    _active = true;
    if (!await DeviceRingtone._play(uri)) {
      _fallback ??= RingtoneService();
      await _fallback!.start();
    }
  }

  @override
  Future<void> stop() async {
    if (!_active) return;
    _active = false;
    await DeviceRingtone._stop();
    await _fallback?.stop();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _fallback?.dispose();
  }
}
