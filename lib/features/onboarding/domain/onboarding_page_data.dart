import 'package:flutter/widgets.dart';

@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.imageUrl,
    required this.title,
    required this.body,
  });

  /// Bundled asset path.
  final String imageUrl;
  final String title;
  final String body;
}
