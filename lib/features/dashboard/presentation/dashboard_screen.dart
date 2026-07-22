import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/biomarker.dart';
import '../../../data/models/digital_twin.dart';
import '../../../data/models/health_insight.dart';
import '../../../data/models/risk_score.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/metric_tile.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../data/demo/demo_guides.dart';
import '../../../data/models/health_guide.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../guides/presentation/widgets/guide_card.dart';
import '../../shell/application/shell_tab.dart';
import '../../twin/domain/twin_completion.dart';
import '../../twin/presentation/widgets/completion_card.dart';
import 'widgets/insight_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/risk_score_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const List<String> _pinnedBiomarkers = <String>[
    'blood_pressure_systolic',
    'blood_glucose',
    'bmi',
    'resting_heart_rate',
  ];

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(twinProvider)
      ..invalidate(riskScoreProvider)
      ..invalidate(biomarkersProvider)
      ..invalidate(insightsProvider);

    await Future.wait(<Future<Object?>>[
      ref.read(twinProvider.future),
      ref.read(riskScoreProvider.future),
      ref.read(biomarkersProvider.future),
      ref.read(insightsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DigitalTwin> twin = ref.watch(twinProvider);
    final AsyncValue<RiskScore> risk = ref.watch(riskScoreProvider);
    final AsyncValue<List<Biomarker>> biomarkers = ref.watch(
      biomarkersProvider,
    );
    final AsyncValue<List<HealthInsight>> insights = ref.watch(
      insightsProvider,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.huge,
            ),
            children: <Widget>[
              _Greeting(twin: twin),
              if (twin.valueOrNull != null) ...<Widget>[
                Builder(
                  builder: (BuildContext context) {
                    final TwinCompletion completion = TwinCompletion.of(
                      twin.value!,
                    );
                    if (completion.isComplete) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl),
                      child: _CompletionNudge(completion: completion),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              AsyncView<RiskScore>(
                value: risk,
                onRetry: () => ref.invalidate(riskScoreProvider),
                loading: const Skeleton(height: 190),
                data: (RiskScore value) => RiskScoreCard(
                  score: value,
                  onTap: () => context.push(Routes.riskScore),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const QuickActions(),
              const SizedBox(height: AppSpacing.xxxl),
              SectionHeading(
                title: 'Your vitals',
                actionLabel: 'See all',
                onAction: () => ref
                    .read(shellTabProvider.notifier)
                    .select(ShellTab.biomarkers),
              ),
              AsyncView<List<Biomarker>>(
                value: biomarkers,
                onRetry: () => ref.invalidate(biomarkersProvider),
                loading: const SkeletonGrid(),
                data: (List<Biomarker> value) => _VitalsGrid(
                  onTapTile: () => ref
                      .read(shellTabProvider.notifier)
                      .select(ShellTab.biomarkers),
                  biomarkers: value
                      .where(
                        (Biomarker b) => _pinnedBiomarkers.contains(b.code),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SectionHeading(
                title: 'What your twin noticed',
                actionLabel: 'Simulate',
                onAction: () => context.push(Routes.simulation),
              ),
              AsyncView<List<HealthInsight>>(
                value: insights,
                onRetry: () => ref.invalidate(insightsProvider),
                loading: const Skeleton(height: 160),
                data: (List<HealthInsight> value) {
                  if (value.isEmpty) {
                    return const EmptyState(
                      icon: Icons.insights_outlined,
                      title: 'No insights yet',
                      body:
                          'Log a few readings and your twin will start finding '
                          'patterns.',
                    );
                  }
                  return Column(
                    children: <Widget>[
                      for (int i = 0; i < value.length; i++) ...<Widget>[
                        if (i > 0) const SizedBox(height: AppSpacing.md),
                        InsightCard(insight: value[i]),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SectionHeading(
                title: 'Worth reading',
                actionLabel: 'Library',
                onAction: () => context.push(Routes.guides),
              ),
              const _GuideCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.twin});

  final AsyncValue<DigitalTwin> twin;

  String get _timeOfDay {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String firstName =
        twin.valueOrNull?.fullName.split(' ').first ?? 'there';

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_timeOfDay, style: text.bodyMedium),
              const SizedBox(height: 2),
              Text(firstName, style: text.headlineSmall),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(Routes.emergency),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.dangerTint,
            foregroundColor: AppColors.danger,
          ),
          icon: const Icon(Icons.emergency_outlined, size: 20),
        ),
      ],
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  const _VitalsGrid({required this.biomarkers, required this.onTapTile});

  final List<Biomarker> biomarkers;
  final VoidCallback onTapTile;

  @override
  Widget build(BuildContext context) {
    if (biomarkers.isEmpty) {
      return const EmptyState(
        icon: Icons.monitor_heart_outlined,
        title: 'No readings yet',
        body: 'Log your first reading to start a trend.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: biomarkers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        mainAxisExtent: 158,
      ),
      itemBuilder: (BuildContext context, int index) {
        final Biomarker biomarker = biomarkers[index];
        return MetricTile(
          label: biomarker.name,
          value: _format(biomarker.latest?.value),
          unit: biomarker.unit,
          deltaLabel: _deltaLabel(biomarker),
          deltaTone: _tone(biomarker),
          sparkline: biomarker.readings
              .map((BiomarkerReading r) => r.value)
              .toList(growable: false),
          onTap: onTapTile,
        );
      },
    );
  }

  static String _format(double? value) {
    if (value == null) {
      return '--';
    }
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  static String? _deltaLabel(Biomarker biomarker) {
    final double? delta = biomarker.delta;
    if (delta == null || delta == 0) {
      return biomarker.isOutOfRange ? 'Out of range' : 'Stable';
    }
    final String sign = delta > 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(delta.abs() < 1 ? 1 : 0)}';
  }

  static StatusTone _tone(Biomarker biomarker) {
    if (biomarker.isOutOfRange) {
      return StatusTone.critical;
    }
    return switch (biomarker.trend) {
      BiomarkerTrend.improving => StatusTone.positive,
      BiomarkerTrend.stable => StatusTone.neutral,
      BiomarkerTrend.worsening => StatusTone.caution,
    };
  }
}

class _GuideCarousel extends StatelessWidget {
  const _GuideCarousel();

  @override
  Widget build(BuildContext context) {
    final List<HealthGuide> guides = DemoGuides.all
        .take(4)
        .toList(growable: false);

    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemCount: guides.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) => GuideCard(
          guide: guides[index],
          onTap: () => context.push('${Routes.guides}/${guides[index].id}'),
        ),
      ),
    );
  }
}

class _CompletionNudge extends StatelessWidget {
  const _CompletionNudge({required this.completion});

  final TwinCompletion completion;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SectionCard(
      onTap: () => context.push(Routes.healthSetupEdit),
      color: AppColors.primaryTint,
      borderColor: AppColors.primaryTint,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          CompletionRing(fraction: completion.fraction, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Finish setting up your twin', style: text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Add your ${completion.next!.label.toLowerCase()} to sharpen '
                  'your score',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
