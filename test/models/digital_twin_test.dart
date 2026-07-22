import 'package:flutter_test/flutter_test.dart';
import 'package:medguardian/data/models/digital_twin.dart';

void main() {
  DigitalTwin twinBornOn(DateTime dateOfBirth) {
    return DigitalTwin(
      id: 'twin_1',
      did: 'did:dtp:8f2a4c19',
      fullName: 'Ada Okoro',
      dateOfBirth: dateOfBirth,
      sex: BiologicalSex.female,
      heightCm: 168,
      weightKg: 63,
    );
  }

  group('age', () {
    test('does not count a birthday that has not happened yet', () {
      final DateTime now = DateTime.now();
      final DigitalTwin twin = twinBornOn(
        DateTime(
          now.year - 30,
          now.month,
          now.day,
        ).add(const Duration(days: 1)),
      );

      expect(twin.age, 29);
    });

    test('counts the birthday on the day itself', () {
      final DateTime now = DateTime.now();
      final DigitalTwin twin = twinBornOn(
        DateTime(now.year - 30, now.month, now.day),
      );

      expect(twin.age, 30);
    });
  });

  test('bmi is derived from height and weight', () {
    final DigitalTwin twin = twinBornOn(DateTime(1995, 4, 2));

    expect(twin.bmi, closeTo(22.32, 0.01));
  });

  test('bmi is null when height is missing rather than infinite', () {
    final DigitalTwin twin = twinBornOn(
      DateTime(1995, 4, 2),
    ).copyWith(heightCm: 0);

    expect(twin.bmi, isNull);
  });

  test('age and bmi are null on a twin with no details yet', () {
    const DigitalTwin bare = DigitalTwin(
      id: 'twin_2',
      did: 'did:dtp:aaaa1111',
      fullName: 'New User',
    );

    expect(bare.age, isNull);
    expect(bare.bmi, isNull);
    expect(bare.sex, BiologicalSex.undisclosed);
  });

  test('shortDid truncates the identifier tail', () {
    expect(twinBornOn(DateTime(1995, 4, 2)).shortDid, 'did:dtp:8f2a');
  });

  test('round trips through json', () {
    final DigitalTwin twin = twinBornOn(DateTime(1995, 4, 2));
    final DigitalTwin decoded = DigitalTwin.fromJson(twin.toJson());

    expect(decoded.did, twin.did);
    expect(decoded.sex, twin.sex);
    expect(decoded.heightCm, twin.heightCm);
    expect(decoded.dateOfBirth, twin.dateOfBirth);
  });

  test('unknown sex values fall back to undisclosed', () {
    expect(BiologicalSex.fromApi('unknown'), BiologicalSex.undisclosed);
    expect(BiologicalSex.fromApi(null), BiologicalSex.undisclosed);
  });
}
