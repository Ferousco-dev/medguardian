import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/medication.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_pill.dart';

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Medication>> medications = ref.watch(
      medicationsProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: SafeArea(
        top: false,
        child: AsyncView<List<Medication>>(
          value: medications,
          onRetry: () => ref.invalidate(medicationsProvider),
          data: (List<Medication> value) {
            if (value.isEmpty) {
              return const EmptyState(
                icon: Icons.medication_outlined,
                title: 'No medications recorded',
                body:
                    'Medications you log will appear here with their uses, '
                    'side effects and interactions.',
              );
            }

            final List<Medication> active = value
                .where((Medication m) => m.isActive)
                .toList(growable: false);
            final List<Medication> past = value
                .where((Medication m) => !m.isActive)
                .toList(growable: false);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.huge,
              ),
              children: <Widget>[
                for (final Medication medication in active) ...<Widget>[
                  MedicationCard(medication: medication),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (past.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Past medications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final Medication medication in past) ...<Widget>[
                    MedicationCard(medication: medication),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  const MedicationCard({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

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
                    Text(medication.name, style: text.titleLarge),
                    if (medication.dosage != null ||
                        medication.frequency != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        <String?>[
                          medication.dosage,
                          medication.frequency,
                        ].whereType<String>().join(', '),
                        style: text.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              StatusPill(
                label: medication.isActive ? 'Active' : 'Stopped',
                tone: medication.isActive
                    ? StatusTone.positive
                    : StatusTone.neutral,
              ),
            ],
          ),
          if (medication.startedOn != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              medication.isActive
                  ? 'Started ${DateFormat('d MMM yyyy').format(medication.startedOn!)}'
                  : '${DateFormat('d MMM yyyy').format(medication.startedOn!)} to '
                        '${DateFormat('d MMM yyyy').format(medication.endedOn!)}',
              style: text.bodySmall,
            ),
          ],
          if (medication.warnings.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.dangerTint,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Warnings',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final String warning in medication.warnings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(warning, style: text.bodyMedium),
                    ),
                ],
              ),
            ),
          ],
          _Section(title: 'Used for', items: medication.uses),
          _Section(
            title: 'Possible side effects',
            items: medication.sideEffects,
          ),
          _Section(
            title: 'Interactions',
            items: medication.interactions,
            footnote: 'Checked against 1.7 million interactions in HOLON',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items, this.footnote});

  final String title;
  final List<String> items;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: text.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final String item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 4,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(item, style: text.bodyMedium)),
                ],
              ),
            ),
          if (footnote != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(footnote!, style: text.labelSmall),
          ],
        ],
      ),
    );
  }
}
