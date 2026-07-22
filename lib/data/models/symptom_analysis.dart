class SymptomAnalysis {
  const SymptomAnalysis({
    required this.id,
    required this.urgency,
    required this.summary,
    required this.extractedSymptoms,
    required this.possibleConditions,
    required this.nextSteps,
    required this.analysedAt,
    this.followUpQuestions = const <String>[],
    this.createdEventId,
  });

  final String id;
  final UrgencyLevel urgency;
  final String summary;
  final List<String> extractedSymptoms;
  final List<PossibleCondition> possibleConditions;
  final List<String> nextSteps;
  final List<String> followUpQuestions;
  final DateTime analysedAt;

  final String? createdEventId;

  bool get isEmergency => urgency == UrgencyLevel.emergency;

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysis(
      id: json['id'] as String,
      urgency: UrgencyLevel.fromApi(json['urgency'] as String?),
      summary: json['summary'] as String? ?? '',
      extractedSymptoms: _strings(json['extracted_symptoms']),
      possibleConditions:
          ((json['possible_conditions'] as List<dynamic>?) ?? const <dynamic>[])
              .map(
                (dynamic e) =>
                    PossibleCondition.fromJson(e as Map<String, dynamic>),
              )
              .toList(growable: false),
      nextSteps: _strings(json['next_steps']),
      followUpQuestions: _strings(json['follow_up_questions']),
      analysedAt: DateTime.parse(json['analysed_at'] as String),
      createdEventId: json['created_event_id'] as String?,
    );
  }

  static List<String> _strings(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }
}

class PossibleCondition {
  const PossibleCondition({
    required this.name,
    required this.likelihood,
    this.description,
    this.clinicalCode,
  });

  final String name;

  final double likelihood;

  final String? description;
  final String? clinicalCode;

  int get likelihoodPercent => (likelihood * 100).round();

  factory PossibleCondition.fromJson(Map<String, dynamic> json) {
    return PossibleCondition(
      name: json['name'] as String? ?? '',
      likelihood: (json['likelihood'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      clinicalCode: json['clinical_code'] as String?,
    );
  }
}

enum UrgencyLevel {
  selfCare('self_care', 'Self care'),
  routine('routine', 'See a doctor soon'),
  urgent('urgent', 'Seek care today'),
  emergency('emergency', 'Emergency');

  const UrgencyLevel(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static UrgencyLevel fromApi(String? value) {
    return UrgencyLevel.values.firstWhere(
      (UrgencyLevel level) => level.apiValue == value,
      orElse: () => UrgencyLevel.routine,
    );
  }
}
