import 'package:flutter_test/flutter_test.dart';
import 'package:medguardian/data/models/digital_twin.dart';
import 'package:medguardian/features/twin/domain/twin_completion.dart';

void main() {
  const DigitalTwin bare = DigitalTwin(
    id: 'twin_1',
    did: 'did:dtp:aaaa',
    fullName: 'Ada Okoro',
  );

  test('a name-only twin counts one of nine', () {
    final TwinCompletion completion = TwinCompletion.of(bare);

    expect(completion.completed, 1);
    expect(completion.isComplete, isFalse);
    expect(completion.missing, contains(CompletionStep.dateOfBirth));
    expect(completion.missing, isNot(contains(CompletionStep.name)));
  });

  test('the first missing step is offered next', () {
    expect(TwinCompletion.of(bare).next, CompletionStep.dateOfBirth);
  });

  test('percent tracks the fields that are filled', () {
    final DigitalTwin partial = bare.copyWith(
      dateOfBirth: DateTime(1994, 3, 17),
      sex: BiologicalSex.female,
      heightCm: 168,
      weightKg: 63,
    );

    expect(TwinCompletion.of(partial).completed, 5);
    expect(TwinCompletion.of(partial).percent, 56);
  });

  test('a fully filled twin is complete and has no next step', () {
    final DigitalTwin full = bare.copyWith(
      dateOfBirth: DateTime(1994, 3, 17),
      sex: BiologicalSex.female,
      heightCm: 168,
      weightKg: 63,
      bloodType: 'O+',
      conditions: <String>['Prediabetes'],
      allergies: <String>['Penicillin'],
      familyHistory: <String>['Hypertension (father)'],
    );

    final TwinCompletion completion = TwinCompletion.of(full);

    expect(completion.isComplete, isTrue);
    expect(completion.percent, 100);
    expect(completion.next, isNull);
  });

  test('a zero height does not count as filled', () {
    expect(
      TwinCompletion.of(bare.copyWith(heightCm: 0)).missing,
      contains(CompletionStep.height),
    );
  });
}
