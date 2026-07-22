import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/health_simulation.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/status_pill.dart';
import '../application/simulation_controller.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  static const List<String> _questions = <String>[
    'What happens if I continue ignoring my blood pressure?',
    'What if I start walking 30 minutes a day?',
    'How does my glucose look in a year if nothing changes?',
    'What if I lose 5 kg over six months?',
  ];

  @override
  Widget build(BuildContext context) {
    final AsyncValue<HealthSimulation?> state = ref.watch(
      simulationControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health simulation'),
        actions: <Widget>[
          if (state.valueOrNull != null)
            TextButton(
              onPressed: () =>
                  ref.read(simulationControllerProvider.notifier).reset(),
              child: const Text('New'),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: switch (state) {
          AsyncLoading<HealthSimulation?>() => const _RunningState(),
          AsyncError<HealthSimulation?>(:final Object error) => ErrorState(
            error: error,
          ),
          AsyncData<HealthSimulation?>(
            value: final HealthSimulation simulation,
          ) =>
            _Result(simulation: simulation),
          _ => _QuestionPicker(
            questions: _questions,
            onSelected: (String question) =>
                ref.read(simulationControllerProvider.notifier).run(question),
          ),
        },
      ),
    );
  }
}

class _QuestionPicker extends StatelessWidget {
  const _QuestionPicker({required this.questions, required this.onSelected});

  final List<String> questions;
  final ValueChanged<String> onSelected;

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
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(
            Icons.query_stats_rounded,
            size: 25,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Project your health forward', style: text.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your twin runs your current trends forward in time so you can see '
          'where they lead before they get there.',
          style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Pick a question', style: text.labelMedium),
        const SizedBox(height: AppSpacing.md),
        for (final String question in questions) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SectionCard(
              onTap: () => onSelected(question),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(question, style: text.bodyLarge)),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.simulation});

  final HealthSimulation simulation;

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
        Text(simulation.question, style: text.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        StatusPill(
          label: simulation.scenario.label,
          tone: simulation.scenario == SimulationScenario.unchanged
              ? StatusTone.caution
              : StatusTone.positive,
        ),
        const SizedBox(height: AppSpacing.xxl),
        SectionCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Projected risk', style: text.titleSmall),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 120,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _ProjectionPainter(
                    values: simulation.horizons
                        .map((SimulationHorizon h) => h.riskLevel)
                        .toList(growable: false),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: simulation.horizons
                    .map(
                      (SimulationHorizon h) =>
                          Text(h.label, style: text.bodySmall),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SectionHeading(title: 'What each stage looks like'),
        for (int i = 0; i < simulation.horizons.length; i++)
          EntranceFade(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _HorizonCard(horizon: simulation.horizons[i]),
            ),
          ),
        if (simulation.preventiveActions.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          const SectionHeading(title: 'How to change this outcome'),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (
                  int i = 0;
                  i < simulation.preventiveActions.length;
                  i++
                ) ...<Widget>[
                  if (i > 0) const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          simulation.preventiveActions[i],
                          style: text.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'A projection is not a prediction. It shows where your current '
          'trends point if nothing else changes.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

class _HorizonCard extends StatelessWidget {
  const _HorizonCard({required this.horizon});

  final SimulationHorizon horizon;

  StatusTone get _tone {
    if (horizon.riskLevel >= 0.7) {
      return StatusTone.critical;
    }
    if (horizon.riskLevel >= 0.45) {
      return StatusTone.caution;
    }
    return StatusTone.info;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(horizon.label, style: text.titleSmall),
              const Spacer(),
              if (horizon.projectedValue != null)
                Text(
                  horizon.projectedValue!,
                  style: AppTypography.numeric(
                    fontSize: 15,
                    color: _tone.foreground,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(horizon.outcome, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: horizon.riskLevel.clamp(0, 1),
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(_tone.foreground),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${(horizon.riskLevel * 100).round()}%',
                style: text.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectionPainter extends CustomPainter {
  const _ProjectionPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final Paint grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final double step = size.width / (values.length - 1);
    final Path line = Path();
    final Path fill = Path()..moveTo(0, size.height);

    for (int i = 0; i < values.length; i++) {
      final Offset point = Offset(
        step * i,
        size.height - (values[i].clamp(0, 1) * size.height),
      );
      if (i == 0) {
        line.moveTo(point.dx, point.dy);
      } else {
        line.lineTo(point.dx, point.dy);
      }
      fill.lineTo(point.dx, point.dy);
    }

    fill
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(fill, Paint()..color = AppColors.dangerTint);
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.danger
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (int i = 0; i < values.length; i++) {
      final Offset point = Offset(
        step * i,
        size.height - (values[i].clamp(0, 1) * size.height),
      );
      canvas
        ..drawCircle(point, 4, Paint()..color = AppColors.surface)
        ..drawCircle(
          point,
          4,
          Paint()
            ..color = AppColors.danger
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  @override
  bool shouldRepaint(_ProjectionPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _RunningState extends StatelessWidget {
  const _RunningState();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox.square(
            dimension: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Running the projection', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text('Extending your trends forward', style: text.bodyMedium),
        ],
      ),
    );
  }
}
