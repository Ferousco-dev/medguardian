import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../demo/demo_data.dart';
import '../models/health_insight.dart';
import '../models/health_simulation.dart';
import '../models/risk_score.dart';
import '../models/symptom_analysis.dart';

abstract interface class IntelligenceRepository {
  Future<RiskScore> fetchRiskScore();

  Future<List<HealthInsight>> fetchInsights();

  Future<HealthSimulation> runSimulation(String question);

  Future<SymptomAnalysis> analyseSymptoms(String description);
}

class RemoteIntelligenceRepository implements IntelligenceRepository {
  const RemoteIntelligenceRepository(this._client);

  final ApiClient _client;

  @override
  Future<RiskScore> fetchRiskScore() async {
    final Map<String, dynamic> json = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.riskScore,
    );
    return RiskScore.fromJson(json);
  }

  @override
  Future<List<HealthInsight>> fetchInsights() async {
    final List<dynamic> json = await _client.get<List<dynamic>>(
      ApiEndpoints.insights,
    );
    return json
        .map((dynamic e) => HealthInsight.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<HealthSimulation> runSimulation(String question) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.simulation,
      body: <String, dynamic>{'question': question},
    );
    return HealthSimulation.fromJson(json);
  }

  @override
  Future<SymptomAnalysis> analyseSymptoms(String description) async {
    final Map<String, dynamic> json = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.analyseSymptoms,
      body: <String, dynamic>{'description': description},
    );
    return SymptomAnalysis.fromJson(json);
  }
}

class MockIntelligenceRepository implements IntelligenceRepository {
  const MockIntelligenceRepository();

  static const Duration _latency = Duration(milliseconds: 600);

  @override
  Future<RiskScore> fetchRiskScore() async {
    await Future<void>.delayed(_latency);
    return DemoData.riskScore;
  }

  @override
  Future<List<HealthInsight>> fetchInsights() async {
    await Future<void>.delayed(_latency);
    return DemoData.insights;
  }

  @override
  Future<HealthSimulation> runSimulation(String question) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    return DemoData.simulation;
  }

  @override
  Future<SymptomAnalysis> analyseSymptoms(String description) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    return DemoData.analysisFor(description);
  }
}
