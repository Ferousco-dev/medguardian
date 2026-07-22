import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/biomarker.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_pill.dart';
import 'widgets/biomarker_chart.dart';
import 'widgets/log_reading_sheet.dart';

class BiomarkersScreen extends ConsumerWidget {
  const BiomarkersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Biomarker>> biomarkers = ref.watch(
      biomarkersProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Biomarkers')),
      body: SafeArea(
        top: false,
        child: AsyncView<List<Biomarker>>(
          value: biomarkers,
          onRetry: () => ref.invalidate(biomarkersProvider),
          data: (List<Biomarker> value) {
            if (value.isEmpty) {
              return const EmptyState(
                icon: Icons.monitor_heart_outlined,
                title: 'No biomarkers tracked',
                body: 'Log your first reading to start building a trend.',
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(biomarkersProvider);
                await ref.read(biomarkersProvider.future);
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.page,
                  AppSpacing.huge,
                ),
                itemCount: value.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.lg),
                itemBuilder: (BuildContext context, int index) =>
                    BiomarkerCard(biomarker: value[index]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LogReadingSheet.show(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Log reading'),
      ),
    );
  }
}

class BiomarkerCard extends StatelessWidget {
  const BiomarkerCard({super.key, required this.biomarker});

  final Biomarker biomarker;

  StatusTone get _tone {
    if (biomarker.isOutOfRange) {
      return StatusTone.critical;
    }
    return switch (biomarker.trend) {
      BiomarkerTrend.improving => StatusTone.positive,
      BiomarkerTrend.stable => StatusTone.neutral,
      BiomarkerTrend.worsening => StatusTone.caution,
    };
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final BiomarkerReading? latest = biomarker.latest;
    final double? delta = biomarker.delta;

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(biomarker.name, style: text.titleMedium),
                    if (biomarker.loincCode.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        'LOINC ${biomarker.loincCode}',
                        style: text.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              StatusPill(
                label: biomarker.isOutOfRange
                    ? 'Out of range'
                    : biomarker.trend.label,
                tone: _tone,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                latest == null ? '--' : _format(latest.value),
                style: AppTypography.numeric(fontSize: 34),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(biomarker.unit, style: text.bodyMedium),
              const Spacer(),
              if (delta != null && delta != 0)
                Text(
                  '${delta > 0 ? '+' : ''}${_format(delta)} since last',
                  style: text.bodySmall,
                ),
            ],
          ),
          if (latest != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Last recorded ${DateFormat('d MMM yyyy').format(latest.recordedAt)}',
              style: text.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          BiomarkerChart(biomarker: biomarker),
          if (biomarker.referenceLow != null ||
              biomarker.referenceHigh != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Reference range '
              '${_format(biomarker.referenceLow)} to '
              '${_format(biomarker.referenceHigh)} ${biomarker.unit}, '
              'from HOLON for your age and sex',
              style: text.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  static String _format(double? value) {
    if (value == null) {
      return '--';
    }
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }
}
