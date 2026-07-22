import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/health_event.dart';
import '../../../data/models/symptom_analysis.dart';

class SymptomController extends AutoDisposeAsyncNotifier<SymptomAnalysis?> {
  @override
  Future<SymptomAnalysis?> build() async => null;

  Future<void> analyse(String description) async {
    state = const AsyncValue<SymptomAnalysis?>.loading();

    state = await AsyncValue.guard<SymptomAnalysis?>(() async {
      final SymptomAnalysis analysis = await ref
          .read(intelligenceRepositoryProvider)
          .analyseSymptoms(description);

      await ref
          .read(twinRepositoryProvider)
          .createEvent(
            HealthEvent(
              id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
              type: HealthEventType.symptom,
              title: analysis.extractedSymptoms.isEmpty
                  ? description
                  : analysis.extractedSymptoms.first,
              description: description,
              occurredAt: DateTime.now(),
              severity: _severityFor(analysis.urgency),
            ),
          );

      ref
        ..invalidate(eventsProvider)
        ..invalidate(riskScoreProvider)
        ..invalidate(insightsProvider);

      return analysis;
    });
  }

  void reset() {
    state = const AsyncValue<SymptomAnalysis?>.data(null);
  }

  static EventSeverity _severityFor(UrgencyLevel urgency) => switch (urgency) {
    UrgencyLevel.selfCare => EventSeverity.mild,
    UrgencyLevel.routine => EventSeverity.mild,
    UrgencyLevel.urgent => EventSeverity.moderate,
    UrgencyLevel.emergency => EventSeverity.critical,
  };
}

final AutoDisposeAsyncNotifierProvider<SymptomController, SymptomAnalysis?>
symptomControllerProvider =
    AsyncNotifierProvider.autoDispose<SymptomController, SymptomAnalysis?>(
      SymptomController.new,
    );
