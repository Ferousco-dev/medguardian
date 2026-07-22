import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/onboarding_page_data.dart';
import 'widgets/onboarding_visuals.dart';
import 'widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<OnboardingPageData> _pages = <OnboardingPageData>[
    OnboardingPageData(
      title: 'One living record of\nyour health',
      body:
          'Every symptom, reading and medication builds a digital twin of your '
          'body. Nothing is scattered across notes and receipts anymore.',
      visual: TwinPreviewVisual(),
    ),
    OnboardingPageData(
      title: 'See problems while\nthey are still small',
      body:
          'MedGuardian watches your biomarkers over time and tells you when a '
          'trend is heading the wrong way, not after it becomes an emergency.',
      visual: TrendPreviewVisual(),
    ),
    OnboardingPageData(
      title: 'Hand your doctor the\nwhole picture',
      body:
          'Generate a clinical summary in one tap and grant your doctor access '
          'for as long as you choose. The record stays yours.',
      visual: SharePreviewVisual(),
    ),
  ];

  bool get _isLastPage => _index == _pages.length - 1;

  void _next() {
    if (_isLastPage) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    context.go(Routes.signIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.md,
                  top: AppSpacing.sm,
                ),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (int index) => setState(() => _index = index),
                itemBuilder: (BuildContext context, int index) {
                  final OnboardingPageData page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Spacer(),
                        page.visual,
                        const SizedBox(height: AppSpacing.huge),
                        Text(page.title, style: text.headlineMedium),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.body,
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.xxl,
              ),
              child: Column(
                children: <Widget>[
                  PageIndicator(count: _pages.length, activeIndex: _index),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_isLastPage ? 'Get started' : 'Continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
