import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../viewmodel/pigeon_id_bloc.dart';
import 'pigeon_id_preview_page.dart';

import '../../../../l10n/app_localizations.dart';
class ZajelScannerPage extends StatefulWidget {
  ZajelScannerPage({super.key});

  @override
  State<ZajelScannerPage> createState() => _ZajelScannerPageState();
}

class _ZajelScannerPageState extends State<ZajelScannerPage> {
  late final List<_ScanStep> _steps;

  // Camera
  CameraController? _cameraController;
  bool _cameraReady = false;
  String? _cameraError;

  // Accelerometer
  StreamSubscription<AccelerometerEvent>? _accelSub;
  Timer? _stabilityTimer;
  double _tiltOffset = 0.5;

  // Scan state
  int _currentStep = 0;
  bool _isStable = false;
  bool _allDone = false;

  // Video recording
  bool _isRecording = false;
  double _recordingProgress = 0.0;
  Timer? _recordingTimer;
  final List<String> _clipPaths = [];

  // FFmpeg processing
  bool _isProcessing = false;
  String? _processingError;

  @override
  void initState() {
    super.initState();
    _steps = [
      _ScanStep(label: AppLocalizations.of(context).no11, emoji: '🦢', hint: AppLocalizations.of(context).no12),
      _ScanStep(label: AppLocalizations.of(context).aljnahYmynYsar, emoji: '🪶', hint: AppLocalizations.of(context).afrdAljnahWqrbhMnAlkamyra),
      _ScanStep(label: AppLocalizations.of(context).alaynMakrw, emoji: '👁️', hint: AppLocalizations.of(context).no13),
      _ScanStep(label: AppLocalizations.of(context).rqmAldbla, emoji: '🔢', hint: AppLocalizations.of(context).takdMnWdwhArqamAldbla),
    ];
    _initCamera();
    _listenAccelerometer();
  }

