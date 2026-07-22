import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 72,
    this.color = AppColors.primary,
    this.traceColor = AppColors.surface,
  });

  final double size;
  final Color color;
  final Color traceColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BrandMarkPainter(color: color, traceColor: traceColor),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter({required this.color, required this.traceColor});

  final Color color;
  final Color traceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path shield = Path()
      ..moveTo(w * 0.500, h * 0.090)
      ..quadraticBezierTo(w * 0.335, h * 0.168, w * 0.196, h * 0.216)
      ..lineTo(w * 0.196, h * 0.602)
      ..cubicTo(
        w * 0.196,
        h * 0.742,
        w * 0.330,
        h * 0.846,
        w * 0.500,
        h * 0.906,
      )
      ..cubicTo(
        w * 0.670,
        h * 0.846,
        w * 0.804,
        h * 0.742,
        w * 0.804,
        h * 0.602,
      )
      ..lineTo(w * 0.804, h * 0.216)
      ..quadraticBezierTo(w * 0.665, h * 0.168, w * 0.500, h * 0.090)
      ..close();

    canvas.drawPath(shield, Paint()..color = color);

    final Path trace = Path()
      ..moveTo(w * 0.232, h * 0.497)
      ..lineTo(w * 0.356, h * 0.497)
      ..lineTo(w * 0.386, h * 0.437)
      ..lineTo(w * 0.420, h * 0.518)
      ..lineTo(w * 0.487, h * 0.272)
      ..lineTo(w * 0.552, h * 0.666)
      ..lineTo(w * 0.601, h * 0.497)
      ..lineTo(w * 0.775, h * 0.497);

    canvas.drawPath(
      trace,
      Paint()
        ..color = traceColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.036
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.traceColor != traceColor;
}
