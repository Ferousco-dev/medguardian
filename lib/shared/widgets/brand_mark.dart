import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 72,
    this.color = AppColors.primary,
    this.traceColor = AppColors.surface,
    this.filled = true,
  });

  final double size;
  final Color color;
  final Color traceColor;

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BrandMarkPainter(
          color: color,
          traceColor: traceColor,
          filled: filled,
        ),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter({
    required this.color,
    required this.traceColor,
    required this.filled,
  });

  final Color color;
  final Color traceColor;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path shield = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.9, h * 0.2)
      ..lineTo(w * 0.9, h * 0.52)
      ..cubicTo(w * 0.9, h * 0.78, w * 0.72, h * 0.92, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.28, h * 0.92, w * 0.1, h * 0.78, w * 0.1, h * 0.52)
      ..lineTo(w * 0.1, h * 0.2)
      ..close();

    final Paint shieldPaint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(shield, shieldPaint);

    final Path trace = Path()
      ..moveTo(w * 0.24, h * 0.5)
      ..lineTo(w * 0.38, h * 0.5)
      ..lineTo(w * 0.45, h * 0.34)
      ..lineTo(w * 0.56, h * 0.66)
      ..lineTo(w * 0.63, h * 0.5)
      ..lineTo(w * 0.76, h * 0.5);

    final Paint tracePaint = Paint()
      ..color = filled ? traceColor : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(trace, tracePaint);
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.traceColor != traceColor ||
        oldDelegate.filled != filled;
  }
}
