import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/liveness_service.dart';

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({super.key});

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  final LivenessService _service = LivenessService.instance;

  CameraController? _camera;
  LivenessStep _step = LivenessStep.initializing;
  String? _errorMsg;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _service.stepStream.listen((step) {
      if (mounted) setState(() => _step = step);
    });
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _step = LivenessStep.initializing;
      _errorMsg = null;
      _isRunning = true;
    });

    final camera = await _service.initCamera();
    if (!mounted) return;

    if (camera == null) {
      setState(() {
        _errorMsg = 'Tidak dapat mengakses kamera. Periksa izin kamera.';
        _step = LivenessStep.failed;
        _isRunning = false;
      });
      return;
    }

    setState(() => _camera = camera);

    final result = await _service.runCheck();
    if (!mounted) return;

    setState(() => _isRunning = false);

    if (result.passed) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).pop(result);
    } else {
      setState(() => _errorMsg = result.failReason);
    }
  }

  Future<void> _retry() async {
    await _service.dispose();
    setState(() => _camera = null);
    await _start();
  }

  void _cancel() {
    Navigator.of(context).pop(
      _step == LivenessStep.failed
          ? LivenessResult.fail(_errorMsg ?? 'Dibatalkan.')
          : null,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _instructionText() {
    switch (_step) {
      case LivenessStep.initializing:
        return 'Menyiapkan kamera...';
      case LivenessStep.lookStraight:
        return 'Lihat lurus ke kamera';
      case LivenessStep.blink:
        return 'Kedipkan mata Anda';
      case LivenessStep.passed:
        return 'Verifikasi berhasil ✓';
      case LivenessStep.failed:
        return _errorMsg ?? 'Verifikasi gagal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    final bool isFailed = _step == LivenessStep.failed;
    final bool isPassed = _step == LivenessStep.passed;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (camera != null && camera.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: camera.value.previewSize?.height ?? 1,
                    height: camera.value.previewSize?.width ?? 1,
                    child: CameraPreview(camera),
                  ),
                ),
              )
            else
              const Positioned.fill(
                child: ColoredBox(color: Colors.black),
              ),
            Positioned.fill(
              child: CustomPaint(
                painter: _FaceOvalOverlayPainter(
                  borderColor: isFailed
                      ? AppColors.danger
                      : isPassed
                          ? AppColors.success
                          : Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: _cancel,
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 48,
              child: Column(
                children: [
                  if (_isRunning && !isFailed && !isPassed)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  if (isPassed)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Icon(Icons.check_circle,
                          color: AppColors.success, size: 40),
                    ),
                  if (isFailed)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Icon(Icons.error_outline,
                          color: AppColors.danger, size: 40),
                    ),
                  Text(
                    _instructionText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isFailed) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceOvalOverlayPainter extends CustomPainter {
  final Color borderColor;
  _FaceOvalOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double ovalWidth = size.width * 0.7;
    final double ovalHeight = ovalWidth * 1.3;
    final Offset center = Offset(size.width / 2, size.height * 0.42);
    final Rect ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path ovalPath = Path()..addOval(ovalRect);
    final Path cutoutPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      ovalPath,
    );

    canvas.drawPath(
      cutoutPath,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceOvalOverlayPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
