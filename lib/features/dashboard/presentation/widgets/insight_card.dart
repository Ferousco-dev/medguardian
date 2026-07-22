import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_insight.dart';
import '../../../../shared/widgets/section_card.dart';
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
    InsightSeverity.positive => Icons.check_circle_outline,
    InsightSeverity.informational => Icons.info_outline,
    InsightSeverity.watch => Icons.trending_up_rounded,
    InsightSeverity.urgent => Icons.priority_high_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StatusPill(label: _toneLabel, tone: _tone, icon: _icon),
          const SizedBox(height: AppSpacing.md),
          Text(insight.title, style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(insight.body, style: text.bodyMedium),
          if (insight.recommendation != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _tone.foreground,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(insight.recommendation!, style: text.titleSmall),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
