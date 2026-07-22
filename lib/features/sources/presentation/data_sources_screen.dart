import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/data_source.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/section_heading.dart';
import '../../../shared/widgets/status_pill.dart';

class DataSourcesScreen extends ConsumerStatefulWidget {
  const DataSourcesScreen({super.key});

  @override
  ConsumerState<DataSourcesScreen> createState() => _DataSourcesScreenState();
}

class _DataSourcesScreenState extends ConsumerState<DataSourcesScreen> {
  String? _busyId;

  Future<void> _run(String id, Future<void> Function() action) async {
    setState(() => _busyId = id);
    try {
      await action();
      ref
        ..invalidate(sourcesProvider)
        ..invalidate(biomarkersProvider)
        ..invalidate(eventsProvider)
        ..invalidate(riskScoreProvider);
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
      }
    }
  }

  Future<void> _connect(ConnectedSource source) => _run(source.id, () async {
    await ref.read(sourcesRepositoryProvider).connect(source.id);
    if (mounted) {
      AppSnack.show(context, '${source.name} connected.');
    }
  });

  Future<void> _sync(ConnectedSource source) => _run(source.id, () async {
    final SyncResult result = await ref
        .read(sourcesRepositoryProvider)
        .sync(source.id);
    if (mounted) {
      AppSnack.show(context, result.summary);
    }
  });

  Future<void> _disconnect(ConnectedSource source) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Disconnect ${source.name}?'),
        content: const Text(
          'Readings already on your twin stay there. Nothing new will come in '
          'until you reconnect.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await _run(
      source.id,
      () => ref.read(sourcesRepositoryProvider).disconnect(source.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ConnectedSource>> sources = ref.watch(
      sourcesProvider,
    );
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Where your data comes from')),
      body: SafeArea(
        top: false,
        child: AsyncView<List<ConnectedSource>>(
          value: sources,
          onRetry: () => ref.invalidate(sourcesProvider),
          data: (List<ConnectedSource> value) {
            final List<ConnectedSource> connected = value
                .where((ConnectedSource s) => s.isConnected)
                .toList(growable: false);
            final List<ConnectedSource> available = value
                .where((ConnectedSource s) => !s.isConnected)
                .toList(growable: false);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                AppSpacing.huge,
              ),
              children: <Widget>[
                EntranceFade(
                  index: 0,
                  child: SectionCard(
                    color: AppColors.primaryTint,
                    borderColor: AppColors.primaryTint,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'MedGuardian never invents a measurement. Every '
                            'number on your twin came from you, a device or a '
                            'clinic, and every reading shows which.',
                            style: text.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (connected.isNotEmpty) ...<Widget>[
                  const SectionHeading(title: 'Connected'),
                  for (int i = 0; i < connected.length; i++)
                    EntranceFade(
                      index: i + 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SourceCard(
                          source: connected[i],
                          isBusy: _busyId == connected[i].id,
                          onSync: () => _sync(connected[i]),
                          onDisconnect: () => _disconnect(connected[i]),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (available.isNotEmpty) ...<Widget>[
                  const SectionHeading(title: 'Available to connect'),
                  for (int i = 0; i < available.length; i++)
                    EntranceFade(
                      index: connected.length + i + 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SourceCard(
                          source: available[i],
                          isBusy: _busyId == available[i].id,
                          onConnect: () => _connect(available[i]),
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.source,
    required this.isBusy,
    this.onConnect,
    this.onSync,
    this.onDisconnect,
  });

  final ConnectedSource source;
  final bool isBusy;
  final VoidCallback? onConnect;
  final VoidCallback? onSync;
  final VoidCallback? onDisconnect;

  IconData get _icon => switch (source.kind) {
    DataSourceKind.wearable => Icons.watch_outlined,
    DataSourceKind.clinic => Icons.local_hospital_outlined,
    DataSourceKind.lab => Icons.science_outlined,
    DataSourceKind.manual => Icons.edit_outlined,
    DataSourceKind.demo => Icons.dataset_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool isManual = source.kind == DataSourceKind.manual;

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: source.isConnected
                      ? AppColors.primaryTint
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _icon,
                  size: 19,
                  color: source.isConnected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(source.name, style: text.titleSmall),
                    const SizedBox(height: 1),
                    Text(source.kind.label, style: text.bodySmall),
                  ],
                ),
              ),
              if (source.isConnected)
                const StatusPill(
                  label: 'Active',
                  tone: StatusTone.positive,
                  icon: Icons.check_rounded,
                ),
            ],
          ),
          if (source.suppliedMarkers.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text('Supplies', style: text.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: source.suppliedMarkers
                  .map((String code) => StatusPill(label: _readable(code)))
                  .toList(growable: false),
            ),
          ],
          if (source.isConnected && source.lastSyncedAt != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${source.readingCount} readings, last updated '
              '${DateFormat('d MMM').format(source.lastSyncedAt!)}',
              style: text.bodySmall,
            ),
          ],
          if (!isManual) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            if (isBusy)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                ),
              )
            else if (source.isConnected)
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSync,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      icon: const Icon(Icons.sync_rounded, size: 17),
                      label: const Text('Sync now'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: onDisconnect,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: AppColors.danger,
                    ),
                    child: const Text('Disconnect'),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: onConnect,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                icon: const Icon(Icons.link_rounded, size: 17),
                label: const Text('Connect'),
              ),
          ],
        ],
      ),
    );
  }

  static String _readable(String code) {
    return code
        .split('_')
        .map(
          (String w) =>
              w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
        )
        .join(' ');
  }
}
