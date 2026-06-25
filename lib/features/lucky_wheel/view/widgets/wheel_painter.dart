import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/wheel_prize_model.dart';

class WheelPainter extends CustomPainter {
  final List<WheelPrizeModel> prizes;

  const WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    if (prizes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final n = prizes.length;
    final sliceAngle = 2 * pi / n;
    const startOffset = -pi / 2;

    final segPaint = Paint()..style = PaintingStyle.fill;
    final divPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < n; i++) {
      segPaint.color = prizes[i].color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startOffset + i * sliceAngle,
        sliceAngle,
        true,
        segPaint,
      );
    }

    for (int i = 0; i < n; i++) {
      final angle = startOffset + i * sliceAngle;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        divPaint,
      );
    }

    canvas.drawCircle(
      center,
      radius + 1,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    for (int i = 0; i < n; i++) {
      final midAngle = startOffset + (i + 0.5) * sliceAngle;
      final textR = radius * 0.58;
      final prize = prizes[i];
      final icon = prize.showIcon ? prize.emoji.trim() : '';
      final label = prize.label.trim();
      final text = [
        if (icon.isNotEmpty) icon,
        if (label.isNotEmpty) label,
      ].join('\n');
      if (text.isEmpty) continue;

      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: _textColorFor(prize.color),
            fontSize: icon.isNotEmpty ? 12 : 13,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        textAlign: TextAlign.center,
        maxLines: icon.isNotEmpty ? 3 : 2,
        ellipsis: '...',
        textDirection: _textDirectionFor(label),
      )..layout(maxWidth: radius * (n <= 4 ? 0.46 : 0.36));

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(midAngle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -textR - tp.height / 2));
      canvas.restore();
    }

    canvas.drawCircle(center, 24, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      24,
      Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(center, 10, Paint()..color = Colors.grey.shade300);
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) =>
      oldDelegate.prizes != prizes;

  Color _textColorFor(Color background) {
    return background.computeLuminance() > 0.45
        ? Colors.black.withValues(alpha: 0.82)
        : Colors.white;
  }

  TextDirection _textDirectionFor(String text) {
    final hasRtl = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return hasRtl ? TextDirection.rtl : TextDirection.ltr;
  }
}
