import 'package:flutter/widgets.dart';

/// Content for a single onboarding page.
@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.body,
    required this.visual,
  });

  final String title;
  final String body;

  /// The illustration shown above the copy.
  final Widget visual;
}
