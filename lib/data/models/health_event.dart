class HealthEvent {
  const HealthEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.occurredAt,
    this.description,
    this.severity = EventSeverity.none,
    this.isHidden = false,
    this.clinicalCode,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final HealthEventType type;
  final String title;
  final DateTime occurredAt;
  final String? description;
  final EventSeverity severity;

  final bool isHidden;

  final String? clinicalCode;

  final Map<String, dynamic> metadata;

  factory HealthEvent.fromJson(Map<String, dynamic> json) {
    return HealthEvent(
      id: json['id'] as String,
      type: HealthEventType.fromApi(json['type'] as String?),
      title: json['title'] as String? ?? '',
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      description: json['description'] as String?,
      severity: EventSeverity.fromApi(json['severity'] as String?),
      isHidden: json['is_hidden'] as bool? ?? false,
      clinicalCode: json['clinical_code'] as String?,
      metadata:
          (json['metadata'] as Map<String, dynamic>?) ??
          const <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.apiValue,
    'title': title,
    'occurred_at': occurredAt.toIso8601String(),
    'description': description,
    'severity': severity.apiValue,
    'is_hidden': isHidden,
    'clinical_code': clinicalCode,
    'metadata': metadata,
  };

  HealthEvent copyWith({bool? isHidden}) {
    return HealthEvent(
      id: id,
      type: type,
      title: title,
      occurredAt: occurredAt,
      description: description,
      severity: severity,
      isHidden: isHidden ?? this.isHidden,
      clinicalCode: clinicalCode,
      metadata: metadata,
    );
  }
}

enum HealthEventType {
  symptom('symptom', 'Symptom'),
  diagnosis('diagnosis', 'Diagnosis'),
  medication('medication', 'Medication'),
  vaccination('vaccination', 'Vaccination'),
  labResult('lab_result', 'Lab result'),
  measurement('measurement', 'Measurement'),
  visit('visit', 'Visit'),
  procedure('procedure', 'Procedure'),
  allergy('allergy', 'Allergy'),
  note('note', 'Note');

  const HealthEventType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static HealthEventType fromApi(String? value) {
    return HealthEventType.values.firstWhere(
      (HealthEventType type) => type.apiValue == value,
      orElse: () => HealthEventType.note,
    );
  }
}

enum EventSeverity {
  none('none', 'Routine'),
  mild('mild', 'Mild'),
  moderate('moderate', 'Moderate'),
  severe('severe', 'Severe'),
  critical('critical', 'Critical');

  const EventSeverity(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static EventSeverity fromApi(String? value) {
    return EventSeverity.values.firstWhere(
      (EventSeverity severity) => severity.apiValue == value,
      orElse: () => EventSeverity.none,
    );
  }
}
