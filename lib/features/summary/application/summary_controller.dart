import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/clinical_summary.dart';

class SummaryController extends AutoDisposeAsyncNotifier<ClinicalSummary?> {
  @override
  Future<ClinicalSummary?> build() async => null;

  Future<void> generate() async {
    state = const AsyncValue<ClinicalSummary?>.loading();
    state = await AsyncValue.guard<ClinicalSummary?>(
      () => ref.read(careRepositoryProvider).generateClinicalSummary(),
    );
  }
}

final AutoDisposeAsyncNotifierProvider<SummaryController, ClinicalSummary?>
summaryControllerProvider =
    AsyncNotifierProvider.autoDispose<SummaryController, ClinicalSummary?>(
      SummaryController.new,
    );

final AutoDisposeFutureProviderFamily<AccessGrant, int> accessGrantProvider =
    FutureProvider.autoDispose.family<AccessGrant, int>((Ref ref, int hours) {
      return ref
          .read(careRepositoryProvider)
          .grantAccess(Duration(hours: hours));
    });
