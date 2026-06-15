import 'dart:async';

import 'package:torch_light/torch_light.dart';

/// Blinks the phone's camera flashlight (torch) on and off repeatedly, like an
/// SOS strobe, to attract attention — especially useful at night.
class FlashlightService {
  Timer? _timer;
  bool _isOn = false; // is the torch currently lit during the blink cycle
  bool _strobing = false;

  bool get isStrobing => _strobing;

  /// Returns true if this phone actually has a flashlight.
  Future<bool> isAvailable() async {
    try {
      return await TorchLight.isTorchAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Start blinking. The torch flips on/off every 400 milliseconds.
  Future<void> start() async {
    if (_strobing) return;
    _strobing = true;

    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) async {
      try {
        if (_isOn) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
        _isOn = !_isOn;
      } catch (_) {
        // If the torch fails for any reason, stop quietly.
        await stop();
      }
    });
  }

  /// Blink the torch in the Morse code pattern for "SOS"
  /// ( ... --- ... = dot dot dot, dash dash dash, dot dot dot ), then pause and
  /// repeat. This is the international distress signal. Returns immediately; the
  /// blinking continues in the background until [stop] is called.
  Future<void> startSos() async {
    if (_strobing) return;
    _strobing = true;

    // One "unit" of time. A dot is 1 unit ON, a dash is 3 units ON. Gaps:
    // 1 unit between blinks, 3 between letters, 7 before repeating.
    const int unitMs = 220;
    // Each step is (turn torch on?, how many units to hold it).
    const List<({bool on, int units})> pattern = [
      (on: true, units: 1), (on: false, units: 1), // S: dot
      (on: true, units: 1), (on: false, units: 1), //    dot
      (on: true, units: 1), (on: false, units: 3), //    dot  (letter gap)
      (on: true, units: 3), (on: false, units: 1), // O: dash
      (on: true, units: 3), (on: false, units: 1), //    dash
      (on: true, units: 3), (on: false, units: 3), //    dash (letter gap)
      (on: true, units: 1), (on: false, units: 1), // S: dot
      (on: true, units: 1), (on: false, units: 1), //    dot
      (on: true, units: 1), (on: false, units: 7), //    dot  (word gap)
    ];

    _runSosPattern(pattern, unitMs);
  }

  /// Walks through the SOS pattern step by step, looping forever until stopped.
  /// Uses a self-scheduling timer so each step can have a different length.
  void _runSosPattern(
      List<({bool on, int units})> pattern, int unitMs) {
    int index = 0;
    void nextStep() {
      if (!_strobing) return;
      final step = pattern[index];
      () async {
        try {
          if (step.on) {
            await TorchLight.enableTorch();
            _isOn = true;
          } else {
            await TorchLight.disableTorch();
            _isOn = false;
          }
        } catch (_) {
          await stop();
          return;
        }
        index = (index + 1) % pattern.length; // loop back to the start
        _timer = Timer(Duration(milliseconds: unitMs * step.units), nextStep);
      }();
    }

    nextStep();
  }

  /// Stop blinking and make sure the torch is left OFF.
  Future<void> stop() async {
    _strobing = false;
    _timer?.cancel();
    _timer = null;
    if (_isOn) {
      try {
        await TorchLight.disableTorch();
      } catch (_) {
        // Ignore — nothing more we can do.
      }
      _isOn = false;
    }
  }
}
