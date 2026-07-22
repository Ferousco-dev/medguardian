import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/biomarker.dart';
import '../../../data/models/clinical_summary.dart';
import '../../../data/models/health_event.dart';
import '../../../data/models/medication.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/status_pill.dart';
import '../application/summary_controller.dart';
import 'widgets/share_access_sheet.dart';

class ClinicalSummaryScreen extends ConsumerWidget {
  const ClinicalSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ClinicalSummary?> state = ref.watch(
      summaryControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Clinical summary')),
      body: SafeArea(
        top: false,
        child: switch (state) {
          AsyncLoading<ClinicalSummary?>() => const _GeneratingState(),
          AsyncError<ClinicalSummary?>(:final Object error) => ErrorState(
            error: error,
            onRetry: () =>
                ref.read(summaryControllerProvider.notifier).generate(),
          ),
          AsyncData<ClinicalSummary?>(value: final ClinicalSummary summary) =>
            _SummaryView(summary: summary),
          _ => _IntroState(
            onGenerate: () =>
                ref.read(summaryControllerProvider.notifier).generate(),
          ),
        },
      ),
    );
  }
}

class _IntroState extends StatelessWidget {
  const _IntroState({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xxl,
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
                  Icons.description_outlined,
                  size: 25,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Give your doctor the whole picture',
                style: text.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'MedGuardian turns everything on your twin into a summary a '
                'clinician can read in under a minute.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    _IncludedRow(
                      icon: Icons.assignment_outlined,
                      label: 'Active problems and history',
                    ),
                    Divider(height: AppSpacing.xxl),
                    _IncludedRow(
                      icon: Icons.monitor_heart_outlined,
                      label: 'Biomarker trends with reference ranges',
                    ),
                    Divider(height: AppSpacing.xxl),
                    _IncludedRow(
                      icon: Icons.medication_outlined,
                      label: 'Current medications and allergies',
                    ),
                    Divider(height: AppSpacing.xxl),
                    _IncludedRow(
                      icon: Icons.visibility_off_outlined,
                      label: 'Private entries stay hidden',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          child: FilledButton(
            onPressed: onGenerate,
            child: const Text('Generate summary'),
          ),
        ),
      ],
    );
  }
}

class _IncludedRow extends StatelessWidget {
  const _IncludedRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _SummaryView extends ConsumerWidget {
  const _SummaryView({required this.summary});

  final ClinicalSummary summary;

  Future<void> _exportFhir(BuildContext context, WidgetRef ref) async {
    final Map<String, dynamic> bundle = await ref
        .read(careRepositoryProvider)
        .exportFhir();

    await Clipboard.setData(
      ClipboardData(text: const JsonEncoder.withIndent('  ').convert(bundle)),
    );

    if (context.mounted) {
      AppSnack.show(context, 'FHIR bundle copied to your clipboard');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              SectionCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.verified_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'MEDGUARDIAN CLINICAL SUMMARY',
                          style: text.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(summary.patientName, style: text.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      '${summary.patientAge} years old, generated '
                      '${DateFormat('d MMM yyyy, HH:mm').format(summary.generatedAt)}',
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(summary.overview, style: text.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeading(title: 'Active problems'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: summary.activeProblems
                    .map(
                      (String p) =>
                          StatusPill(label: p, tone: StatusTone.caution),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeading(title: 'Biomarkers'),
              SectionCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < summary.biomarkers.length; i++) ...[
                      if (i > 0) const Divider(),
                      _BiomarkerRow(biomarker: summary.biomarkers[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeading(title: 'Current medications'),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: summary.medications
                      .map(
                        (Medication m) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            '${m.name} ${m.dosage ?? ''}, ${m.frequency ?? ''}'
                                .trim(),
                            style: text.bodyLarge,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeading(title: 'Recent events'),
              SectionCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < summary.recentEvents.length; i++) ...[
                      if (i > 0) const Divider(),
                      _EventRow(event: summary.recentEvents[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeading(title: 'Suggested next steps'),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (
                      int i = 0;
                      i < summary.recommendations.length;
                      i++
                    ) ...<Widget>[
                      if (i > 0) const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${i + 1}.',
                            style: AppTypography.numeric(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              summary.recommendations[i],
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
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _exportFhir(context, ref),
                  child: const Text('Export FHIR'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () => ShareAccessSheet.show(context),
                  child: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BiomarkerRow extends StatelessWidget {
  const _BiomarkerRow({required this.biomarker});

  final Biomarker biomarker;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final BiomarkerReading? latest = biomarker.latest;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(biomarker.name, style: text.bodyLarge)),
          Text(
            '${latest?.value.toStringAsFixed(1) ?? '--'} ${biomarker.unit}',
            style: AppTypography.numeric(fontSize: 14),
          ),
          const SizedBox(width: AppSpacing.md),
          StatusPill(
            label: biomarker.isOutOfRange ? 'High' : 'Normal',
            tone: biomarker.isOutOfRange
                ? StatusTone.critical
                : StatusTone.positive,
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final HealthEvent event;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(event.title, style: text.bodyLarge),
                const SizedBox(height: 2),
                Text(event.type.label, style: text.bodySmall),
              ],
            ),
          ),
          Text(
            DateFormat('d MMM').format(event.occurredAt),
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _GeneratingState extends StatelessWidget {
  const _GeneratingState();

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
          Text('Compiling your record', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text('Private entries are excluded', style: text.bodyMedium),
        ],
      ),
    );
  }
}
