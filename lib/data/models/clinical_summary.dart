import 'biomarker.dart';
import 'health_event.dart';
import 'medication.dart';

class ClinicalSummary {
  const ClinicalSummary({
    required this.id,
    required this.generatedAt,
    required this.patientName,
    required this.patientAge,
    required this.overview,
    required this.activeProblems,
    required this.recentEvents,
    required this.medications,
    required this.biomarkers,
    required this.recommendations,
  });

  final String id;
  final DateTime generatedAt;
  final String patientName;
  final int patientAge;
  final String overview;
  final List<String> activeProblems;
  final List<HealthEvent> recentEvents;
  final List<Medication> medications;
  final List<Biomarker> biomarkers;
  final List<String> recommendations;

  factory ClinicalSummary.fromJson(Map<String, dynamic> json) {
    List<dynamic> list(String key) =>
        (json[key] as List<dynamic>?) ?? const <dynamic>[];

    return ClinicalSummary(
      id: json['id'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      patientName: json['patient_name'] as String? ?? '',
      patientAge: (json['patient_age'] as num?)?.round() ?? 0,
      overview: json['overview'] as String? ?? '',
      activeProblems: list(
        'active_problems',
      ).map((dynamic e) => e.toString()).toList(growable: false),
      recentEvents: list('recent_events')
          .map((dynamic e) => HealthEvent.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      medications: list('medications')
          .map((dynamic e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      biomarkers: list('biomarkers')
          .map((dynamic e) => Biomarker.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      recommendations: list(
        'recommendations',
      ).map((dynamic e) => e.toString()).toList(growable: false),
    );
  }
}

class AccessGrant {
  const AccessGrant({
    required this.id,
    required this.code,
    required this.expiresAt,
    this.grantedTo,
  });

  final String id;
  final String code;
  final DateTime expiresAt;
  final String? grantedTo;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining => expiresAt.difference(DateTime.now());

  factory AccessGrant.fromJson(Map<String, dynamic> json) {
    return AccessGrant(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      grantedTo: json['granted_to'] as String?,
    );
  }
}
