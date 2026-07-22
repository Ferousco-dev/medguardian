class HealthSimulation {
  const HealthSimulation({
    required this.id,
    required this.question,
    required this.scenario,
    required this.horizons,
    required this.generatedAt,
    this.preventiveActions = const <String>[],
  });

  final String id;
  final String question;
  final SimulationScenario scenario;
  final List<SimulationHorizon> horizons;
  final List<String> preventiveActions;
  final DateTime generatedAt;

  factory HealthSimulation.fromJson(Map<String, dynamic> json) {
    return HealthSimulation(
      id: json['id'] as String,
      question: json['question'] as String? ?? '',
      scenario: SimulationScenario.fromApi(json['scenario'] as String?),
      horizons: ((json['horizons'] as List<dynamic>?) ?? const <dynamic>[])
          .map(
            (dynamic e) =>
                SimulationHorizon.fromJson(e as Map<String, dynamic>),
          )
          .toList(growable: false),
      preventiveActions:
          ((json['preventive_actions'] as List<dynamic>?) ?? const <dynamic>[])
              .map((dynamic e) => e.toString())
              .toList(growable: false),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}

class SimulationHorizon {
  const SimulationHorizon({
    required this.label,
    required this.outcome,
    required this.riskLevel,
    this.projectedValue,
  });

  final String label;
  final String outcome;

  final double riskLevel;

  final String? projectedValue;

  factory SimulationHorizon.fromJson(Map<String, dynamic> json) {
    return SimulationHorizon(
      label: json['label'] as String? ?? '',
      outcome: json['outcome'] as String? ?? '',
      riskLevel: (json['risk_level'] as num?)?.toDouble() ?? 0,
      projectedValue: json['projected_value'] as String?,
    );
  }
}

enum SimulationScenario {
  unchanged('unchanged', 'If nothing changes'),
  improved('improved', 'If you act now');

  const SimulationScenario(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static SimulationScenario fromApi(String? value) {
    return SimulationScenario.values.firstWhere(
      (SimulationScenario scenario) => scenario.apiValue == value,
      orElse: () => SimulationScenario.unchanged,
    );
  }
}
