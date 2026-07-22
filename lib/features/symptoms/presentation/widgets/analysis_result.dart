import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/symptom_analysis.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/section_heading.dart';
import '../../../../shared/widgets/status_pill.dart';

class AnalysisResult extends StatelessWidget {
  const AnalysisResult({
    super.key,
    required this.analysis,
    required this.onReset,
    this.onEmergency,
  });

  final SymptomAnalysis analysis;
  final VoidCallback onReset;
  final VoidCallback? onEmergency;

  StatusTone get _tone => switch (analysis.urgency) {
    UrgencyLevel.selfCare => StatusTone.positive,
    UrgencyLevel.routine => StatusTone.info,
    UrgencyLevel.urgent => StatusTone.caution,
    UrgencyLevel.emergency => StatusTone.critical,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.huge,
      ),
      children: <Widget>[
        SectionCard(
          color: _tone.background,
          borderColor: _tone.background,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    analysis.isEmergency
                        ? Icons.emergency_rounded
                        : Icons.assignment_turned_in_outlined,
                    size: 20,
                    color: _tone.foreground,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    analysis.urgency.label,
                    style: text.titleMedium?.copyWith(color: _tone.foreground),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(analysis.summary, style: text.bodyLarge),
              if (analysis.isEmergency && onEmergency != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: onEmergency,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  ),
                  child: const Text('Open emergency card'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeading(title: 'Recorded on your twin'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: analysis.extractedSymptoms
              .map((String s) => StatusPill(label: s, tone: StatusTone.info))
              .toList(growable: false),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeading(title: 'What this could be'),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < analysis.possibleConditions.length; i++) ...[
                if (i > 0) const Divider(),
                _ConditionRow(condition: analysis.possibleConditions[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'These are possibilities based on your twin, not a diagnosis. Only a '
          'clinician can diagnose you.',
          style: text.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeading(title: 'What to do next'),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < analysis.nextSteps.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 22,
                      width: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: AppTypography.numeric(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(analysis.nextSteps[i], style: text.bodyLarge),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (analysis.followUpQuestions.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeading(title: 'Questions that would sharpen this'),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (
                  int i = 0;
                  i < analysis.followUpQuestions.length;
                  i++
                ) ...<Widget>[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          analysis.followUpQuestions[i],
                          style: text.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        OutlinedButton(
          onPressed: onReset,
          child: const Text('Report something else'),
        ),
      ],
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({required this.condition});

  final PossibleCondition condition;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(condition.name, style: text.titleSmall)),
              Text(
                '${condition.likelihoodPercent}%',
                style: AppTypography.numeric(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: condition.likelihood.clamp(0, 1),
              minHeight: 5,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          if (condition.description != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(condition.description!, style: text.bodyMedium),
          ],
          if (condition.clinicalCode != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            StatusPill(label: condition.clinicalCode!),
          ],
        ],
      ),
    );
  }
}
