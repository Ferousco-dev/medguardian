import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/risk_score.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/status_pill.dart';

class RiskScoreScreen extends ConsumerWidget {
  const RiskScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RiskScore> score = ref.watch(riskScoreProvider);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Health risk score')),
      body: SafeArea(
        top: false,
        child: AsyncView<RiskScore>(
          value: score,
          onRetry: () => ref.invalidate(riskScoreProvider),
          data: (RiskScore value) {
            final List<RiskFactor> raising = value.factors
                .where((RiskFactor f) => f.direction == RiskDirection.raises)
                .toList(growable: false);
            final List<RiskFactor> lowering = value.factors
                .where((RiskFactor f) => f.direction == RiskDirection.lowers)
                .toList(growable: false);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.huge,
              ),
              children: <Widget>[
                EntranceFade(index: 0, child: _ScoreHero(score: value)),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeading(title: 'Raising your risk'),
                _FactorList(factors: raising, tone: StatusTone.critical),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeading(title: 'Working in your favour'),
                _FactorList(factors: lowering, tone: StatusTone.positive),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Last calculated '
                  '${DateFormat('d MMM yyyy').format(value.calculatedAt)}',
                  style: text.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton.icon(
                  onPressed: () => context.push(Routes.simulation),
                  icon: const Icon(Icons.query_stats_rounded, size: 18),
                  label: const Text('See where this leads'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.score});

  final RiskScore score;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int? delta = score.delta;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
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
        children: <Widget>[
          AnimatedCounter(
            value: score.score,
            style: AppTypography.numeric(
              fontSize: 76,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'out of 100',
            style: text.bodyMedium?.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              score.band.label,
              style: text.labelMedium?.copyWith(color: AppColors.onPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: (score.score / 100).clamp(0, 1),
              ),
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
          ),
          if (delta != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              delta >= 0
                  ? 'Up $delta points since last month'
                  : 'Down ${delta.abs()} points since last month',
              style: text.bodyMedium?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FactorList extends StatelessWidget {
  const _FactorList({required this.factors, required this.tone});

  final List<RiskFactor> factors;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    if (factors.isEmpty) {
      return SectionCard(
        child: Text(
          'Nothing recorded here.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < factors.length; i++) ...<Widget>[
            if (i > 0) const Divider(),
            _FactorRow(factor: factors[i], tone: tone),
          ],
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor, required this.tone});

  final RiskFactor factor;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: tone.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(
              factor.direction == RiskDirection.raises
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
              color: tone.foreground,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(factor.label, style: text.titleSmall),
                if (factor.detail != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(factor.detail!, style: text.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${factor.direction == RiskDirection.raises ? '+' : '-'}${factor.impact}',
            style: AppTypography.numeric(fontSize: 15, color: tone.foreground),
          ),
        ],
      ),
    );
  }
}
