import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/section_card.dart';

/// Onboarding illustrations.
///
/// Each one is a small, honest preview of a real screen in the app rather than
/// a stock drawing, so what the user sees on page one is what they get on the
/// dashboard.

class TwinPreviewVisual extends StatelessWidget {
  const TwinPreviewVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'AO',
                  style: AppTypography.numeric(
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Digital Twin',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'did:onto:8f2a',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              const _StatusDot(color: AppColors.success, label: 'Live'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Row(
            children: <Widget>[
              Expanded(child: _MetricTile(label: 'BMI', value: '22.4')),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _MetricTile(label: 'Resting HR', value: '68')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: <Widget>[
              Expanded(child: _MetricTile(label: 'BP', value: '118/76')),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _MetricTile(label: 'Glucose', value: '92')),
            ],
          ),
        ],
      ),
    );
  }
}

class TrendPreviewVisual extends StatelessWidget {
  const TrendPreviewVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        SectionCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Blood pressure', style: text.titleSmall),
                  Text('6 months', style: text.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 88,
                width: double.infinity,
                child: CustomPaint(
                  painter: _TrendLinePainter(
                    points: const <double>[0.34, 0.3, 0.42, 0.48, 0.62, 0.78],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          color: AppColors.warningTint,
          borderColor: AppColors.warningTint,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.trending_up_rounded,
                size: 20,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Rising over the last 3 readings',
                  style: text.titleSmall?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SharePreviewVisual extends StatelessWidget {
  const SharePreviewVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.description_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Clinical summary', style: text.titleSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SkeletonLine(widthFactor: 1),
          const SizedBox(height: AppSpacing.sm),
          const _SkeletonLine(widthFactor: 0.86),
          const SizedBox(height: AppSpacing.sm),
          const _SkeletonLine(widthFactor: 0.62),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              const _Chip(label: 'FHIR export'),
              const SizedBox(width: AppSpacing.sm),
              const _Chip(label: 'Access for 24h'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.numeric(fontSize: 18)),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: 9,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  const _TrendLinePainter({required this.points});

  /// Normalised 0 to 1 values, drawn left to right.
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final Paint grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final double y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final double step = size.width / (points.length - 1);
    final Path path = Path();

    for (int i = 0; i < points.length; i++) {
      final Offset point = Offset(
        step * i,
        size.height - (points[i] * size.height),
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
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Emphasise the most recent reading.
    final Offset last = Offset(
      size.width,
      size.height - (points.last * size.height),
    );
    canvas.drawCircle(last, 5, Paint()..color = AppColors.surface);
    canvas.drawCircle(
      last,
      5,
      Paint()
        ..color = AppColors.warning
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_TrendLinePainter oldDelegate) =>
      oldDelegate.points != points;
}
