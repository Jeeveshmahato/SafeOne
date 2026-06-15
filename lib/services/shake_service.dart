import 'package:shake/shake.dart';

/// Detects when the user shakes the phone, and runs a function in response.
///
/// We use this so the SOS can be triggered WITHOUT opening or looking at the
/// app (handy in a real emergency). It wraps the `shake` package so the rest
/// of the app stays simple.
class ShakeService {
  ShakeDetector? _detector;

  /// Start listening. [onShake] is called every time a shake is detected.
  void start(void Function() onShake) {
    // Avoid starting twice.
    if (_detector != null) return;
    _detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) => onShake(),
    );
  }

  /// Stop listening (e.g. when the user turns the feature off).
  void stop() {
    _detector?.stopListening();
    _detector = null;
  }

  bool get isListening => _detector != null;
}
