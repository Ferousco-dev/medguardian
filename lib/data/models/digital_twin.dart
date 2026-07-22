class DigitalTwin {
  const DigitalTwin({
    required this.id,
    required this.did,
    required this.fullName,
    this.dateOfBirth,
    this.sex = BiologicalSex.undisclosed,
    this.heightCm,
    this.weightKg,
    this.bloodType,
    this.conditions = const <String>[],
    this.allergies = const <String>[],
    this.familyHistory = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  final String did;

  final String fullName;
  final DateTime? dateOfBirth;
  final BiologicalSex sex;
  final double? heightCm;
  final double? weightKg;
  final String? bloodType;

  final List<String> conditions;
  final List<String> allergies;
  final List<String> familyHistory;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  int? get age {
    final DateTime? birth = dateOfBirth;
    if (birth == null) {
      return null;
    }
    final DateTime now = DateTime.now();
    int years = now.year - birth.year;
    final bool hadBirthday =
        now.month > birth.month ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) {
      years -= 1;
    }
    return years;
  }

  double? get bmi {
    final double? height = heightCm;
    final double? weight = weightKg;
    if (height == null || weight == null || height <= 0) {
      return null;
    }
    final double metres = height / 100;
    return weight / (metres * metres);
  }

  String get shortDid {
    final List<String> parts = did.split(':');
    if (parts.length < 2) {
      return did;
    }
    final String tail = parts.last;
    final String trimmed = tail.length > 4 ? tail.substring(0, 4) : tail;
    return '${parts.take(parts.length - 1).join(':')}:$trimmed';
  }

  factory DigitalTwin.fromJson(Map<String, dynamic> json) {
    return DigitalTwin(
      id: json['id'] as String,
      did: json['did'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: _parseDate(json['date_of_birth']),
      sex: BiologicalSex.fromApi(json['sex'] as String?),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      bloodType: json['blood_type'] as String?,
      conditions: _stringList(json['conditions']),
      allergies: _stringList(json['allergies']),
      familyHistory: _stringList(json['family_history']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'did': did,
    'full_name': fullName,
    'date_of_birth': dateOfBirth?.toIso8601String(),
    'sex': sex.apiValue,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'blood_type': bloodType,
    'conditions': conditions,
    'allergies': allergies,
    'family_history': familyHistory,
  };

  DigitalTwin copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    BiologicalSex? sex,
    double? heightCm,
    double? weightKg,
    String? bloodType,
    List<String>? conditions,
    List<String>? allergies,
    List<String>? familyHistory,
  }) {
    return DigitalTwin(
      id: id,
      did: did,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bloodType: bloodType ?? this.bloodType,
      conditions: conditions ?? this.conditions,
      allergies: allergies ?? this.allergies,
      familyHistory: familyHistory ?? this.familyHistory,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  static DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;
}

enum BiologicalSex {
  female('female', 'Female'),
  male('male', 'Male'),
  intersex('intersex', 'Intersex'),
  undisclosed('undisclosed', 'Prefer not to say');

  const BiologicalSex(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static BiologicalSex fromApi(String? value) {
    return BiologicalSex.values.firstWhere(
      (BiologicalSex sex) => sex.apiValue == value,
      orElse: () => BiologicalSex.undisclosed,
    );
  }
}
