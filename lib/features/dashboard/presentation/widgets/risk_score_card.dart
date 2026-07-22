import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/risk_score.dart';
import '../../../../shared/widgets/entrance.dart';
import '../../../../shared/widgets/status_pill.dart';

/// The one thing on the dashboard that is meant to catch the eye.
///
/// Solid brand teal rather than another white card, so the screen has a focal
/// point instead of an even grid of panels.
class RiskScoreCard extends StatelessWidget {
  const RiskScoreCard({super.key, required this.score, this.onTap});

  final RiskScore score;
  final VoidCallback? onTap;

  Color get _bandColor => switch (score.band) {
    RiskBand.low => AppColors.success,
    RiskBand.moderate => AppColors.warning,
    RiskBand.high => AppColors.danger,
    RiskBand.critical => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int? delta = score.delta;

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Health score',
                  style: text.titleSmall?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
                const Spacer(),
                _BandChip(label: score.band.label, dotColor: _bandColor),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                AnimatedCounter(
                  value: score.score,
                  style: AppTypography.numeric(
                    fontSize: 60,
                    color: AppColors.onPrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 3),
                  child: Text(
                    '/100',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
                const Spacer(),
                if (delta != null) _DeltaChip(delta: delta),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ScoreTrack(value: score.score / 100),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _headline(score),
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.onPrimary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _headline(RiskScore score) {
    final RiskFactor? top = score.factors
        .where((RiskFactor f) => f.direction == RiskDirection.raises)
        .fold<RiskFactor?>(
          null,
          (RiskFactor? best, RiskFactor f) =>
              best == null || f.impact > best.impact ? f : best,
        );

    if (top == null) {
      return 'Nothing is currently pulling your score down.';
    }
    return 'Biggest factor right now: ${top.label.toLowerCase()}.';
  }
}

class _BandChip extends StatelessWidget {
  const _BandChip({required this.label, required this.dotColor});

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 7,
            width: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final bool isUp = delta >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 13,
              color: AppColors.onPrimary,
            ),
            const SizedBox(width: 3),
            Text(
              '${delta.abs()} this month',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTrack extends StatelessWidget {
  const _ScoreTrack({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double current, _) {
          return LinearProgressIndicator(
            value: current,
            minHeight: 8,
            backgroundColor: AppColors.onPrimary.withValues(alpha: 0.22),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.onPrimary,
            ),
          );
        },
      ),
    );
  }
}

class ScoreBar extends StatelessWidget {
  const ScoreBar({super.key, required this.value, required this.tone});

  final double value;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double current, _) {
          return LinearProgressIndicator(
            value: current,
            minHeight: 8,
            backgroundColor: AppColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(tone.foreground),
          );
        },
      ),
    );
  }
}
