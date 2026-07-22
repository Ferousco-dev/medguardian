import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/health_event.dart';
import '../../../../shared/widgets/status_pill.dart';

class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.event,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  final HealthEvent event;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  static const Map<HealthEventType, IconData> _icons =
      <HealthEventType, IconData>{
        HealthEventType.symptom: Icons.sick_outlined,
        HealthEventType.diagnosis: Icons.assignment_outlined,
        HealthEventType.medication: Icons.medication_outlined,
        HealthEventType.vaccination: Icons.vaccines_outlined,
        HealthEventType.labResult: Icons.science_outlined,
        HealthEventType.measurement: Icons.monitor_heart_outlined,
        HealthEventType.visit: Icons.local_hospital_outlined,
        HealthEventType.procedure: Icons.healing_outlined,
        HealthEventType.allergy: Icons.warning_amber_outlined,
        HealthEventType.note: Icons.sticky_note_2_outlined,
      };

  StatusTone get _tone => switch (event.severity) {
    EventSeverity.none => StatusTone.neutral,
    EventSeverity.mild => StatusTone.info,
    EventSeverity.moderate => StatusTone.caution,
    EventSeverity.severe => StatusTone.critical,
    EventSeverity.critical => StatusTone.critical,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Rail(
            isFirst: isFirst,
            isLast: isLast,
            tone: _tone,
            icon: _icons[event.type] ?? Icons.circle_outlined,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : AppSpacing.sm,
                bottom: AppSpacing.xxl,
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(event.type.label, style: text.labelSmall),
                        const Spacer(),
                        Text(
                          DateFormat('d MMM').format(event.occurredAt),
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(event.title, style: text.titleMedium),
                    if (event.description != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(event.description!, style: text.bodyMedium),
                    ],
                    if (event.severity != EventSeverity.none ||
                        event.clinicalCode != null ||
                        event.isHidden) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: <Widget>[
                          if (event.severity != EventSeverity.none)
                            StatusPill(
                              label: event.severity.label,
                              tone: _tone,
                            ),
                          if (event.clinicalCode != null)
                            StatusPill(label: event.clinicalCode!),
                          if (event.isHidden)
                            const StatusPill(
                              label: 'Hidden from providers',
                              icon: Icons.visibility_off_outlined,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.isFirst,
    required this.isLast,
    required this.tone,
    required this.icon,
  });

  final bool isFirst;
  final bool isLast;
  final StatusTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool isNeutral = tone == StatusTone.neutral;

    return SizedBox(
      width: 32,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: isFirst ? 2 : 8,
            child: isFirst
                ? null
                : const VerticalDivider(width: 1, thickness: 1),
          ),
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: isNeutral ? AppColors.surfaceMuted : tone.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isNeutral ? AppColors.textSecondary : tone.foreground,
            ),
          ),
          if (!isLast)
            const Expanded(child: VerticalDivider(width: 1, thickness: 1)),
        ],
      ),
    );
  }
}
