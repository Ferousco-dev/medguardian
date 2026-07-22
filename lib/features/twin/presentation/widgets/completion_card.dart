import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../domain/twin_completion.dart';

class CompletionCard extends StatelessWidget {
  const CompletionCard({
    super.key,
    required this.completion,
    required this.onComplete,
  });

  final TwinCompletion completion;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    if (completion.isComplete) {
      return SectionCard(
        color: AppColors.successTint,
        borderColor: AppColors.successTint,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.verified_outlined,
              size: 20,
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Your twin is complete. Every feature has what it needs.',
                style: text.titleSmall?.copyWith(color: AppColors.success),
              ),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CompletionRing(fraction: completion.fraction),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(completion.headline, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${completion.completed} of 9 details added',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Text('Still missing', style: text.labelMedium),
          const SizedBox(height: AppSpacing.md),
          for (final CompletionStep step in completion.missing.take(3)) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(step.label, style: text.titleSmall),
                        Text(step.why, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (completion.missing.length > 3)
            Padding(
              padding: const EdgeInsets.only(left: 28, bottom: AppSpacing.md),
              child: Text(
                'and ${completion.missing.length - 3} more',
                style: text.bodySmall,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: onComplete,
            child: const Text('Complete my twin'),
          ),
        ],
      ),
    );
  }
}

class CompletionRing extends StatelessWidget {
  const CompletionRing({super.key, required this.fraction, this.size = 52});

  final double fraction;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: fraction.clamp(0, 1),
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Text(
            '${(fraction * 100).round()}',
            style: AppTypography.numeric(
              fontSize: size * 0.3,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
