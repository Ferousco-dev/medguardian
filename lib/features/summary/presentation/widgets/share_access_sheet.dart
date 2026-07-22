import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/clinical_summary.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../application/summary_controller.dart';

class ShareAccessSheet extends ConsumerStatefulWidget {
  const ShareAccessSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (BuildContext context) => const ShareAccessSheet(),
    );
  }

  @override
  ConsumerState<ShareAccessSheet> createState() => _ShareAccessSheetState();
}

class _ShareAccessSheetState extends ConsumerState<ShareAccessSheet> {
  static const List<int> _options = <int>[1, 24, 72, 168];

  int? _selected;

  static String _label(int hours) {
    if (hours < 24) {
      return '$hours hour';
    }
    if (hours < 168) {
      return '${hours ~/ 24} days';
    }
    return '1 week';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Grant temporary access', style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your doctor can open this record for as long as you choose. '
            'Access expires on its own.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _options
                .map(
                  (int hours) => ChoiceChip(
                    label: Text(_label(hours)),
                    selected: _selected == hours,
                    onSelected: (_) => setState(() => _selected = hours),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primaryTint,
                    labelStyle: text.labelMedium?.copyWith(
                      color: _selected == hours
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: _selected == hours
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          if (_selected != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xxl),
            AsyncView<AccessGrant>(
              value: ref.watch(accessGrantProvider(_selected!)),
              loading: const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
              data: (AccessGrant grant) => _GrantCard(grant: grant),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrantCard extends StatelessWidget {
  const _GrantCard({required this.grant});

  final AccessGrant grant;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: <Widget>[
          Text('Access code', style: text.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            grant.code,
            style: AppTypography.numeric(
              fontSize: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Expires ${DateFormat('d MMM, HH:mm').format(grant.expiresAt)}',
            style: text.bodySmall,
          ),
          if (grant.scope.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: grant.scope
                  .map((String s) => StatusPill(label: s))
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Scoped and revocable. You can end this at any time.',
              style: text.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: grant.code));
              if (context.mounted) {
                Navigator.of(context).pop();
                AppSnack.show(context, 'Access code copied');
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy code'),
          ),
        ],
      ),
    );
  }
}
