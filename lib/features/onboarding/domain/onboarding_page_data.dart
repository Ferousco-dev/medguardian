import 'package:flutter/widgets.dart';

@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.body,
    required this.visual,
  });

  final String title;
  final String body;

  final Widget visual;
}
