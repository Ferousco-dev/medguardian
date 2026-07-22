import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../demo/demo_data.dart';
import '../models/biomarker.dart';
import '../models/digital_twin.dart';
import '../models/health_event.dart';

abstract interface class TwinRepository {
  Future<DigitalTwin> fetchTwin();

  Future<DigitalTwin> createTwin(DigitalTwin twin);

  Future<DigitalTwin> updateTwin(DigitalTwin twin);

  Future<List<HealthEvent>> fetchEvents();

  Future<HealthEvent> createEvent(HealthEvent event);

  Future<void> setEventHidden({required String id, required bool hidden});

  Future<List<Biomarker>> fetchBiomarkers();

  Future<Biomarker> recordReading({
    required String code,
    required double value,
  });
}

class RemoteTwinRepository implements TwinRepository {
  const RemoteTwinRepository(this._client);

  final ApiClient _client;

  @override
  Future<DigitalTwin> fetchTwin() async {
    final Map<String, dynamic> json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.twin,
    );
    return DigitalTwin.fromJson(json);
  }

  @override
  Future<DigitalTwin> createTwin(DigitalTwin twin) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.twin,
      body: twin.toJson(),
    );
    return DigitalTwin.fromJson(json);
  }

  @override
  Future<DigitalTwin> updateTwin(DigitalTwin twin) async {
    final Map<String, dynamic> json = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.twinProfile,
      body: twin.toJson(),
    );
    return DigitalTwin.fromJson(json);
  }

  @override
  Future<List<HealthEvent>> fetchEvents() async {
    final List<dynamic> json = await _client.get<List<dynamic>>(
      ApiEndpoints.events,
    );
    return json
        .map((dynamic e) => HealthEvent.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<HealthEvent> createEvent(HealthEvent event) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.events,
      body: event.toJson(),
    );
    return HealthEvent.fromJson(json);
  }

  @override
  Future<void> setEventHidden({
    required String id,
    required bool hidden,
  }) async {
    await _client.post<Map<String, dynamic>>(
      ApiEndpoints.hideEvent(id),
      body: <String, dynamic>{'hidden': hidden},
    );
  }

  @override
  Future<List<Biomarker>> fetchBiomarkers() async {
    final List<dynamic> json = await _client.get<List<dynamic>>(
      ApiEndpoints.biomarkers,
    );
    return json
        .map((dynamic e) => Biomarker.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Biomarker> recordReading({
    required String code,
    required double value,
  }) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.biomarkers,
      body: <String, dynamic>{
        'code': code,
        'value': value,
        'recorded_at': DateTime.now().toIso8601String(),
      },
    );
    return Biomarker.fromJson(json);
  }
}

class MockTwinRepository implements TwinRepository {
  MockTwinRepository();

  static const Duration _latency = Duration(milliseconds: 450);

  DigitalTwin? _twin;
  List<HealthEvent>? _events;
  List<Biomarker>? _biomarkers;

  DigitalTwin get _current => _twin ??= DemoData.twin;

  List<HealthEvent> get _currentEvents => _events ??= DemoData.events;

  List<Biomarker> get _currentBiomarkers => _biomarkers ??= DemoData.biomarkers;

  @override
  Future<DigitalTwin> fetchTwin() async {
    await Future<void>.delayed(_latency);
    return _current;
  }

  @override
  Future<DigitalTwin> createTwin(DigitalTwin twin) async {
    await Future<void>.delayed(_latency);
    _twin = twin;
    return twin;
  }

  @override
  Future<DigitalTwin> updateTwin(DigitalTwin twin) async {
    await Future<void>.delayed(_latency);
    _twin = twin;
    return twin;
  }

  @override
  Future<List<HealthEvent>> fetchEvents() async {
    await Future<void>.delayed(_latency);
    return List<HealthEvent>.unmodifiable(
      _currentEvents..sort(
        (HealthEvent a, HealthEvent b) => b.occurredAt.compareTo(a.occurredAt),
      ),
    );
  }

  @override
  Future<HealthEvent> createEvent(HealthEvent event) async {
    await Future<void>.delayed(_latency);
    _currentEvents.insert(0, event);
    return event;
  }

  @override
  Future<void> setEventHidden({
    required String id,
    required bool hidden,
  }) async {
    await Future<void>.delayed(_latency);
    final int index = _currentEvents.indexWhere((HealthEvent e) => e.id == id);
    if (index != -1) {
      _currentEvents[index] = _currentEvents[index].copyWith(isHidden: hidden);
    }
  }

  @override
  Future<List<Biomarker>> fetchBiomarkers() async {
    await Future<void>.delayed(_latency);
    return List<Biomarker>.unmodifiable(_currentBiomarkers);
  }

  @override
  Future<Biomarker> recordReading({
    required String code,
    required double value,
  }) async {
    await Future<void>.delayed(_latency);

    final int index = _currentBiomarkers.indexWhere(
      (Biomarker b) => b.code == code,
    );
    if (index == -1) {
      throw ArgumentError.value(code, 'code', 'Unknown biomarker');
    }

    final Biomarker existing = _currentBiomarkers[index];
    final Biomarker updated = Biomarker(
      loincCode: existing.loincCode,
      code: existing.code,
      name: existing.name,
      unit: existing.unit,
      referenceLow: existing.referenceLow,
      referenceHigh: existing.referenceHigh,
      trend: existing.trend,
      readings: <BiomarkerReading>[
        ...existing.readings,
        BiomarkerReading(
          value: value,
          recordedAt: DateTime.now(),
          source: 'manual',
        ),
      ],
    );

    _currentBiomarkers[index] = updated;
    return updated;
  }
}
