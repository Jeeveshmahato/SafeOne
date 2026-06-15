import 'package:audioplayers/audioplayers.dart';

import 'call_sound.dart';

/// Plays (and stops) a classic phone-ring tone while a fake call is "ringing".
///
/// The sound file lives at assets/sounds/ringtone.wav and is bundled with the
/// app, so it works WITHOUT internet. It loops until [stop] is called.
class RingtoneService implements CallSound {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  @override
  bool get isActive => _isPlaying;

  /// Start the ringtone. It loops until [stop] is called.
  @override
  Future<void> start() async {
    if (_isPlaying) return;
    _isPlaying = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      // AssetSource path is relative to the "assets/" folder.
      await _player.play(AssetSource('sounds/ringtone.wav'));
    } catch (_) {
      _isPlaying = false;
    }
  }

  /// Stop the ringtone.
  @override
  Future<void> stop() async {
    if (!_isPlaying) return;
    _isPlaying = false;
    await _player.stop();
  }

  /// Free up the player when it is no longer needed.
  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
