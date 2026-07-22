import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/health_event.dart';
import '../../../shared/widgets/async_view.dart';
import 'widgets/timeline_entry.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  HealthEventType? _filter;
  bool _showHidden = false;

  List<HealthEvent> _visible(List<HealthEvent> events) {
    return events
        .where((HealthEvent event) {
          if (!_showHidden && event.isHidden) {
            return false;
          }
          if (_filter != null && event.type != _filter) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<HealthEvent>> events = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health timeline'),
        actions: <Widget>[
          IconButton(
            tooltip: _showHidden
                ? 'Hide private entries'
                : 'Show private entries',
            onPressed: () => setState(() => _showHidden = !_showHidden),
            icon: Icon(
              _showHidden
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_outlined,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            _FilterBar(
              selected: _filter,
              onSelected: (HealthEventType? type) =>
                  setState(() => _filter = type),
            ),
            Expanded(
              child: AsyncView<List<HealthEvent>>(
                value: events,
                onRetry: () => ref.invalidate(eventsProvider),
                data: (List<HealthEvent> all) {
                  final List<HealthEvent> visible = _visible(all);

                  if (visible.isEmpty) {
                    return EmptyState(
                      icon: Icons.timeline_outlined,
                      title: 'Nothing here yet',
                      body: _filter == null
                          ? 'Report a symptom or log a reading and it will '
                                'appear on your timeline.'
                          : 'No ${_filter!.label.toLowerCase()} entries '
                                'recorded.',
                      action: FilledButton(
                        onPressed: () => context.push(Routes.symptomCheck),
                        child: const Text('Report a symptom'),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(eventsProvider);
                      await ref.read(eventsProvider.future);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.lg,
                        AppSpacing.page,
                        AppSpacing.huge,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TimelineEntry(
                          event: visible[index],
                          isFirst: index == 0,
                          isLast: index == visible.length - 1,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final HealthEventType? selected;
  final ValueChanged<HealthEventType?> onSelected;

  static const List<HealthEventType> _types = <HealthEventType>[
    HealthEventType.symptom,
    HealthEventType.measurement,
    HealthEventType.labResult,
    HealthEventType.medication,
    HealthEventType.diagnosis,
    HealthEventType.visit,
    HealthEventType.vaccination,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: <Widget>[
          _Chip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final HealthEventType type in _types)
            _Chip(
              label: type.label,
              isSelected: selected == type,
              onTap: () => onSelected(type),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Center(
        child: Material(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
