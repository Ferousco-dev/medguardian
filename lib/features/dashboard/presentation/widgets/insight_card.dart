import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_insight.dart';
import '../../../../shared/widgets/entrance.dart';
import '../../../../shared/widgets/status_pill.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight, this.onTap});

  final HealthInsight insight;
  final VoidCallback? onTap;

  StatusTone get _tone => switch (insight.severity) {
    InsightSeverity.positive => StatusTone.positive,
    InsightSeverity.informational => StatusTone.info,
    InsightSeverity.watch => StatusTone.caution,
    InsightSeverity.urgent => StatusTone.critical,
  };

  String get _toneLabel => switch (insight.severity) {
    InsightSeverity.positive => 'Going well',
    InsightSeverity.informational => 'For your info',
    InsightSeverity.watch => 'Worth watching',
    InsightSeverity.urgent => 'Needs attention',
  };

  IconData get _icon => switch (insight.severity) {
    InsightSeverity.positive => Icons.check_circle_outline_rounded,
    InsightSeverity.informational => Icons.info_outline_rounded,
    InsightSeverity.watch => Icons.trending_up_rounded,
    InsightSeverity.urgent => Icons.priority_high_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(width: 4, color: _tone.foreground),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              color: _tone.background,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              _icon,
                              size: 15,
                              color: _tone.foreground,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _toneLabel,
                            style: text.labelMedium?.copyWith(
                              color: _tone.foreground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(insight.title, style: text.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(insight.body, style: text.bodyMedium),
                      if (insight.recommendation != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  insight.recommendation!,
                                  style: text.titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
