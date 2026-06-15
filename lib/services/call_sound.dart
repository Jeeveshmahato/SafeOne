/// A simple start/stop sound used while a fake call is ringing.
///
/// Both [RingtoneService] (a phone ring) and [PoliceSirenService] (a siren)
/// implement this, so the call screen can treat them interchangeably and tests
/// can inject a no-op fake instead of touching real audio hardware.
abstract class CallSound {
  /// Whether the sound is currently playing.
  bool get isActive;

  /// Start playing (loops until [stop]).
  Future<void> start();

  /// Stop playing.
  Future<void> stop();

  /// Release underlying audio resources.
  Future<void> dispose();
}
