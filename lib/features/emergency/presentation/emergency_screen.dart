import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/digital_twin.dart';
import '../../../data/models/medication.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_pill.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DigitalTwin> twin = ref.watch(twinProvider);
    final AsyncValue<List<Medication>> medications = ref.watch(
      medicationsProvider,
    );
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency card')),
      body: SafeArea(
        top: false,
        child: AsyncView<DigitalTwin>(
          value: twin,
          onRetry: () => ref.invalidate(twinProvider),
          data: (DigitalTwin value) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.huge,
            ),
            children: <Widget>[
              SectionCard(
                color: AppColors.dangerTint,
                borderColor: AppColors.dangerTint,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.emergency_rounded,
                      color: AppColors.danger,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Show this screen to a first responder.',
                        style: text.titleSmall?.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(value.fullName, style: text.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${value.age} years, ${value.sex.label.toLowerCase()}'
                      '${value.bloodType != null ? ', blood type ${value.bloodType}' : ''}',
                      style: text.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),
                    _Block(
                      title: 'Allergies',
                      items: value.allergies,
                      tone: StatusTone.critical,
                      emptyLabel: 'None recorded',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Block(
                      title: 'Conditions',
                      items: value.conditions,
                      tone: StatusTone.caution,
                      emptyLabel: 'None recorded',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Current medications', style: text.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    medications.when(
                      loading: () => Text('Loading', style: text.bodyMedium),
                      error: (_, _) =>
                          Text('Unavailable offline', style: text.bodyMedium),
                      data: (List<Medication> meds) {
                        final List<Medication> active = meds
                            .where((Medication m) => m.isActive)
                            .toList(growable: false);
                        if (active.isEmpty) {
                          return Text('None recorded', style: text.bodyLarge);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: active
                              .map(
                                (Medication m) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    '${m.name} ${m.dosage ?? ''} ${m.frequency ?? ''}'
                                        .trim(),
                                    style: text.bodyLarge,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Twin identifier', style: text.labelMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value.did,
                      style: AppTypography.numeric(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton.icon(
                onPressed: () => context.push(Routes.hospitals),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                icon: const Icon(Icons.local_hospital_outlined, size: 18),
                label: const Text('Find nearest hospital'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    required this.items,
    required this.tone,
    required this.emptyLabel,
  });

  final String title;
  final List<String> items;
  final StatusTone tone;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: text.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        if (items.isEmpty)
          Text(emptyLabel, style: text.bodyLarge)
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: items
                .map((String item) => StatusPill(label: item, tone: tone))
                .toList(growable: false),
          ),
      ],
    );
  }
}
