import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'vault.dart';

/// Records audio from the microphone and saves it as a file on the phone.
///
/// Useful for capturing evidence during an emergency. Recordings are stored in
/// the app's private folder on the device (they stay on the phone).
class RecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Start recording. Returns true if it started, false if mic permission was
  /// denied. The saved file path is remembered until [stop] is called.
  Future<bool> start() async {
    if (_isRecording) return true;

    // Ask for microphone permission (the package handles the prompt).
    final bool allowed = await _recorder.hasPermission();
    if (!allowed) return false;

    // Build a file path like .../recording_1717000000000.m4a
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final path = '${dir.path}/$fileName';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _isRecording = true;
    return true;
  }

  /// Stop recording. Returns the saved file path (or null if nothing recorded).
  ///
  /// The recording is encrypted into the [Vault] straight away (this works
  /// even while the app is locked) and the plain audio file is removed, so it
  /// can only be played back by someone who can unlock SafeOne.
  Future<String?> stop() async {
    if (!_isRecording) return null;
    _isRecording = false;
    final path = await _recorder.stop();
    if (path == null) return null;
    try {
      return await Vault.instance.sealFile(path);
    } catch (_) {
      // No vault (can't happen once a PIN exists): keep the evidence.
      return path;
    }
  }

  /// Free up the recorder when no longer needed.
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
