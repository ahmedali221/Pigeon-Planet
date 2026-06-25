import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import 'public_bird_page.dart';

import '../../../../l10n/app_localizations.dart';
class BirdQrScannerPage extends StatefulWidget {
  BirdQrScannerPage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BirdQrScannerPage()),
      );

  @override
  State<BirdQrScannerPage> createState() => _BirdQrScannerPageState();
}

class _BirdQrScannerPageState extends State<BirdQrScannerPage> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _navigating = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Parses the scanned value to extract the bird public_id.
  /// Accepts a full URL (`https://example.com/birds/{public_id}`)
  /// or a bare UUID string as fallback.
  String? _extractPublicId(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final segments = uri.pathSegments;
      final birdsIdx = segments.indexOf('birds');
      if (birdsIdx >= 0 && birdsIdx + 1 < segments.length) {
        final id = segments[birdsIdx + 1];
        if (id.isNotEmpty) return id;
      }
    }
    // Fallback: bare UUID string
    final uuidRe = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (uuidRe.hasMatch(raw.trim())) return raw.trim();
    return null;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_navigating) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final publicId = _extractPublicId(raw);
    if (publicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).invalidQrCode),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _navigating = true);
    _ctrl.stop();
    PublicBirdPage.push(context, publicId).then((_) {
      if (mounted) {
        setState(() => _navigating = false);
        _ctrl.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PPWAppBar(
        backgroundColor: Colors.black,
        title: AppLocalizations.of(context).mshRmz,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _ctrl.toggleTorch(),
            tooltip: AppLocalizations.of(context).no10,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera feed ───────────────────────────────────────────────
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // ── Scan frame overlay ────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ScanFrame(scanning: !_navigating),
                SizedBox(height: 28),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _navigating
                        ? AppLocalizations.of(context).loading6
                        : AppLocalizations.of(context).wjhAlkamyraNhwRmzAla,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  final bool scanning;

  _ScanFrame({required this.scanning});

  @override
  Widget build(BuildContext context) {
    final size = 220.0;
    final cornerLen = 24.0;
    final cornerWidth = 3.5;
    final color = scanning ? AppColors.primary : Colors.white54;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // top-right corner (in RTL: visually top-left)
          Positioned(
            top: 0,
            right: 0,
            child: _Corner(
                color: color, len: cornerLen, width: cornerWidth, top: true, start: true),
          ),
          // top-left corner
          Positioned(
            top: 0,
            left: 0,
            child: _Corner(
                color: color, len: cornerLen, width: cornerWidth, top: true, start: false),
          ),
          // bottom-right corner
          Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(
                color: color, len: cornerLen, width: cornerWidth, top: false, start: true),
          ),
          // bottom-left corner
          Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(
                color: color, len: cornerLen, width: cornerWidth, top: false, start: false),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double len;
  final double width;
  final bool top;
  final bool start;

  _Corner({
    required this.color,
    required this.len,
    required this.width,
    required this.top,
    required this.start,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
        painter: _CornerPainter(
            color: color, width: width, top: top, start: start),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double width;
  final bool top;
  final bool start;

  _CornerPainter(
      {required this.color,
      required this.width,
      required this.top,
      required this.start});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = start ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = start ? size.width : -size.width;
    final dy = top ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.width != width;
}
