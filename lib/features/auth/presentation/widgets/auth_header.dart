import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/brand_mark.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const BrandMark(size: 44),
        const SizedBox(height: AppSpacing.xxl),
        Text(title, style: text.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(subtitle, style: text.bodyLarge),
      ],
    );
  }
}
