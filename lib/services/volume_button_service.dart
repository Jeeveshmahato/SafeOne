import 'package:flutter/services.dart';

/// Detects a quick triple-press of a volume button and fires a callback —
/// a discreet way to trigger the SOS without looking at the screen.
///
/// The actual key events come from the Android side (see MainActivity.kt),
/// which forwards each volume press over a [MethodChannel] WITHOUT consuming
/// it, so the volume still changes normally. This class just counts presses
/// inside a short time window.
class VolumeButtonService {
  static const _channel = MethodChannel('women_safety/volume_button');

  /// How close together the three presses must be.
  static const _window = Duration(milliseconds: 1500);

  final List<DateTime> _presses = [];
  void Function()? _onTriplePress;

  void start({required void Function() onTriplePress}) {
    _onTriplePress = onTriplePress;
    _channel.setMethodCallHandler(_handle);
  }

  void stop() {
    _onTriplePress = null;
    _presses.clear();
    _channel.setMethodCallHandler(null);
  }

  Future<dynamic> _handle(MethodCall call) async {
    if (call.method != 'volumePressed' || _onTriplePress == null) return;
    final now = DateTime.now();
    _presses.add(now);
    // Drop presses older than the window.
    _presses.removeWhere((t) => now.difference(t) > _window);
    if (_presses.length >= 3) {
      _presses.clear();
      _onTriplePress!.call();
    }
  }
}
