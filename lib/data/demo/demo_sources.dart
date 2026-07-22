import '../models/data_source.dart';

abstract final class DemoSources {
  static List<ConnectedSource> get all => <ConnectedSource>[
    ConnectedSource(
      id: 'src_health_connect',
      name: 'Health Connect',
      kind: DataSourceKind.wearable,
      provider: 'health_connect',
      isConnected: false,
      suppliedMarkers: const <String>[
        'resting_heart_rate',
        'bmi',
        'oxygen_saturation',
      ],
    ),
    ConnectedSource(
      id: 'src_bp_cuff',
      name: 'Bluetooth blood pressure cuff',
      kind: DataSourceKind.wearable,
      provider: 'ble_bp',
      isConnected: false,
      suppliedMarkers: const <String>[
        'blood_pressure_systolic',
        'resting_heart_rate',
      ],
    ),
    ConnectedSource(
      id: 'src_clinic',
      name: 'Lagoon General Hospital',
      kind: DataSourceKind.clinic,
      provider: 'fhir',
      isConnected: true,
      lastSyncedAt: DateTime.now().subtract(const Duration(days: 12)),
      readingCount: 14,
      suppliedMarkers: const <String>[
        'hba1c',
        'total_cholesterol',
        'blood_glucose',
      ],
    ),
    ConnectedSource(
      id: 'src_manual',
      name: 'Readings you enter',
      kind: DataSourceKind.manual,
      isConnected: true,
      lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
      readingCount: 23,
      suppliedMarkers: const <String>[
        'blood_pressure_systolic',
        'blood_glucose',
        'bmi',
      ],
    ),
  ];

  const DemoSources._();
}
