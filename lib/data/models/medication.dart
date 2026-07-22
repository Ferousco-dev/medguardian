class Medication {
  const Medication({
    required this.id,
    required this.name,
    this.genericName,
    this.dosage,
    this.frequency,
    this.startedOn,
    this.endedOn,
    this.uses = const <String>[],
    this.sideEffects = const <String>[],
    this.interactions = const <String>[],
    this.warnings = const <String>[],
  });

  final String id;
  final String name;
  final String? genericName;
  final String? dosage;
  final String? frequency;
  final DateTime? startedOn;
  final DateTime? endedOn;

  final List<String> uses;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> warnings;

  bool get isActive => endedOn == null;

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      genericName: json['generic_name'] as String?,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      startedOn: _date(json['started_on']),
      endedOn: _date(json['ended_on']),
      uses: _strings(json['uses']),
      sideEffects: _strings(json['side_effects']),
      interactions: _strings(json['interactions']),
      warnings: _strings(json['warnings']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'generic_name': genericName,
    'dosage': dosage,
    'frequency': frequency,
    'started_on': startedOn?.toIso8601String(),
    'ended_on': endedOn?.toIso8601String(),
  };

  static DateTime? _date(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  static List<String> _strings(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }
}
