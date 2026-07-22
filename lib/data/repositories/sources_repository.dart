import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../demo/demo_sources.dart';
import '../models/data_source.dart';

abstract interface class SourcesRepository {
  Future<List<ConnectedSource>> fetchSources();

  Future<ConnectedSource> connect(String id);

  Future<ConnectedSource> disconnect(String id);

  Future<SyncResult> sync(String id);

  Future<SyncResult> importFhirBundle(Map<String, dynamic> bundle);

  Future<void> seedDemoHistory();
}

class RemoteSourcesRepository implements SourcesRepository {
  const RemoteSourcesRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ConnectedSource>> fetchSources() async {
    final List<dynamic> json = await _client.get<List<dynamic>>(
      ApiEndpoints.sources,
    );
    return json
        .map((dynamic e) => ConnectedSource.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ConnectedSource> connect(String id) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.connectSource(id),
    );
    return ConnectedSource.fromJson(json);
  }

  @override
  Future<ConnectedSource> disconnect(String id) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.disconnectSource(id),
    );
    return ConnectedSource.fromJson(json);
  }

  @override
  Future<SyncResult> sync(String id) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.syncSource(id),
    );
    return SyncResult.fromJson(json);
  }

  @override
  Future<SyncResult> importFhirBundle(Map<String, dynamic> bundle) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.importFhir,
      body: bundle,
    );
    return SyncResult.fromJson(json);
  }

  @override
  Future<void> seedDemoHistory() async {
    await _client.post<Map<String, dynamic>>(ApiEndpoints.seedDemo);
  }
}

class MockSourcesRepository implements SourcesRepository {
  MockSourcesRepository();

  static const Duration _latency = Duration(milliseconds: 500);

  List<ConnectedSource>? _sources;

  List<ConnectedSource> get _current => _sources ??= DemoSources.all;

  @override
  Future<List<ConnectedSource>> fetchSources() async {
    await Future<void>.delayed(_latency);
    return List<ConnectedSource>.unmodifiable(_current);
  }

  @override
  Future<ConnectedSource> connect(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    return _update(
      id,
      (ConnectedSource s) =>
          s.copyWith(isConnected: true, lastSyncedAt: DateTime.now()),
    );
  }

  @override
  Future<ConnectedSource> disconnect(String id) async {
    await Future<void>.delayed(_latency);
    return _update(id, (ConnectedSource s) => s.copyWith(isConnected: false));
  }

  @override
  Future<SyncResult> sync(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final ConnectedSource source = _current.firstWhere(
      (ConnectedSource s) => s.id == id,
    );
    final int added = source.kind == DataSourceKind.wearable ? 12 : 4;

    _update(
      id,
      (ConnectedSource s) => s.copyWith(
        lastSyncedAt: DateTime.now(),
        readingCount: s.readingCount + added,
      ),
    );

    return SyncResult(
      sourceId: id,
      readingsAdded: added,
      eventsAdded: source.kind == DataSourceKind.clinic ? 3 : 0,
      syncedAt: DateTime.now(),
    );
  }

  @override
  Future<SyncResult> importFhirBundle(Map<String, dynamic> bundle) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    return SyncResult(
      sourceId: 'src_clinic',
      readingsAdded: 9,
      eventsAdded: 5,
      syncedAt: DateTime.now(),
    );
  }

  @override
  Future<void> seedDemoHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }

  ConnectedSource _update(
    String id,
    ConnectedSource Function(ConnectedSource) change,
  ) {
    final int index = _current.indexWhere((ConnectedSource s) => s.id == id);
    if (index == -1) {
      throw ArgumentError.value(id, 'id', 'Unknown source');
    }
    final ConnectedSource updated = change(_current[index]);
    _current[index] = updated;
    return updated;
  }
}
