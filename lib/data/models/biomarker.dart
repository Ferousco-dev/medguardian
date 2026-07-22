class Biomarker {
  const Biomarker({
    required this.code,
    required this.name,
    required this.unit,
    required this.readings,
    this.referenceLow,
    this.referenceHigh,
    this.trend = BiomarkerTrend.stable,
  });

  final String code;

  final String name;
  final String unit;

  final List<BiomarkerReading> readings;

  final double? referenceLow;
  final double? referenceHigh;
  final BiomarkerTrend trend;

  BiomarkerReading? get latest => readings.isEmpty ? null : readings.last;

  BiomarkerReading? get previous =>
      readings.length < 2 ? null : readings[readings.length - 2];

  double? get delta {
    final BiomarkerReading? last = latest;
    final BiomarkerReading? prior = previous;
    if (last == null || prior == null) {
      return null;
    }
    return last.value - prior.value;
  }

  bool get isOutOfRange {
    final BiomarkerReading? last = latest;
    if (last == null) {
      return false;
    }
    if (referenceLow != null && last.value < referenceLow!) {
      return true;
    }
    if (referenceHigh != null && last.value > referenceHigh!) {
      return true;
    }
    return false;
  }

  factory Biomarker.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw =
        (json['readings'] as List<dynamic>?) ?? const <dynamic>[];
    return Biomarker(
      code: json['code'] as String,
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      readings: raw
          .map(
            (dynamic e) => BiomarkerReading.fromJson(e as Map<String, dynamic>),
          )
          .toList(growable: false),
      referenceLow: (json['reference_low'] as num?)?.toDouble(),
      referenceHigh: (json['reference_high'] as num?)?.toDouble(),
      trend: BiomarkerTrend.fromApi(json['trend'] as String?),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'name': name,
    'unit': unit,
    'readings': readings.map((BiomarkerReading r) => r.toJson()).toList(),
    'reference_low': referenceLow,
    'reference_high': referenceHigh,
    'trend': trend.apiValue,
  };
}

class BiomarkerReading {
  const BiomarkerReading({
    required this.value,
    required this.recordedAt,
    this.source,
  });

  final double value;
  final DateTime recordedAt;

  final String? source;

  factory BiomarkerReading.fromJson(Map<String, dynamic> json) {
    return BiomarkerReading(
      value: (json['value'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'value': value,
    'recorded_at': recordedAt.toIso8601String(),
    'source': source,
  };
}

enum BiomarkerTrend {
  improving('improving', 'Improving'),
  stable('stable', 'Stable'),
  worsening('worsening', 'Worsening');

  const BiomarkerTrend(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static BiomarkerTrend fromApi(String? value) {
    return BiomarkerTrend.values.firstWhere(
      (BiomarkerTrend trend) => trend.apiValue == value,
      orElse: () => BiomarkerTrend.stable,
    );
  }
}