  Future<void> _initCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (!cameraStatus.isGranted) {
      if (mounted) setState(() => _cameraError = AppLocalizations.of(context).mtlwbIthnAlkamyra);
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = AppLocalizations.of(context).no14);
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: micStatus.isGranted,
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      _cameraController = controller;
      setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) setState(() => _cameraError = AppLocalizations.of(context).tathrTshghylAlkamyra);
    }
  }

  void _listenAccelerometer() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen((event) {
      if (!mounted) return;
      final tilt = event.x.abs() + event.z.abs();
      final offset = ((event.x + 2.5) / 5.0).clamp(0.0, 1.0);
      setState(() => _tiltOffset = offset);
      final nowStable = tilt < 1.5;

      if (nowStable && !_isStable && !_isRecording && !_allDone && !_isProcessing) {
        _stabilityTimer ??= Timer(Duration(milliseconds: 700), () {
          if (!mounted || _isRecording || _allDone) return;
          setState(() => _isStable = true);
          _startVideoRecording();
        });
      } else if (!nowStable && !_isRecording) {
        _stabilityTimer?.cancel();
        _stabilityTimer = null;
        if (_isStable) setState(() => _isStable = false);
      }
    });
  }

  Future<void> _startVideoRecording() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      _resetForRetry();
      return;
    }
    setState(() {
      _isRecording = true;
      _recordingProgress = 0.0;
    });
    try {
      await controller.startVideoRecording();
    } catch (_) {
      _resetForRetry();
      return;
    }
    _recordingTimer = Timer.periodic(Duration(milliseconds: 100), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _recordingProgress += 0.02); // 50 ticks = 5 seconds
      if (_recordingProgress >= 1.0) {
        t.cancel();
        _stopVideoRecording();
      }
    });
  }

  Future<void> _stopVideoRecording() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isRecordingVideo) {
      _resetForRetry();
      return;
    }
    try {
      final xFile = await controller.stopVideoRecording();
      if (!mounted) return;
      _clipPaths.add(xFile.path);
      _onStepCaptured();
    } catch (_) {
      _resetForRetry();
    }
  }

  void _safeStopRecording() async {
    try {
      await _cameraController?.stopVideoRecording();
    } catch (_) {}
  }

  void _resetForRetry() {
    if (!mounted) return;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    if (_cameraController?.value.isRecordingVideo == true) {
      _safeStopRecording();
    }
    setState(() {
      _isRecording = false;
      _recordingProgress = 0.0;
      _isStable = false;
    });
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  void _onStepCaptured() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _recordingProgress = 0.0;
        _isStable = false;
        _isRecording = false;
      });
      _stabilityTimer?.cancel();
      _stabilityTimer = null;
    } else {
      setState(() {
        _allDone = true;
        _isRecording = false;
      });
      _mergeClipsWithFFmpeg();
    }
  }

  Future<void> _mergeClipsWithFFmpeg() async {
    if (!mounted) return;
    // Capture bloc and state before any async gap
    final bloc = context.read<PigeonIdBloc>();
    final ringNumber = bloc.state.ringNumber;
    setState(() {
      _isProcessing = true;
      _processingError = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final outputPath = '${dir.path}/zajel_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final now = DateTime.now();
      final captureDate =
          '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
      final antiFraudCode = _generateAntiFraudCode(ringNumber);

      final concatPath = '${dir.path}/concat_list.txt';
      await File(concatPath).writeAsString(
        _clipPaths.map((p) => "file '$p'").join('\n'),
      );

      final font = '/system/fonts/Roboto-Regular.ttf';
      final vf = [
        "drawtext=fontfile=$font:text='Pigeon Planet':fontsize=18:fontcolor=white@0.7:x=10:y=h-th-10:shadowcolor=black:shadowx=1:shadowy=1",
        "drawtext=fontfile=$font:text='$captureDate':fontsize=16:fontcolor=white@0.7:x=(w-tw)/2:y=h-th-10:shadowcolor=black:shadowx=1:shadowy=1",
        "drawtext=fontfile=$font:text='$ringNumber':fontsize=20:fontcolor=white:x=w-tw-10:y=10:box=1:boxcolor=black@0.4:boxborderw=4",
        "drawtext=fontfile=$font:text='CODE\\: $antiFraudCode':fontsize=14:fontcolor=white@0.9:x=w-tw-10:y=h-th-30:shadowcolor=black:shadowx=1:shadowy=1",
      ].join(',');

      final cmd =
          '-f concat -safe 0 -i "$concatPath" -vf "$vf" -an -c:v libx264 -preset fast -crf 23 -movflags +faststart "$outputPath"';

      final session = await FFmpegKit.execute(cmd);
      if (!mounted) return;

      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        bloc.add(PigeonIdVideoRecorded(outputPath));
        setState(() => _isProcessing = false);
      } else {
        final logs = await session.getLogs();
        for (final log in logs) {
          debugPrint('[FFmpeg] ${log.getMessage()}');
        }
        setState(() {
          _isProcessing = false;
          _processingError = AppLocalizations.of(context).fshlDmjAlfydyw;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingError = AppLocalizations.of(context).fshlDmjAlfydyw2;
        });
      }
    }
  }

  String _generateAntiFraudCode(String ringNumber) {
    int hash = 5381;
    for (final c in '$ringNumber::${DateTime.now().millisecondsSinceEpoch}'.codeUnits) {
      hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  void _proceedToPreview() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PigeonIdBloc>(),
          child: PigeonIdPreviewPage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _stabilityTimer?.cancel();
    _recordingTimer?.cancel();
    if (_cameraController?.value.isRecordingVideo == true) {
      _safeStopRecording();
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera viewfinder ──────────────────────────────────────────
          Positioned.fill(
            child: _cameraError != null
                ? _ErrorView(message: _cameraError!)
                : !_cameraReady
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.white38),
                      )
                    : CameraPreview(_cameraController!),
          ),

          // ── Per-step guide overlay (CustomPainter) ─────────────────────
          if (_cameraReady && !_allDone)
            Positioned.fill(
              child: CustomPaint(
                painter: _ScanOverlayPainter(
                  step: _currentStep,
                  isStable: _isStable,
                  recordingProgress: _recordingProgress,
                ),
              ),
            ),

          // ── Center leveler line ────────────────────────────────────────
          if (_cameraReady && !_allDone)
            Positioned(
              left: 0,
              right: 0,
              top: screenSize.height / 2 - 1,
              child: _CenterLeveler(
                tiltOffset: _tiltOffset,
                isStable: _isStable,
                screenWidth: screenSize.width,
              ),
            ),

          // ── Done / Processing overlay ──────────────────────────────────
          if (_allDone)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: _isProcessing
                    ? _ProcessingView()
                    : _processingError != null
                        ? _ProcessingErrorView(
                            message: _processingError!,
                            onRetry: _mergeClipsWithFFmpeg,
                            onSkip: _proceedToPreview,
                          )
                        : _DoneView(onPreview: _proceedToPreview),
              ),
            ),

          // ── Top bar — icon step indicator ──────────────────────────────
          if (!_allDone)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Icon stepper (centered)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (i) {
                        final isDone = i < _currentStep;
                        final isActive = i == _currentStep;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (i > 0)
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                width: 24,
                                height: 2,
                                color: isDone ? AppColors.primary : Colors.white24,
                              ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: isActive ? 44 : 34,
                              height: isActive ? 44 : 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppColors.primary
                                    : isActive
                                        ? Colors.white
                                        : Colors.white12,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha:0.5),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isDone
                                    ? Icon(Icons.check_rounded,
                                        color: Colors.white, size: 18)
                                    : Text(
                                        _steps[i].emoji,
                                        style: TextStyle(fontSize: isActive ? 22 : 16),
                                      ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    // Close button (start = right in RTL)
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom panel — step label + recording indicator ────────────
          if (!_allDone)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_currentStep + 1} / ${_steps.length}  —  ',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                          Text(
                            step.label,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        step.hint,
                        style: TextStyle(
                            color: Colors.white60, fontSize: 12),
                      ),
                      SizedBox(height: 16),
                      if (_isRecording) ...[
                        Row(
                          children: [
                            Icon(Icons.fiber_manual_record,
                                color: Colors.red, size: 10),
                            SizedBox(width: 6),
                            Text(AppLocalizations.of(context).processingLabel,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _recordingProgress,
                            backgroundColor: Colors.white24,
                            color: Colors.red,
                            minHeight: 5,
                          ),
                        ),
                      ] else
                        SizedBox(
                          height: 27,
                          child: Center(
                            child: Text(
                              _isStable
                                  ? AppLocalizations.of(context).thabtSybdaAltsjylTlqayya
                                  : AppLocalizations.of(context).thbtAlkamyraLbdAltsjyl,
                              style: TextStyle(
                                color: _isStable
                                    ? AppColors.primary
                                    : Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────────

class _ScanStep {
  final String label;
  final String emoji;
  final String hint;
  _ScanStep(
      {required this.label, required this.emoji, required this.hint});
}

// ── CustomPainter overlay ──────────────────────────────────────────────────────

class _ScanOverlayPainter extends CustomPainter {
  final int step;
  final bool isStable;
  final double recordingProgress;

  _ScanOverlayPainter({
    required this.step,
    required this.isStable,
    required this.recordingProgress,
  });

  Color get _guideColor => isStable ? AppColors.primary : Colors.white38;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final maskPaint = Paint()..color = Colors.black.withValues(alpha:0.55);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderPaint = Paint()
      ..color = _guideColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    switch (step) {
      case 0: // Full body — tall rounded rect
        final guide = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: 220, height: 320),
          Radius.circular(24),
        );
        _cutMask(canvas, fullRect, Path()..addRRect(guide), maskPaint);
        canvas.drawRRect(guide, borderPaint);
        _drawCornerTicks(canvas, guide.outerRect, borderPaint);

      case 1: // Wing — wide landscape rect
        final guide = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: 300, height: 180),
          Radius.circular(16),
        );
        _cutMask(canvas, fullRect, Path()..addRRect(guide), maskPaint);
        canvas.drawRRect(guide, borderPaint);
        _drawDottedHLine(canvas, guide.outerRect, _guideColor);

      case 2: // Eye — circle with crosshair
        final radius = 110.0;
        final center = Offset(cx, cy);
        _cutMask(canvas, fullRect,
            Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
            maskPaint);
        canvas.drawCircle(center, radius, borderPaint);
        _drawCrosshair(canvas, center, 20, borderPaint);

      case 3: // Ring number — small box shifted down
        final guide = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(cx, cy + 80), width: 200, height: 80),
          Radius.circular(10),
        );
        _cutMask(canvas, fullRect, Path()..addRRect(guide), maskPaint);
        canvas.drawRRect(guide, borderPaint);
    }

    // Recording progress arc (top-start corner)
    if (recordingProgress > 0) {
      final arcPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      final arcRect = Rect.fromLTWH(16, 70, 44, 44);
      canvas.drawArc(
          arcRect, -1.5708, recordingProgress * 6.2832, false, arcPaint);
    }
  }

  void _cutMask(Canvas canvas, Rect full, Path guide, Paint paint) {
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(full),
        guide,
      ),
      paint,
    );
  }

  void _drawCornerTicks(Canvas canvas, Rect r, Paint paint) {
    final len = 20.0;
    final corners = [
      [Offset(r.left, r.top + len), Offset(r.left, r.top), Offset(r.left + len, r.top)],
      [Offset(r.right - len, r.top), Offset(r.right, r.top), Offset(r.right, r.top + len)],
      [Offset(r.left, r.bottom - len), Offset(r.left, r.bottom), Offset(r.left + len, r.bottom)],
      [Offset(r.right - len, r.bottom), Offset(r.right, r.bottom), Offset(r.right, r.bottom - len)],
    ];
    final tickPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final pts in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(pts[0].dx, pts[0].dy)
          ..lineTo(pts[1].dx, pts[1].dy)
          ..lineTo(pts[2].dx, pts[2].dy),
        tickPaint,
      );
    }
  }

  void _drawDottedHLine(Canvas canvas, Rect r, Color color) {
    final dotPaint = Paint()
      ..color = color.withValues(alpha:0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final cy = r.center.dy;
    for (double x = r.left + 8; x < r.right - 8; x += 10) {
      canvas.drawLine(Offset(x, cy), Offset(x + 5, cy), dotPaint);
    }
  }

  void _drawCrosshair(Canvas canvas, Offset center, double half, Paint paint) {
    canvas.drawLine(
        Offset(center.dx - half, center.dy), Offset(center.dx + half, center.dy), paint);
    canvas.drawLine(
        Offset(center.dx, center.dy - half), Offset(center.dx, center.dy + half), paint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.step != step ||
      old.isStable != isStable ||
      old.recordingProgress != recordingProgress;
}

// ── Center leveler ─────────────────────────────────────────────────────────────

class _CenterLeveler extends StatelessWidget {
  final double tiltOffset;
  final bool isStable;
  final double screenWidth;

  _CenterLeveler({
    required this.tiltOffset,
    required this.isStable,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final color = isStable ? AppColors.primary : Colors.white38;
    final dotLeft = (tiltOffset * screenWidth - 8).clamp(0.0, screenWidth - 16);

    return SizedBox(
      height: 16,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Horizontal line
          Positioned(
            left: 0,
            right: 0,
            top: 7,
            child: Container(height: 1, color: color),
          ),
          // Center tick
          Positioned(
            left: screenWidth / 2 - 1,
            top: 1,
            child: Container(width: 2, height: 14, color: color.withValues(alpha:0.9)),
          ),
          // Sliding dot
          AnimatedPositioned(
            duration: Duration(milliseconds: 80),
            left: dotLeft,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isStable ? AppColors.primary : Colors.orangeAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha:0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Done / Processing sub-widgets ──────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  _ProcessingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 24),
        Text(
          'جاري دمج مقاطع الفيديو...',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Text(
          'هذا قد يستغرق بضع ثوانٍ',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}

class _ProcessingErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSkip;

  _ProcessingErrorView({
    required this.message,
    required this.onRetry,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 56),
        SizedBox(height: 16),
        Text(message,
            style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 28),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding:
                EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(AppLocalizations.of(context).reprocessBtn,
              style: TextStyle(color: Colors.white, fontSize: 15)),
        ),
        SizedBox(height: 12),
        TextButton(
          onPressed: onSkip,
          child: Text(
            'تخطي الفيديو والمتابعة',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onPreview;

  _DoneView({required this.onPreview});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: Colors.white, size: 50),
        ),
        SizedBox(height: 20),
        Text(
          'تم التصوير بنجاح!',
          style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'تم دمج الفيديو وإضافة العلامة المائية',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        SizedBox(height: 32),
        ElevatedButton(
          onPressed: onPreview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding:
                EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            'عرض المعاينة',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_rounded,
                color: Colors.white38, size: 48),
            SizedBox(height: 12),
            Text(message,
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
