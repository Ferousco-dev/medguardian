class RiskScore {
  const RiskScore({
    required this.score,
    required this.band,
    required this.factors,
    required this.calculatedAt,
    this.previousScore,
  });

  final int score;
  final RiskBand band;
  final List<RiskFactor> factors;
  final DateTime calculatedAt;
  final int? previousScore;

  int? get delta => previousScore == null ? null : score - previousScore!;

  factory RiskScore.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw =
        (json['factors'] as List<dynamic>?) ?? const <dynamic>[];
    return RiskScore(
      score: (json['score'] as num).round(),
      band: RiskBand.fromApi(json['band'] as String?),
      factors: raw
          .map((dynamic e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
      previousScore: (json['previous_score'] as num?)?.round(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'score': score,
    'band': band.apiValue,
    'factors': factors.map((RiskFactor f) => f.toJson()).toList(),
    'calculated_at': calculatedAt.toIso8601String(),
    'previous_score': previousScore,
  };
}

class RiskFactor {
  const RiskFactor({
    required this.label,
    required this.impact,
    required this.direction,
    this.detail,
  });

  final String label;

  final int impact;

  final RiskDirection direction;
  final String? detail;

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      label: json['label'] as String? ?? '',
      impact: (json['impact'] as num?)?.round() ?? 0,
      direction: RiskDirection.fromApi(json['direction'] as String?),
      detail: json['detail'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'label': label,
    'impact': impact,
    'direction': direction.apiValue,
    'detail': detail,
  };
}

enum RiskDirection {
  raises('raises'),
  lowers('lowers'),
  neutral('neutral');

  const RiskDirection(this.apiValue);

  final String apiValue;

  static RiskDirection fromApi(String? value) {
    return RiskDirection.values.firstWhere(
      (RiskDirection direction) => direction.apiValue == value,
      orElse: () => RiskDirection.neutral,
    );
  }
}

enum RiskBand {
  low('low', 'Low risk'),
  moderate('moderate', 'Moderate risk'),
  high('high', 'High risk'),
  critical('critical', 'Critical risk');

  const RiskBand(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static RiskBand fromApi(String? value) {
    return RiskBand.values.firstWhere(
      (RiskBand band) => band.apiValue == value,
      orElse: () => RiskBand.low,
    );
  }

  static RiskBand fromScore(int score) {
    if (score >= 80) {
      return RiskBand.low;
    }
    if (score >= 60) {
      return RiskBand.moderate;
    }
    if (score >= 40) {
      return RiskBand.high;
    }
    return RiskBand.critical;
  }
}
