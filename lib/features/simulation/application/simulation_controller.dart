import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/health_simulation.dart';

class SimulationController extends AutoDisposeAsyncNotifier<HealthSimulation?> {
  @override
  Future<HealthSimulation?> build() async => null;

  Future<void> run(String question) async {
    state = const AsyncValue<HealthSimulation?>.loading();
    state = await AsyncValue.guard<HealthSimulation?>(
      () => ref.read(intelligenceRepositoryProvider).runSimulation(question),
    );
  }

  void reset() {
    state = const AsyncValue<HealthSimulation?>.data(null);
  }
}

final AutoDisposeAsyncNotifierProvider<SimulationController, HealthSimulation?>
simulationControllerProvider =
    AsyncNotifierProvider.autoDispose<SimulationController, HealthSimulation?>(
      SimulationController.new,
    );
