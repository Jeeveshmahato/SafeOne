import 'package:audioplayers/audioplayers.dart';

import 'call_sound.dart';

/// Plays a police-vehicle "wail" siren — the sweeping hi-lo electronic siren
/// used by police/emergency vehicles in India.
///
/// It plays a dedicated, seamlessly-looping asset (assets/sounds/police_siren.wav)
/// so it sounds clearly different from the plain alarm [SirenService]. The file
/// is bundled with the app, so it works WITHOUT internet.
class PoliceSirenService implements CallSound {
  final AudioPlayer _player = AudioPlayer();
  bool _active = false;

  /// Start the police wail siren. It loops until [stop] is called.
  @override
  Future<void> start() async {
    if (_active) return;
    _active = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      // AssetSource path is relative to the "assets/" folder.
      await _player.play(AssetSource('sounds/police_siren.wav'));
    } catch (_) {
      _active = false;
    }
  }

  /// Stop the police siren.
  @override
  Future<void> stop() async {
    if (!_active) return;
    _active = false;
    await _player.stop();
  }

  /// Check if the police siren is currently playing.
  @override
  bool get isActive => _active;

  /// Clean up resources when done.
  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
