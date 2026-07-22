import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/biomarker.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LogReadingSheet extends ConsumerStatefulWidget {
  const LogReadingSheet({super.key, required this.biomarkers});

  final List<Biomarker> biomarkers;

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final List<Biomarker> biomarkers =
        ref.read(biomarkersProvider).valueOrNull ?? const <Biomarker>[];

    if (biomarkers.isEmpty) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (BuildContext context) =>
          LogReadingSheet(biomarkers: biomarkers),
    );
  }

  @override
  ConsumerState<LogReadingSheet> createState() => _LogReadingSheetState();
}

class _LogReadingSheetState extends ConsumerState<LogReadingSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _value = TextEditingController();

  late Biomarker _selected = widget.biomarkers.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(twinRepositoryProvider)
          .recordReading(
            code: _selected.code,
            value: double.parse(_value.text.trim()),
          );

      ref
        ..invalidate(biomarkersProvider)
        ..invalidate(riskScoreProvider)
        ..invalidate(insightsProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        right: AppSpacing.page,
        top: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Log a reading', style: text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'This becomes a health event and refreshes your score.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Biomarker', style: text.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<Biomarker>(
              initialValue: _selected,
              isExpanded: true,
              items: widget.biomarkers
                  .map(
                    (Biomarker b) => DropdownMenuItem<Biomarker>(
                      value: b,
                      child: Text(b.name, style: text.bodyLarge),
                    ),
                  )
                  .toList(),
              onChanged: (Biomarker? value) {
                if (value != null) {
                  setState(() => _selected = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Value in ${_selected.unit}',
              controller: _value,
              hintText: '0.0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              validator: (String? input) {
                final double? parsed = double.tryParse(input?.trim() ?? '');
                if (parsed == null) {
                  return 'Enter a number';
                }
                if (parsed <= 0) {
                  return 'Enter a value above zero';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Save reading'),
            ),
          ],
        ),
      ),
    );
  }
}
