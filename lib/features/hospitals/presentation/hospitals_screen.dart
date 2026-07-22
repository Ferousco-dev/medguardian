import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/hospital.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_pill.dart';

final Provider<LocationService> locationServiceProvider =
    Provider<LocationService>((Ref ref) => const LocationService());

final FutureProvider<LocationResult> locationProvider =
    FutureProvider<LocationResult>(
      (Ref ref) => ref.watch(locationServiceProvider).current(),
    );

class HospitalsScreen extends ConsumerWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Hospital>> hospitals = ref.watch(hospitalsProvider);
    final AsyncValue<LocationResult> location = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby hospitals')),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            if (location.valueOrNull != null &&
                location.value!.outcome != LocationOutcome.granted)
              _LocationNotice(
                result: location.value!,
                onRetry: () => ref.invalidate(locationProvider),
                onOpenSettings: () =>
                    ref.read(locationServiceProvider).openSettings(),
              ),
            Expanded(
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

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref
                        ..invalidate(hospitalsProvider)
                        ..invalidate(locationProvider);
                      await ref.read(hospitalsProvider.future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.lg,
                        AppSpacing.page,
                        AppSpacing.huge,
                      ),
                      itemCount: value.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (BuildContext context, int index) =>
                          HospitalCard(hospital: value[index]),
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

class _LocationNotice extends StatelessWidget {
  const _LocationNotice({
    required this.result,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final LocationResult result;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool isBlocked = result.outcome == LocationOutcome.deniedForever;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        0,
      ),
      child: SectionCard(
        color: AppColors.infoTint,
        borderColor: AppColors.infoTint,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.location_off_outlined,
                  size: 18,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(result.message, style: text.bodyMedium)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: isBlocked ? onOpenSettings : onRetry,
                child: Text(isBlocked ? 'Open settings' : 'Allow location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key, required this.hospital});

  final Hospital hospital;

  Future<void> _call(BuildContext context) async {
    final String? phone = hospital.phone;
    if (phone == null) {
      return;
    }
    final Uri uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (!await launchUrl(uri) && context.mounted) {
      AppSnack.show(
        context,
        'No dialler available on this device.',
        isError: true,
      );
    }
  }

  Future<void> _directions(BuildContext context) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${Uri.encodeComponent('${hospital.name}, ${hospital.address}')}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      AppSnack.show(context, 'Could not open maps.', isError: true);
    }
  }

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
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _directions(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                        ),
                        icon: const Icon(Icons.directions_outlined, size: 18),
                        label: const Text('Directions'),
                      ),
                    ),
                    if (hospital.phone != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _call(context),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: hospital.hasEmergency
                                ? AppColors.danger
                                : AppColors.primary,
                          ),
                          icon: const Icon(Icons.call_outlined, size: 18),
                          label: const Text('Call'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
