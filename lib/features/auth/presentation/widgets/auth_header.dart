import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          alignment: Alignment.center,
          child: const BrandMark(size: 34),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: text.displaySmall?.copyWith(fontSize: 28)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
