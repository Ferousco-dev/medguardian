import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum StatusTone { neutral, positive, caution, critical, info }

extension StatusToneColors on StatusTone {
  Color get foreground => switch (this) {
    StatusTone.neutral => AppColors.textSecondary,
    StatusTone.positive => AppColors.success,
    StatusTone.caution => AppColors.warning,
    StatusTone.critical => AppColors.danger,
    StatusTone.info => AppColors.info,
  };

  Color get background => switch (this) {
    StatusTone.neutral => AppColors.surfaceMuted,
    StatusTone.positive => AppColors.successTint,
    StatusTone.caution => AppColors.warningTint,
    StatusTone.critical => AppColors.dangerTint,
    StatusTone.info => AppColors.infoTint,
  };
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: tone.foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tone.foreground),
          ),
        ],
      ),
    );
  }
}
