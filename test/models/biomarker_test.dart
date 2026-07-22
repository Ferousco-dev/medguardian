import 'package:flutter_test/flutter_test.dart';
import 'package:medguardian/data/models/biomarker.dart';

void main() {
  Biomarker glucose(List<double> values) {
    return Biomarker(
      loincCode: '1558-6',
      code: 'blood_glucose',
      name: 'Blood glucose',
      unit: 'mg/dL',
      referenceLow: 70,
      referenceHigh: 99,
      readings: <BiomarkerReading>[
        for (int i = 0; i < values.length; i++)
          BiomarkerReading(
            value: values[i],
            recordedAt: DateTime(2026, 1, i + 1),
          ),
      ],
    );
  }

  test('latest is the most recent reading', () {
    expect(glucose(<double>[88, 94, 102]).latest?.value, 102);
  });

  test('delta compares the last two readings', () {
    expect(glucose(<double>[88, 94, 102]).delta, 8);
  });

  test('delta is null with a single reading', () {
    expect(glucose(<double>[88]).delta, isNull);
  });

  test('flags a reading above the reference range', () {
    expect(glucose(<double>[88, 102]).isOutOfRange, isTrue);
  });

  test('flags a reading below the reference range', () {
    expect(glucose(<double>[88, 64]).isOutOfRange, isTrue);
  });

  test('does not flag a reading inside the reference range', () {
    expect(glucose(<double>[88, 92]).isOutOfRange, isFalse);
  });

  test('an empty series is not out of range', () {
    expect(glucose(<double>[]).isOutOfRange, isFalse);
    expect(glucose(<double>[]).latest, isNull);
  });

  test('round trips through json', () {
    final Biomarker decoded = Biomarker.fromJson(
      glucose(<double>[88, 94]).toJson(),
    );

    expect(decoded.code, 'blood_glucose');
    expect(decoded.loincCode, '1558-6');
    expect(decoded.readings, hasLength(2));
    expect(decoded.readings.last.value, 94);
  });
}
