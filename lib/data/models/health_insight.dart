class HealthInsight {
  const HealthInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.generatedAt,
    this.recommendation,
    this.relatedBiomarker,
  });

  final String id;
  final String title;
  final String body;
  final InsightSeverity severity;
  final DateTime generatedAt;
  final String? recommendation;
  final String? relatedBiomarker;

  factory HealthInsight.fromJson(Map<String, dynamic> json) {
    return HealthInsight(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      severity: InsightSeverity.fromApi(json['severity'] as String?),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      recommendation: json['recommendation'] as String?,
      relatedBiomarker: json['related_biomarker'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'severity': severity.apiValue,
    'generated_at': generatedAt.toIso8601String(),
    'recommendation': recommendation,
    'related_biomarker': relatedBiomarker,
  };
}

enum InsightSeverity {
  positive('positive'),
  informational('informational'),
  watch('watch'),
  urgent('urgent');

  const InsightSeverity(this.apiValue);

  final String apiValue;

  static InsightSeverity fromApi(String? value) {
    return InsightSeverity.values.firstWhere(
      (InsightSeverity severity) => severity.apiValue == value,
      orElse: () => InsightSeverity.informational,
    );
  }
}
