import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const List<_Action> _actions = <_Action>[
    _Action(
      icon: Icons.add_comment_outlined,
      label: 'Report symptom',
      route: Routes.symptomCheck,
    ),
    _Action(
      icon: Icons.monitor_heart_outlined,
      label: 'Log reading',
      route: Routes.biomarkers,
    ),
    _Action(
      icon: Icons.medication_outlined,
      label: 'Medications',
      route: Routes.medications,
    ),
    _Action(
      icon: Icons.share_outlined,
      label: 'Share record',
      route: Routes.clinicalSummary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < _actions.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppSpacing.md),
          Expanded(child: _ActionButton(action: _actions[i])),
        ],
      ],
    );
  }
}

class _Action {
  const _Action({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final _Action action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push(action.route),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: <Widget>[
              Icon(action.icon, size: 22, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
