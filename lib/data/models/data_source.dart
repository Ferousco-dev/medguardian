enum DataSourceKind { manual, wearable, clinic, lab, demo }

extension DataSourceKindLabel on DataSourceKind {
  String get label => switch (this) {
    DataSourceKind.manual => 'Entered by you',
    DataSourceKind.wearable => 'Wearable',
    DataSourceKind.clinic => 'Clinic',
    DataSourceKind.lab => 'Lab report',
    DataSourceKind.demo => 'Demo data',
  };

  String get apiValue => switch (this) {
    DataSourceKind.manual => 'manual',
    DataSourceKind.wearable => 'wearable',
    DataSourceKind.clinic => 'clinic',
    DataSourceKind.lab => 'lab',
    DataSourceKind.demo => 'demo',
  };

  static DataSourceKind fromApi(String? value) {
    return switch (value) {
      'wearable' => DataSourceKind.wearable,
      'clinic' => DataSourceKind.clinic,
      'lab' => DataSourceKind.lab,
      'demo' => DataSourceKind.demo,
      _ => DataSourceKind.manual,
    };
  }
}

class ConnectedSource {
  const ConnectedSource({
    required this.id,
    required this.name,
    required this.kind,
    required this.isConnected,
    this.provider,
    this.lastSyncedAt,
    this.suppliedMarkers = const <String>[],
    this.readingCount = 0,
  });

  final String id;
  final String name;
  final DataSourceKind kind;
  final bool isConnected;

  /// Platform behind the connection, for example `health_connect`.
  final String? provider;

  final DateTime? lastSyncedAt;

  /// Biomarker codes this source can actually supply.
  final List<String> suppliedMarkers;

  final int readingCount;

  factory ConnectedSource.fromJson(Map<String, dynamic> json) {
    return ConnectedSource(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      kind: DataSourceKindLabel.fromApi(json['kind'] as String?),
      isConnected: json['is_connected'] as bool? ?? false,
      provider: json['provider'] as String?,
      lastSyncedAt: json['last_synced_at'] is String
          ? DateTime.tryParse(json['last_synced_at'] as String)
          : null,
      suppliedMarkers:
          ((json['supplied_markers'] as List<dynamic>?) ?? const <dynamic>[])
              .map((dynamic e) => e.toString())
              .toList(growable: false),
      readingCount: (json['reading_count'] as num?)?.round() ?? 0,
    );
  }

  ConnectedSource copyWith({
    bool? isConnected,
    DateTime? lastSyncedAt,
    int? readingCount,
  }) {
    return ConnectedSource(
      id: id,
      name: name,
      kind: kind,
      isConnected: isConnected ?? this.isConnected,
      provider: provider,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      suppliedMarkers: suppliedMarkers,
      readingCount: readingCount ?? this.readingCount,
    );
  }
}

class SyncResult {
  const SyncResult({
    required this.sourceId,
    required this.readingsAdded,
    required this.eventsAdded,
    required this.syncedAt,
  });

  final String sourceId;
  final int readingsAdded;
  final int eventsAdded;
  final DateTime syncedAt;

  bool get foundSomething => readingsAdded > 0 || eventsAdded > 0;

  String get summary {
    if (!foundSomething) {
      return 'Already up to date, nothing new to bring in.';
    }
    final List<String> parts = <String>[
      if (readingsAdded > 0)
        '$readingsAdded reading${readingsAdded == 1 ? '' : 's'}',
      if (eventsAdded > 0) '$eventsAdded event${eventsAdded == 1 ? '' : 's'}',
    ];
    return 'Added ${parts.join(' and ')} to your twin.';
  }

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      sourceId: json['source_id'] as String? ?? '',
      readingsAdded: (json['readings_added'] as num?)?.round() ?? 0,
      eventsAdded: (json['events_added'] as num?)?.round() ?? 0,
      syncedAt: json['synced_at'] is String
          ? DateTime.parse(json['synced_at'] as String)
          : DateTime.now(),
    );
  }
}
