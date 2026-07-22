import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'section_card.dart';
import 'status_pill.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.deltaLabel,
    this.deltaTone = StatusTone.neutral,
    this.sparkline,
    this.onTap,
  });

  final String label;
  final String value;
  final String? unit;
  final String? deltaLabel;
  final StatusTone deltaTone;
  final List<double>? sparkline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: text.bodySmall, maxLines: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(value, style: AppTypography.numeric(fontSize: 24)),
              if (unit != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Text(unit!, style: text.bodySmall),
              ],
            ],
          ),
          if (sparkline != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 26,
              width: double.infinity,
              child: CustomPaint(
                painter: SparklinePainter(
                  values: sparkline!,
                  color: deltaTone == StatusTone.neutral
                      ? AppColors.primary
                      : deltaTone.foreground,
                ),
              ),
            ),
          ],
          if (deltaLabel != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            StatusPill(label: deltaLabel!, tone: deltaTone),
          ],
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  const SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final double min = values.reduce((double a, double b) => a < b ? a : b);
    final double max = values.reduce((double a, double b) => a > b ? a : b);
    final double range = max - min;
    final double step = size.width / (values.length - 1);

    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final double normalised = range == 0 ? 0.5 : (values[i] - min) / range;
      final Offset point = Offset(
        step * i,
        size.height - (normalised * size.height),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
