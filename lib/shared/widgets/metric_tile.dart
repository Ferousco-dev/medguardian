import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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

  Color get _accent => deltaTone == StatusTone.neutral
      ? AppColors.primary
      : deltaTone.foreground;

  IconData? get _deltaIcon => switch (deltaTone) {
    StatusTone.positive => Icons.trending_down_rounded,
    StatusTone.caution || StatusTone.critical => Icons.trending_up_rounded,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 32,
                      child: Text(
                        label,
                        style: text.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.numeric(fontSize: 26),
                          ),
                        ),
                        if (unit != null) ...<Widget>[
                          const SizedBox(width: 3),
                          Text(unit!, style: text.bodySmall),
                        ],
                      ],
                    ),
                    if (deltaLabel != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: <Widget>[
                          if (_deltaIcon != null) ...<Widget>[
                            Icon(_deltaIcon, size: 13, color: _accent),
                            const SizedBox(width: 3),
                          ],
                          Flexible(
                            child: Text(
                              deltaLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelSmall?.copyWith(
                                color: _accent,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (sparkline != null && sparkline!.length > 1)
                SizedBox(
                  height: 34,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: SparklinePainter(
                      values: sparkline!,
                      color: _accent,
                    ),
                  ),
                )
              else
                const SizedBox(height: 34),
            ],
          ),
        ),
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

    const double topInset = 6;
    final double usable = size.height - topInset;

    Offset pointAt(int i) {
      final double normalised = range == 0 ? 0.5 : (values[i] - min) / range;
      return Offset(step * i, topInset + usable - (normalised * usable));
    }

    final Path line = Path();
    final Path fill = Path()..moveTo(0, size.height);

    for (int i = 0; i < values.length; i++) {
      final Offset p = pointAt(i);
      if (i == 0) {
        line.moveTo(p.dx, p.dy);
      } else {
        line.lineTo(p.dx, p.dy);
      }
      fill.lineTo(p.dx, p.dy);
    }

    fill
      ..lineTo(size.width, size.height)
      ..close();

    canvas
      ..drawPath(fill, Paint()..color = color.withValues(alpha: 0.10))
      ..drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

    final Offset last = pointAt(values.length - 1);
    canvas
      ..drawCircle(last, 3.2, Paint()..color = AppColors.surface)
      ..drawCircle(
        last,
        3.2,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
