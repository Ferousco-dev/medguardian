import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = AppRadius.lg,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      period: const Duration(milliseconds: 1400),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({super.key, this.count = 4, this.tileHeight = 158});

  final int count;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        mainAxisExtent: tileHeight,
      ),
      itemBuilder: (_, _) => Skeleton(height: tileHeight),
    );
  }
}
