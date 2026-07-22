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
import '../../auth/domain/validators.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();

  DateTime? _dateOfBirth;
  BiologicalSex _sex = BiologicalSex.undisclosed;
  bool _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Date of birth',
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Add your date of birth to continue.')),
        );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(twinRepositoryProvider)
          .createTwin(
            DigitalTwin(
              id: '',
              did: '',
              fullName: _name.text.trim(),
              dateOfBirth: _dateOfBirth!,
              sex: _sex,
              heightCm: double.parse(_height.text.trim()),
              weightKg: double.parse(_weight.text.trim()),
            ),
          );

      ref.invalidate(twinProvider);

      if (mounted) {
        context.go(Routes.dashboard);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Create your twin')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
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
                    Text(
                      'A few details to start with',
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your twin needs a baseline. Everything else builds up '
                      'as you use the app.',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      label: 'Full name',
                      controller: _name,
                      hintText: 'Ada Okoro',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Date of birth', style: text.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
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
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Sex at birth', style: text.labelMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: BiologicalSex.values
                          .map(
                            (BiologicalSex sex) => ChoiceChip(
                              label: Text(sex.label),
                              selected: _sex == sex,
                              onSelected: (_) => setState(() => _sex = sex),
                              backgroundColor: AppColors.surface,
                              selectedColor: AppColors.primaryTint,
                              labelStyle: text.labelMedium?.copyWith(
                                color: _sex == sex
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              side: BorderSide(
                                color: _sex == sex
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AppTextField(
                            label: 'Height in cm',
                            controller: _height,
                            hintText: '168',
                            keyboardType: TextInputType.number,
                            validator: (String? value) =>
                                _positiveNumber(value, 'height'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            label: 'Weight in kg',
                            controller: _weight,
                            hintText: '65',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (String? value) =>
                                _positiveNumber(value, 'weight'),
                          ),
                        ),
                      ],
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
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text('Create my twin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _positiveNumber(String? value, String field) {
    final double? parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return 'Enter your $field';
    }
    if (parsed <= 0) {
      return 'Enter a valid $field';
    }
    return null;
  }
}
