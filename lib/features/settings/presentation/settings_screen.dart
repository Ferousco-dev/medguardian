import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../auth/application/auth_controller.dart';
import '../../shell/application/shell_tab.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text(
          'Your twin stays safe. You can sign back in at any time.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(authControllerProvider.notifier).signOut();

    if (context.mounted) {
      context.go(Routes.signIn);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.huge,
          ),
          children: <Widget>[
            const SectionHeading(title: 'Your record'),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _Tile(
                    icon: Icons.person_outline_rounded,
                    label: 'Digital twin profile',
                    onTap: () {
                      ref.read(shellTabProvider.notifier).select(ShellTab.twin);
                      context.pop();
                    },
                  ),
                  const Divider(),
                  _Tile(
                    icon: Icons.description_outlined,
                    label: 'Clinical summary',
                    onTap: () => context.push(Routes.clinicalSummary),
                  ),
                  const Divider(),
                  _Tile(
                    icon: Icons.emergency_outlined,
                    label: 'Emergency card',
                    onTap: () => context.push(Routes.emergency),
                  ),
                  const Divider(),
                  _Tile(
                    icon: Icons.cable_rounded,
                    label: 'Data sources and devices',
                    onTap: () => context.push(Routes.dataSources),
                  ),
                  const Divider(),
                  _Tile(
                    icon: Icons.menu_book_outlined,
                    label: 'Health library',
                    onTap: () => context.push(Routes.guides),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeading(title: 'Privacy'),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('You own this record', style: text.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'MedGuardian never shares your twin without an explicit, '
                    'time limited grant from you. Entries you mark private are '
                    'excluded from every provider view and clinical summary.',
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeading(title: 'About'),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _Tile(
                    icon: Icons.info_outline_rounded,
                    label: 'Version',
                    trailing: Text('1.0.0', style: text.bodyMedium),
                  ),
                  const Divider(),
                  _Tile(
                    icon: Icons.cloud_outlined,
                    label: 'Data source',
                    trailing: StatusPill(
                      label: AppConfig.useMockData ? 'Demo data' : 'Live API',
                      tone: AppConfig.useMockData
                          ? StatusTone.caution
                          : StatusTone.positive,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            OutlinedButton(
              onPressed: () => _signOut(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
