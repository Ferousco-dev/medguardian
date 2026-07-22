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
      label: 'Report\nsymptom',
      route: Routes.symptomCheck,
    ),
    _Action(
      icon: Icons.forum_outlined,
      label: 'Ask\nassistant',
      route: Routes.healthChat,
    ),
    _Action(
      icon: Icons.medication_outlined,
      label: 'My\nmedications',
      route: Routes.medications,
    ),
    _Action(
      icon: Icons.ios_share_outlined,
      label: 'Share\nrecord',
      route: Routes.clinicalSummary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 38,
                width: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, size: 19, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 30,
                child: Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 0,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
