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
    const startOffset = -pi / 2; // first slot starts at 12 o'clock

    final segPaint = Paint()..style = PaintingStyle.fill;
    final divPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // ── Draw segments ─────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final prize = prizes[i];
      segPaint.color =
          prize.isEnabled ? prize.color : Colors.grey.shade300;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startOffset + i * sliceAngle,
        sliceAngle,
        true,
        segPaint,
      );
    }

    // ── Draw divider lines ────────────────────────────────────────────────────
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

    // ── Outer ring ────────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius + 1,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // ── Emoji labels (upright, centered in each segment) ──────────────────────
    for (int i = 0; i < n; i++) {
      final prize = prizes[i];
      final midAngle = startOffset + (i + 0.5) * sliceAngle;
      final textR = radius * 0.62;
      final tx = center.dx + textR * cos(midAngle);
      final ty = center.dy + textR * sin(midAngle);

      final tp = TextPainter(
        text: TextSpan(
          text: prize.emoji,
          style: TextStyle(
            fontSize: 22,
            color: prize.isEnabled ? null : Colors.grey.shade500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(tx - tp.width / 2, ty - tp.height / 2));
    }

    // ── Center hub ────────────────────────────────────────────────────────────
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
}
