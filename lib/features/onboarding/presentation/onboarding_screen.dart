import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/onboarding_page_data.dart';
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
      imageUrl: AppImages.onboardingRecord,
      title: 'One living record of\nyour health',
      body:
          'Every symptom, reading and medication builds a digital twin of your '
          'body. Nothing is scattered across notes and receipts anymore.',
    ),
    OnboardingPageData(
      imageUrl: AppImages.onboardingTrends,
      title: 'See problems while\nthey are still small',
      body:
          'MedGuardian watches your biomarkers over time and tells you when a '
          'trend is heading the wrong way, not after it becomes an emergency.',
    ),
    OnboardingPageData(
      imageUrl: AppImages.onboardingShare,
      title: 'Hand your doctor the\nwhole picture',
      body:
          'Generate a clinical summary in one tap and grant your doctor access '
          'for as long as you choose. The record stays yours.',
    ),
  ];

  bool get _isLastPage => _index == _pages.length - 1;

  void _next() {
    if (_isLastPage) {
      _start();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _start() => context.go(Routes.signUp);

  void _skip() => context.go(Routes.signIn);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Size size = MediaQuery.sizeOf(context);
    final double imageHeight = (size.height * 0.46).clamp(240.0, 420.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemBuilder: (BuildContext context, int index) =>
                      _OnboardingImage(asset: _pages[index].imageUrl),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
                  right: AppSpacing.md,
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    child: const Text('I have an account'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xxl,
                AppSpacing.page,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PageIndicator(count: _pages.length, activeIndex: _index),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _pages[_index].title,
                            style: text.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _pages[_index].body,
                            style: text.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: FilledButton(
                onPressed: _next,
                child: Text(_isLastPage ? 'Get started' : 'Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingImage extends StatelessWidget {
  const _OnboardingImage({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.primaryTint,
        child: Center(
          child: Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
        ),
      ),
    );
  }
}
