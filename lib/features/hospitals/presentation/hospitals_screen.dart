import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/hospital.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_pill.dart';

class HospitalsScreen extends ConsumerWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Hospital>> hospitals = ref.watch(hospitalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby hospitals')),
      body: SafeArea(
        top: false,
        child: AsyncView<List<Hospital>>(
          value: hospitals,
          onRetry: () => ref.invalidate(hospitalsProvider),
          data: (List<Hospital> value) {
            if (value.isEmpty) {
              return const EmptyState(
                icon: Icons.local_hospital_outlined,
                title: 'No facilities found',
                body: 'Nothing was found near your current location.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.huge,
              ),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (BuildContext context, int index) =>
                  HospitalCard(hospital: value[index]),
            );
          },
        ),
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key, required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hospital.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              child: CachedNetworkImage(
                imageUrl: AppImages.sized(hospital.imageUrl!, width: 900),
                height: 132,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(height: 132, color: AppColors.surfaceMuted),
                errorWidget: (_, _, _) => Container(
                  height: 132,
                  color: AppColors.surfaceMuted,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.local_hospital_outlined,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(hospital.name, style: text.titleMedium),
                    ),
                    StatusPill(
                      label: hospital.isOpenNow ? 'Open' : 'Closed',
                      tone: hospital.isOpenNow
                          ? StatusTone.positive
                          : StatusTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(hospital.address, style: text.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Text(
                      '${hospital.distanceKm.toStringAsFixed(1)} km',
                      style: AppTypography.numeric(fontSize: 15),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'about ${hospital.travelMinutes} min away',
                      style: text.bodySmall,
                    ),
                    const Spacer(),
                    if (hospital.hasEmergency)
                      const StatusPill(
                        label: 'Emergency',
                        tone: StatusTone.critical,
                        icon: Icons.emergency_outlined,
                      ),
                  ],
                ),
                if (hospital.specialties.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: hospital.specialties
                        .map((String s) => StatusPill(label: s))
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
