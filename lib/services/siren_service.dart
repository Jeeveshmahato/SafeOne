import 'package:audioplayers/audioplayers.dart';

/// Plays (and stops) a loud siren sound to scare an attacker and draw attention.
///
/// The sound file lives at assets/sounds/siren.wav and is bundled with the app,
/// so it works WITHOUT internet.
class SirenService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Start the siren. It loops until [stop] is called.
  Future<void> start() async {
    if (_isPlaying) return;
    _isPlaying = true;

    // Loop the sound forever and play at full volume.
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);
    // Note: AssetSource path is relative to the "assets/" folder.
    await _player.play(AssetSource('sounds/siren.wav'));
  }

  /// Stop the siren.
  Future<void> stop() async {
    if (!_isPlaying) return;
    _isPlaying = false;
    await _player.stop();
  }

  /// Free up the player when it is no longer needed.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
