import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_store.dart';
import '../data/models/biomarker.dart';
import '../data/models/digital_twin.dart';
import '../data/models/health_event.dart';
import '../data/models/health_insight.dart';
import '../data/models/hospital.dart';
import '../data/models/medication.dart';
import '../data/models/risk_score.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/care_repository.dart';
import '../data/repositories/intelligence_repository.dart';
import '../data/repositories/twin_repository.dart';

final Provider<TokenStore> tokenStoreProvider = Provider<TokenStore>(
  (Ref ref) => TokenStore(),
);

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (Ref ref) => ApiClient(tokenStore: ref.watch(tokenStoreProvider)),
);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
      if (AppConfig.useMockData) {
        return MockAuthRepository();
      }
      return RemoteAuthRepository(
        ref.watch(apiClientProvider),
        ref.watch(tokenStoreProvider),
      );
    });

final Provider<TwinRepository> twinRepositoryProvider =
    Provider<TwinRepository>((Ref ref) {
      if (AppConfig.useMockData) {
        return MockTwinRepository();
      }
      return RemoteTwinRepository(ref.watch(apiClientProvider));
    });

final Provider<IntelligenceRepository> intelligenceRepositoryProvider =
    Provider<IntelligenceRepository>((Ref ref) {
      if (AppConfig.useMockData) {
        return const MockIntelligenceRepository();
      }
      return RemoteIntelligenceRepository(ref.watch(apiClientProvider));
    });

final Provider<CareRepository> careRepositoryProvider =
    Provider<CareRepository>((Ref ref) {
      if (AppConfig.useMockData) {
        return const MockCareRepository();
      }
      return RemoteCareRepository(ref.watch(apiClientProvider));
    });

final FutureProvider<DigitalTwin> twinProvider = FutureProvider<DigitalTwin>(
  (Ref ref) => ref.watch(twinRepositoryProvider).fetchTwin(),
);

final FutureProvider<List<HealthEvent>> eventsProvider =
    FutureProvider<List<HealthEvent>>(
      (Ref ref) => ref.watch(twinRepositoryProvider).fetchEvents(),
    );

final FutureProvider<List<Biomarker>> biomarkersProvider =
    FutureProvider<List<Biomarker>>(
      (Ref ref) => ref.watch(twinRepositoryProvider).fetchBiomarkers(),
    );

final FutureProvider<RiskScore> riskScoreProvider = FutureProvider<RiskScore>(
  (Ref ref) => ref.watch(intelligenceRepositoryProvider).fetchRiskScore(),
);

final FutureProvider<List<HealthInsight>> insightsProvider =
    FutureProvider<List<HealthInsight>>(
      (Ref ref) => ref.watch(intelligenceRepositoryProvider).fetchInsights(),
    );

final FutureProvider<List<Medication>> medicationsProvider =
    FutureProvider<List<Medication>>(
      (Ref ref) => ref.watch(careRepositoryProvider).fetchMedications(),
    );

final FutureProvider<List<Hospital>> hospitalsProvider =
    FutureProvider<List<Hospital>>(
      (Ref ref) => ref.watch(careRepositoryProvider).fetchNearbyHospitals(),
    );
