import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/digital_twin.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/section_card.dart';
import 'widgets/tag_editor.dart';

class HealthSetupScreen extends ConsumerStatefulWidget {
  const HealthSetupScreen({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  ConsumerState<HealthSetupScreen> createState() => _HealthSetupScreenState();
}

class _HealthSetupScreenState extends ConsumerState<HealthSetupScreen> {
  final PageController _pages = PageController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();

  int _step = 0;
  DateTime? _dateOfBirth;
  BiologicalSex _sex = BiologicalSex.undisclosed;
  String? _bloodType;
  List<String> _conditions = <String>[];
  List<String> _allergies = <String>[];
  List<String> _familyHistory = <String>[];
  bool _isSaving = false;
  bool _prefilled = false;

  static const int _stepCount = 3;
  static const List<String> _bloodTypes = <String>[
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _pages.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _prefill(DigitalTwin twin) {
    if (_prefilled) {
      return;
    }
    _prefilled = true;
    _dateOfBirth = twin.dateOfBirth;
    _sex = twin.sex;
    _bloodType = twin.bloodType;
    _conditions = List<String>.of(twin.conditions);
    _allergies = List<String>.of(twin.allergies);
    _familyHistory = List<String>.of(twin.familyHistory);
    if (twin.heightCm != null) {
      _height.text = twin.heightCm!.toStringAsFixed(0);
    }
    if (twin.weightKg != null) {
      _weight.text = twin.weightKg!.toStringAsFixed(1);
    }
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 28, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Date of birth',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _next() {
    if (_step == _stepCount - 1) {
      _save();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _leave() {
    if (widget.isEditing) {
      context.pop();
    } else {
      context.go(Routes.dashboard);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final DigitalTwin existing =
          ref.read(twinProvider).valueOrNull ??
          const DigitalTwin(id: '', did: '', fullName: '');

      await ref
          .read(twinRepositoryProvider)
          .updateTwin(
            existing.copyWith(
              dateOfBirth: _dateOfBirth,
              sex: _sex,
              heightCm: double.tryParse(_height.text.trim()),
              weightKg: double.tryParse(_weight.text.trim()),
              bloodType: _bloodType,
              conditions: _conditions,
              allergies: _allergies,
              familyHistory: _familyHistory,
            ),
          );

      ref
        ..invalidate(twinProvider)
        ..invalidate(riskScoreProvider)
        ..invalidate(insightsProvider);

      if (mounted) {
        _leave();
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

    ref.listen(twinProvider, (_, AsyncValue<DigitalTwin> next) {
      final DigitalTwin? twin = next.valueOrNull;
      if (twin != null && mounted) {
        setState(() => _prefill(twin));
      }
    });

    final DigitalTwin? twin = ref.watch(twinProvider).valueOrNull;
    if (twin != null) {
      _prefill(twin);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _step == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => _pages.previousPage(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                ),
              ),
        title: Text(
          widget.isEditing ? 'Edit health details' : 'Health details',
        ),
        actions: <Widget>[
          if (!widget.isEditing)
            TextButton(onPressed: _leave, child: const Text('Skip for now')),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: List<Widget>.generate(_stepCount, (int index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index == _stepCount - 1 ? 0 : AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _step
                            ? AppColors.primary
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (int index) => setState(() => _step = index),
                children: <Widget>[
                  _StepBody(
                    title: 'The basics',
                    body:
                        'Age and sex change how your biomarkers are read. '
                        'Everything here is optional.',
                    children: <Widget>[
                      Text('Date of birth', style: text.labelMedium),
                      const SizedBox(height: AppSpacing.sm),
                      _FieldShell(
                        onTap: _pickDate,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                _dateOfBirth == null
                                    ? 'Select a date'
                                    : DateFormat(
                                        'd MMMM yyyy',
                                      ).format(_dateOfBirth!),
                                style: _dateOfBirth == null
                                    ? text.bodyMedium
                                    : text.bodyLarge,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Sex at birth', style: text.labelMedium),
                      const SizedBox(height: AppSpacing.sm),
                      _ChipRow<BiologicalSex>(
                        options: BiologicalSex.values,
                        selected: _sex,
                        labelOf: (BiologicalSex s) => s.label,
                        onSelected: (BiologicalSex s) =>
                            setState(() => _sex = s),
                      ),
                    ],
                  ),
                  _StepBody(
                    title: 'Your body',
                    body:
                        'Height and weight give your twin a BMI to track, '
                        'which feeds directly into your risk score.',
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AppTextField(
                              label: 'Height in cm',
                              controller: _height,
                              hintText: '168',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              label: 'Weight in kg',
                              controller: _weight,
                              hintText: '65',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Blood type', style: text.labelMedium),
                      const SizedBox(height: AppSpacing.sm),
                      _ChipRow<String>(
                        options: _bloodTypes,
                        selected: _bloodType,
                        labelOf: (String s) => s,
                        onSelected: (String s) => setState(
                          () => _bloodType = _bloodType == s ? null : s,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Shown on your emergency card.',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                  _StepBody(
                    title: 'Your history',
                    body:
                        'This is what lets MedGuardian read a symptom in '
                        'context instead of in isolation.',
                    children: <Widget>[
                      TagEditor(
                        label: 'Existing conditions',
                        hintText: 'Asthma',
                        values: _conditions,
                        suggestions: const <String>[
                          'Asthma',
                          'Hypertension',
                          'Type 2 diabetes',
                          'Prediabetes',
                          'Sickle cell',
                        ],
                        onChanged: (List<String> v) =>
                            setState(() => _conditions = v),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TagEditor(
                        label: 'Allergies',
                        hintText: 'Penicillin',
                        values: _allergies,
                        suggestions: const <String>[
                          'Penicillin',
                          'Peanuts',
                          'Sulfa drugs',
                          'Latex',
                          'Shellfish',
                        ],
                        onChanged: (List<String> v) =>
                            setState(() => _allergies = v),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TagEditor(
                        label: 'Family history',
                        hintText: 'Hypertension (father)',
                        values: _familyHistory,
                        suggestions: const <String>[
                          'Type 2 diabetes',
                          'Hypertension',
                          'Heart disease',
                          'Stroke',
                        ],
                        onChanged: (List<String> v) =>
                            setState(() => _familyHistory = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                AppSpacing.xxl,
              ),
              child: FilledButton(
                onPressed: _isSaving ? null : _next,
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        _step == _stepCount - 1
                            ? 'Save and finish'
                            : 'Continue',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        Text(title, style: text.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(body, style: text.bodyMedium),
        const SizedBox(height: AppSpacing.xxl),
        ...children,
      ],
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      radius: AppRadius.md,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options
          .map((T option) {
            final bool isSelected = option == selected;
            return ChoiceChip(
              label: Text(labelOf(option)),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryTint,
              showCheckmark: false,
              labelStyle: text.labelMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
