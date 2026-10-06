import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import 'recorder_service.dart';
import 'vault.dart';

/// Captures photos and audio as evidence during an emergency.
///
/// When triggered, it silently takes a front-camera photo and starts audio
/// recording. Both are saved to the app's private storage with timestamps.
class EvidenceService {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final RecorderService _recorderService = RecorderService();
  bool _isCapturingEvidence = false;

  bool get isCapturingEvidence => _isCapturingEvidence;

  /// Initialize the front camera for evidence capture.
  Future<bool> initializeCamera() async {
    if (_isCameraInitialized) return true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return false;

      // Use front camera if available, otherwise fall back to first camera.
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low, // Low res for speed and privacy.
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Capture photo and start audio recording for evidence.
  Future<({String? photoPath, String? audioPath})> captureEvidence() async {
    _isCapturingEvidence = true;
    String? photoPath;
    String? audioPath;

    try {
      // Initialize camera if not already done.
      if (!_isCameraInitialized) {
        await initializeCamera();
      }

      // Capture photo if camera is ready.
      if (_cameraController != null && _isCameraInitialized) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          photoPath = '${dir.path}/evidence_photo_$timestamp.jpg';

          final image = await _cameraController!.takePicture();
          await image.saveTo(photoPath);
          // The camera's own temporary copy would stay readable.
          try {
            await File(image.path).delete();
          } catch (_) {/* already gone */}
          photoPath = await Vault.instance.sealFile(photoPath);
        } catch (e) {
          // Photo capture failed, but continue with audio.
        }
      }

      // Start audio recording silently in the background.
      final recordingStarted = await _recorderService.start();
      if (recordingStarted) {
        // Recording is now running; the caller should stop it later.
        audioPath = 'recording_active';
      }
    } catch (e) {
      // Evidence capture failed, but we still return what was captured.
    }

    _isCapturingEvidence = false;
    return (photoPath: photoPath, audioPath: audioPath);
  }

  /// Stop the audio recording and get its file path.
  Future<String?> stopRecording() async {
    return _recorderService.stop();
  }

  /// Clean up camera resources.
  Future<void> dispose() async {
    await _cameraController?.dispose();
    await _recorderService.dispose();
  }
}
