import '../../../data/models/digital_twin.dart';

enum CompletionStep {
  name('Your name', 'Needed on your clinical summary'),
  dateOfBirth('Date of birth', 'Age changes what your risk score means'),
  sex('Sex at birth', 'Affects reference ranges for several biomarkers'),
  height('Height', 'Needed to calculate your BMI'),
  weight('Weight', 'Needed to calculate your BMI'),
  bloodType('Blood type', 'Shown on your emergency card'),
  conditions('Existing conditions', 'Improves how symptoms are interpreted'),
  allergies('Allergies', 'Checked against every medication you log'),
  familyHistory('Family history', 'Feeds inherited risk into your score');

  const CompletionStep(this.label, this.why);

  final String label;
  final String why;
}

class TwinCompletion {
  const TwinCompletion({required this.missing});

  final List<CompletionStep> missing;

  static const int _total = 9;

  factory TwinCompletion.of(DigitalTwin twin) {
    return TwinCompletion(
      missing: <CompletionStep>[
        if (twin.fullName.trim().isEmpty) CompletionStep.name,
        if (twin.dateOfBirth == null) CompletionStep.dateOfBirth,
        if (twin.sex == BiologicalSex.undisclosed) CompletionStep.sex,
        if (twin.heightCm == null || twin.heightCm! <= 0) CompletionStep.height,
        if (twin.weightKg == null || twin.weightKg! <= 0) CompletionStep.weight,
        if ((twin.bloodType ?? '').isEmpty) CompletionStep.bloodType,
        if (twin.conditions.isEmpty) CompletionStep.conditions,
        if (twin.allergies.isEmpty) CompletionStep.allergies,
        if (twin.familyHistory.isEmpty) CompletionStep.familyHistory,
      ],
    );
  }

  int get completed => _total - missing.length;

  double get fraction => completed / _total;

  int get percent => (fraction * 100).round();

  bool get isComplete => missing.isEmpty;

  CompletionStep? get next => missing.isEmpty ? null : missing.first;

  String get headline {
    if (isComplete) {
      return 'Your twin is complete';
    }
    if (percent >= 70) {
      return 'Almost there';
    }
    if (percent >= 40) {
      return 'Good start';
    }
    return 'Your twin needs more to work with';
  }
}
