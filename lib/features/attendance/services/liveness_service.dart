import 'dart:ui';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Hasil dari satu sesi liveness check.
class LivenessResult {
  final bool passed;
  final String? failReason;
  final String? photoPath; // path file foto saat lulus

  const LivenessResult({
    required this.passed,
    this.failReason,
    this.photoPath,
  });

  factory LivenessResult.fail(String reason) =>
      LivenessResult(passed: false, failReason: reason);
}

/// Status step liveness yang ditampilkan ke user.
enum LivenessStep {
  initializing, // kamera & detektor belum siap
  lookStraight, // minta user lihat lurus ke kamera
  blink, // minta user kedipkan mata
  passed, // lulus semua step
  failed, // gagal
}

/// Service yang mengelola pipeline liveness detection:
///   1. Pastikan wajah terdeteksi di frame
///   2. Pastikan mata terbuka (bukan foto orang tidur / gambar)
///   3. Minta user kedipkan mata → konfirmasi liveness
///
/// Menggunakan Google ML Kit Face Detection — ondevice, gratis, tanpa server.
class LivenessService {
  LivenessService._();
  static final LivenessService instance = LivenessService._();

  CameraController? _camera;
  FaceDetector? _detector;
  bool _isProcessing = false;

  final _stepController = StreamController<LivenessStep>.broadcast();
  Stream<LivenessStep> get stepStream => _stepController.stream;

  static const double _eyeOpenThreshold = 0.4;
  static const double _eyeClosedThreshold = 0.2;
  static const int _blinkTimeoutSec = 8;

  Future<CameraController?> initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _camera = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _camera!.initialize();
      return _camera;
    } catch (e) {
      return null;
    }
  }

  void _initDetector() {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: false,
        minFaceSize: 0.25,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<LivenessResult> runCheck() async {
    _initDetector();
    if (_camera == null || !_camera!.value.isInitialized) {
      return LivenessResult.fail('Kamera tidak tersedia.');
    }

    _stepController.add(LivenessStep.lookStraight);

    final faceDetected = await _waitForCondition(
      timeoutSec: 5,
      condition: (faces) {
        if (faces.isEmpty) return false;
        final f = faces.first;
        final leftOpen = f.leftEyeOpenProbability ?? 0;
        final rightOpen = f.rightEyeOpenProbability ?? 0;
        return leftOpen > _eyeOpenThreshold && rightOpen > _eyeOpenThreshold;
      },
    );

    if (!faceDetected) {
      _stepController.add(LivenessStep.failed);
      return LivenessResult.fail(
        'Wajah tidak terdeteksi atau mata tertutup.\n'
        'Pastikan wajah Anda terlihat jelas dan mata terbuka.',
      );
    }

    _stepController.add(LivenessStep.blink);

    bool eyesWereClosed = false;
    final blinkDetected = await _waitForCondition(
      timeoutSec: _blinkTimeoutSec,
      condition: (faces) {
        if (faces.isEmpty) return false;
        final f = faces.first;
        final leftOpen = f.leftEyeOpenProbability ?? 1;
        final rightOpen = f.rightEyeOpenProbability ?? 1;
        final closed =
            leftOpen < _eyeClosedThreshold && rightOpen < _eyeClosedThreshold;
        final open =
            leftOpen > _eyeOpenThreshold && rightOpen > _eyeOpenThreshold;

        if (closed) eyesWereClosed = true;
        if (eyesWereClosed && open) return true;
        return false;
      },
    );

    if (!blinkDetected) {
      _stepController.add(LivenessStep.failed);
      return LivenessResult.fail(
        'Kedipan mata tidak terdeteksi dalam $_blinkTimeoutSec detik.\n'
        'Coba lagi dan kedipkan mata secara natural.',
      );
    }

    String? photoPath;
    try {
      final xfile = await _camera!.takePicture();
      photoPath = xfile.path;
    } catch (_) {}

    _stepController.add(LivenessStep.passed);
    return LivenessResult(passed: true, photoPath: photoPath);
  }

  Future<bool> _waitForCondition({
    required int timeoutSec,
    required bool Function(List<Face> faces) condition,
  }) async {
    final deadline = DateTime.now().add(Duration(seconds: timeoutSec));
    final completer = Completer<bool>();

    void processImage(CameraImage image) async {
      if (_isProcessing || completer.isCompleted) return;
      if (DateTime.now().isAfter(deadline)) {
        if (!completer.isCompleted) completer.complete(false);
        return;
      }

      _isProcessing = true;
      try {
        final inputImage = _cameraImageToInputImage(image);
        if (inputImage == null) {
          _isProcessing = false;
          return;
        }

        final faces = await _detector!.processImage(inputImage);
        if (condition(faces) && !completer.isCompleted) {
          completer.complete(true);
        }
      } catch (_) {
      } finally {
        _isProcessing = false;
      }
    }

    await _camera!.startImageStream(processImage);

    Future.delayed(Duration(seconds: timeoutSec + 1), () {
      if (!completer.isCompleted) completer.complete(false);
    });

    final result = await completer.future;
    try {
      await _camera!.stopImageStream();
    } catch (_) {}
    return result;
  }

  InputImage? _cameraImageToInputImage(CameraImage image) {
    try {
      final camera = _camera!.description;
      final rotation = InputImageRotationValue.fromRawValue(
            camera.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      return InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      await _camera?.stopImageStream();
    } catch (_) {}
    try {
      await _camera?.dispose();
    } catch (_) {}
    try {
      await _detector?.close();
    } catch (_) {}
    _camera = null;
    _detector = null;
    _isProcessing = false;
  }
}
