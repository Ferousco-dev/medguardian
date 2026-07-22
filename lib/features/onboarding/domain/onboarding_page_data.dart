import 'package:flutter/widgets.dart';

@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.imageUrl,
    required this.title,
    required this.body,
  });

  final String imageUrl;
  final String title;
  final String body;
}
