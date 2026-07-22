import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/symptom_analysis.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../application/symptom_controller.dart';
import 'widgets/analysis_result.dart';

class SymptomCheckScreen extends ConsumerStatefulWidget {
  const SymptomCheckScreen({super.key});

  @override
  ConsumerState<SymptomCheckScreen> createState() => _SymptomCheckScreenState();
}

class _SymptomCheckScreenState extends ConsumerState<SymptomCheckScreen> {
  final TextEditingController _controller = TextEditingController();

  static const List<String> _examples = <String>[
    'I have had headaches for four days',
    'Chest tightness and shortness of breath',
    'Feeling dizzy when I stand up',
    'Persistent cough for a week',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String description = _controller.text.trim();
    if (description.isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(symptomControllerProvider.notifier).analyse(description);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SymptomAnalysis?> state = ref.watch(
      symptomControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Report a symptom')),
      body: SafeArea(
        top: false,
        child: switch (state) {
          AsyncLoading<SymptomAnalysis?>() => const _AnalysingState(),
          AsyncError<SymptomAnalysis?>(:final Object error) => ErrorState(
            error: error,
            onRetry: _submit,
          ),
          AsyncData<SymptomAnalysis?>(value: final SymptomAnalysis analysis) =>
            AnalysisResult(
              analysis: analysis,
              onReset: () {
                _controller.clear();
                ref.read(symptomControllerProvider.notifier).reset();
              },
              onEmergency: () => context.push(Routes.emergency),
            ),
          _ => _InputState(
            controller: _controller,
            examples: _examples,
            onExample: (String example) {
              _controller.text = example;
              setState(() {});
            },
            onSubmit: _submit,
          ),
        },
      ),
    );
  }
}

class _InputState extends StatelessWidget {
  const _InputState({
    required this.controller,
    required this.examples,
    required this.onExample,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final List<String> examples;
  final ValueChanged<String> onExample;
  final VoidCallback onSubmit;

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
              Text('Describe what you are feeling', style: text.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Use your own words. Your twin already knows your history, so '
                'you do not need to repeat it.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 6,
                  minLines: 4,
                  style: text.bodyLarge,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintText:
                        'For example, I have had a headache for four '
                        'days and it gets worse in the evening.',
                    hintStyle: text.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Common examples', style: text.labelMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: examples
                    .map(
                      (String example) => ActionChip(
                        label: Text(example),
                        labelStyle: text.bodyMedium,
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        onPressed: () => onExample(example),
                      ),
                    )
                    .toList(growable: false),
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
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue value, _) {
              return FilledButton(
                onPressed: value.text.trim().isEmpty ? null : onSubmit,
                child: const Text('Analyse symptom'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnalysingState extends StatefulWidget {
  const _AnalysingState();

  @override
  State<_AnalysingState> createState() => _AnalysingStateState();
}

class _AnalysingStateState extends State<_AnalysingState> {
  static const List<String> _steps = <String>[
    'Reading your description',
    'Checking against your twin history',
    'Comparing biomarker trends',
    'Assessing urgency',
  ];

  int _done = 0;

  @override
  void initState() {
    super.initState();
    _advance();
  }

  Future<void> _advance() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 380));
      if (!mounted) {
        return;
      }
      setState(() => _done = i + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Analysing', style: text.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Reading this against everything already on your twin.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          for (int i = 0; i < _steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: i < _done
                          ? AppColors.primary
                          : AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: i < _done
                        ? const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: AppColors.onPrimary,
                          )
                        : i == _done
                        ? const Padding(
                            padding: EdgeInsets.all(5),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style:
                          (i <= _done
                              ? text.titleSmall
                              : text.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary,
                                )) ??
                          const TextStyle(),
                      child: Text(_steps[i]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
