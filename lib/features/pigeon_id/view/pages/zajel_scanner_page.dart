import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../viewmodel/pigeon_id_bloc.dart';
import 'pigeon_id_preview_page.dart';

class ZajelScannerPage extends StatefulWidget {
  const ZajelScannerPage({super.key});

  @override
  State<ZajelScannerPage> createState() => _ZajelScannerPageState();
}

class _ZajelScannerPageState extends State<ZajelScannerPage>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    _ScanStep(label: 'الجسم كاملاً', emoji: '🦢', hint: 'وجّه الكاميرا لالتقاط الحمامة بالكامل من الجانب'),
    _ScanStep(label: 'الجناح (يمين / يسار)', emoji: '🪶', hint: 'افرد الجناح وقربه من الكاميرا'),
    _ScanStep(label: 'العين (ماكرو)', emoji: '👁️', hint: 'قرّب الكاميرا من العين لالتقاط التفاصيل'),
    _ScanStep(label: 'رقم الحلقة', emoji: '🔢', hint: 'تأكد من وضوح أرقام الحلقة'),
  ];

  int _currentStep = 0;
  double _captureProgress = 0.0;
  bool _isStable = false;
  bool _isCapturing = false;
  bool _allDone = false;
  Timer? _stabilityTimer;
  Timer? _progressTimer;
  late AnimationController _levelerController;
  late Animation<double> _levelerAnimation;

  @override
  void initState() {
    super.initState();
    _levelerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _levelerAnimation = Tween<double>(begin: -0.4, end: 0.4).animate(
      CurvedAnimation(parent: _levelerController, curve: Curves.easeInOut),
    );
    _levelerController.repeat(reverse: true);
    // Simulate stabilisation after 2 seconds for the first step
    _startStabilitySimulation();
  }

  void _startStabilitySimulation() {
    _stabilityTimer?.cancel();
    _stabilityTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _isStable = true);
      _levelerController.stop();
      _levelerController.value = 0.5; // centred
      _startCapture();
    });
  }

  void _startCapture() {
    setState(() {
      _isCapturing = true;
      _captureProgress = 0.0;
    });
    _progressTimer = Timer.periodic(const Duration(milliseconds: 40), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _captureProgress += 0.02);
      if (_captureProgress >= 1.0) {
        t.cancel();
        _onStepCaptured();
      }
    });
  }

  void _onStepCaptured() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _captureProgress = 0.0;
        _isStable = false;
        _isCapturing = false;
      });
      _levelerController.repeat(reverse: true);
      _startStabilitySimulation();
    } else {
      // All 4 steps done
      setState(() => _allDone = true);
      context
          .read<PigeonIdBloc>()
          .add(const PigeonIdVideoRecorded('zajel_mock_video.mp4'));
    }
  }

  void _proceedToPreview() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PigeonIdBloc>(),
          child: const PigeonIdPreviewPage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stabilityTimer?.cancel();
    _progressTimer?.cancel();
    _levelerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera viewfinder (mock) ───────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
                ),
              ),
            ),
          ),

          // ── Pigeon silhouette overlay ──────────────────────────────────
          Center(
            child: AnimatedOpacity(
              opacity: _allDone ? 0 : 1,
              duration: const Duration(milliseconds: 400),
              child: Container(
                width: 220,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isStable
                        ? AppColors.primary
                        : Colors.white38,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                    const SizedBox(height: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: _isStable ? AppColors.primary : Colors.white54,
                        fontSize: 12,
                      ),
                      child: Text(
                        _isStable ? 'ثابت ✓' : 'ثبّت الكاميرا...',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Done overlay ───────────────────────────────────────────────
          if (_allDone)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تم التسجيل بنجاح!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'جاري معالجة الفيديو...',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _proceedToPreview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'عرض المعاينة',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // ── Top bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // step dots — rightmost in RTL
                  Row(
                    children: List.generate(_steps.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsetsDirectional.only(end: 6),
                        width: i == _currentStep ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i <= _currentStep
                              ? AppColors.primary
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // close button — leftmost in RTL
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom panel ───────────────────────────────────────────────
          if (!_allDone)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step label
                      Row(
                        children: [
                          Text(
                            '${_currentStep + 1} / ${_steps.length}  —  ',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                          Text(
                            step.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        step.hint,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12),
                      ),

                      const SizedBox(height: 16),

                      // Leveler
                      _LevelerBar(
                          animation: _levelerAnimation,
                          isStable: _isStable),

                      const SizedBox(height: 14),

                      // Capture progress bar
                      if (_isCapturing) ...[
                        Row(
                          children: [
                            const Icon(Icons.fiber_manual_record,
                                color: Colors.red, size: 10),
                            const SizedBox(width: 6),
                            const Text('التقاط تلقائي...',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _captureProgress,
                            backgroundColor: Colors.white24,
                            color: AppColors.primary,
                            minHeight: 5,
                          ),
                        ),
                      ] else
                        const SizedBox(
                          height: 27,
                          child: Center(
                            child: Text(
                              'الالتقاط تلقائي — لا تضغط أي زر',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12),
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

class _ScanStep {
  final String label;
  final String emoji;
  final String hint;
  const _ScanStep(
      {required this.label, required this.emoji, required this.hint});
}

class _LevelerBar extends StatelessWidget {
  final Animation<double> animation;
  final bool isStable;

  const _LevelerBar({required this.animation, required this.isStable});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.straighten_rounded,
                color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text(
              isStable ? 'الهاتف مستوٍ ✓' : 'قوّم الهاتف',
              style: TextStyle(
                color: isStable ? AppColors.primary : Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(4),
          ),
          child: isStable
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 1,
                    backgroundColor: Colors.transparent,
                    color: AppColors.primary,
                  ),
                )
              : AnimatedBuilder(
                  animation: animation,
                  builder: (_, _) {
                    final offset = (animation.value + 0.5).clamp(0.0, 1.0);
                    return Stack(
                      children: [
                        Positioned(
                          left: MediaQuery.of(context).size.width *
                              0.6 *
                              offset,
                          child: Container(
                            width: 40,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
