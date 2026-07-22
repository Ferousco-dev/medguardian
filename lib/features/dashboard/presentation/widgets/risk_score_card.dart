import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/risk_score.dart';
import '../../../../shared/widgets/entrance.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_pill.dart';

class RiskScoreCard extends StatelessWidget {
  const RiskScoreCard({super.key, required this.score, this.onTap});

  final RiskScore score;
  final VoidCallback? onTap;

  StatusTone get _tone => switch (score.band) {
    RiskBand.low => StatusTone.positive,
    RiskBand.moderate => StatusTone.caution,
    RiskBand.high => StatusTone.critical,
    RiskBand.critical => StatusTone.critical,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int? delta = score.delta;

    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Health score', style: text.titleSmall),
              StatusPill(label: score.band.label, tone: _tone),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              AnimatedCounter(
                value: score.score,
                style: AppTypography.numeric(fontSize: 52),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 2),
                child: Text('/100', style: text.bodyMedium),
              ),
              const Spacer(),
              if (delta != null)
                StatusPill(
                  label: '${delta > 0 ? '+' : ''}$delta since last month',
                  tone: delta >= 0 ? StatusTone.positive : StatusTone.caution,
                  icon: delta >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ScoreBar(value: score.score / 100, tone: _tone),
          const SizedBox(height: AppSpacing.lg),
          Text(_headline(score), style: text.bodyMedium),
        ],
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
