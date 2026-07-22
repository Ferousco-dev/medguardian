import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/digital_twin.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/status_pill.dart';
import '../domain/twin_completion.dart';
import 'widgets/completion_card.dart';

class TwinProfileScreen extends ConsumerWidget {
  const TwinProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DigitalTwin> twin = ref.watch(twinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital twin'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
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
              EntranceFade(index: 0, child: _IdentityCard(twin: value)),
              const SizedBox(height: AppSpacing.lg),
              EntranceFade(
                index: 1,
                child: CompletionCard(
                  completion: TwinCompletion.of(value),
                  onComplete: () => context.push(Routes.healthSetupEdit),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SectionHeading(
                title: 'Body',
                actionLabel: 'Edit',
                onAction: () => context.push(Routes.healthSetupEdit),
              ),
              _BodyStats(twin: value),
              const SizedBox(height: AppSpacing.xxl),
              SectionHeading(
                title: 'Conditions',
                actionLabel: 'Edit',
                onAction: () => context.push(Routes.healthSetupEdit),
              ),
              _TagList(
                items: value.conditions,
                emptyLabel: 'No conditions recorded',
                tone: StatusTone.caution,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeading(title: 'Allergies'),
              _TagList(
                items: value.allergies,
                emptyLabel: 'No allergies recorded',
                tone: StatusTone.critical,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeading(title: 'Family history'),
              _TagList(
                items: value.familyHistory,
                emptyLabel: 'No family history recorded',
                tone: StatusTone.info,
              ),
              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton.icon(
                onPressed: () => context.push(Routes.clinicalSummary),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share with a doctor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.twin});

  final DigitalTwin twin;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(twin.fullName),
                  style: AppTypography.numeric(
                    fontSize: 20,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      twin.fullName,
                      style: text.titleLarge?.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(twin),
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Ontomorph identity',
                        style: text.labelSmall?.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        twin.did,
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy identifier',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: twin.did));
                    if (context.mounted) {
                      AppSnack.show(context, 'Twin identifier copied');
                    }
                  },
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppColors.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (twin.createdAt != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Twin created ${DateFormat('d MMMM yyyy').format(twin.createdAt!)}',
              style: text.bodySmall?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _subtitle(DigitalTwin twin) {
    final List<String> parts = <String>[
      if (twin.age != null) '${twin.age} years old',
      if (twin.sex != BiologicalSex.undisclosed) twin.sex.label.toLowerCase(),
    ];
    return parts.isEmpty
        ? 'Add your details to complete your twin'
        : parts.join(', ');
  }

  static String _initials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _BodyStats extends StatelessWidget {
  const _BodyStats({required this.twin});

  final DigitalTwin twin;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          _Row(
            label: 'Height',
            value: twin.heightCm == null
                ? 'Not set'
                : '${twin.heightCm!.toStringAsFixed(0)} cm',
          ),
          const Divider(),
          _Row(
            label: 'Weight',
            value: twin.weightKg == null
                ? 'Not set'
                : '${twin.weightKg!.toStringAsFixed(1)} kg',
          ),
          const Divider(),
          _Row(
            label: 'Body mass index',
            value: twin.bmi == null ? 'Not set' : twin.bmi!.toStringAsFixed(1),
            trailing: twin.bmi == null
                ? null
                : StatusPill(
                    label: _bmiLabel(twin.bmi!),
                    tone: _bmiTone(twin.bmi!),
                  ),
          ),
          const Divider(),
          _Row(label: 'Blood type', value: twin.bloodType ?? 'Not set'),
        ],
      ),
    );
  }

  static String _bmiLabel(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    }
    if (bmi < 25) {
      return 'Healthy';
    }
    if (bmi < 30) {
      return 'Overweight';
    }
    return 'Obese';
  }

  static StatusTone _bmiTone(double bmi) {
    if (bmi >= 18.5 && bmi < 25) {
      return StatusTone.positive;
    }
    if (bmi >= 30) {
      return StatusTone.critical;
    }
    return StatusTone.caution;
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: text.bodyMedium)),
          Text(value, style: text.titleSmall),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _TagList extends StatelessWidget {
  const _TagList({
    required this.items,
    required this.emptyLabel,
    required this.tone,
  });

  final List<String> items;
  final String emptyLabel;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SectionCard(
        child: Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items
          .map((String item) => StatusPill(label: item, tone: tone))
          .toList(growable: false),
    );
  }
}
