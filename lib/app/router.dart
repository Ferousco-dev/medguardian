import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/chat/presentation/health_chat_screen.dart';
import '../features/emergency/presentation/emergency_screen.dart';
import '../features/guides/presentation/guide_detail_screen.dart';
import '../features/guides/presentation/guides_screen.dart';
import '../features/hospitals/presentation/hospitals_screen.dart';
import '../features/medications/presentation/medications_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/risk/presentation/risk_score_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shell/presentation/home_shell.dart';
import '../features/simulation/presentation/simulation_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/summary/presentation/clinical_summary_screen.dart';
import '../features/symptoms/presentation/symptom_check_screen.dart';
import '../features/twin/presentation/health_setup_screen.dart';
import 'routes.dart';

GoRoute _route(String path, Widget Function() builder) {
  return GoRoute(
    path: path,
    builder: (BuildContext context, GoRouterState state) => builder(),
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: <RouteBase>[
    _route(Routes.splash, SplashScreen.new),
    _route(Routes.onboarding, OnboardingScreen.new),

    _route(Routes.signIn, SignInScreen.new),
    _route(Routes.signUp, SignUpScreen.new),
    _route(Routes.healthSetup, HealthSetupScreen.new),
    _route(
      Routes.healthSetupEdit,
      () => const HealthSetupScreen(isEditing: true),
    ),

    _route(Routes.dashboard, HomeShell.new),
    _route(Routes.settings, SettingsScreen.new),

    _route(Routes.symptomCheck, SymptomCheckScreen.new),
    _route(Routes.healthChat, HealthChatScreen.new),
    _route(Routes.simulation, SimulationScreen.new),
    _route(Routes.riskScore, RiskScoreScreen.new),
    _route(Routes.medications, MedicationsScreen.new),
    _route(Routes.emergency, EmergencyScreen.new),
    _route(Routes.hospitals, HospitalsScreen.new),
    _route(Routes.clinicalSummary, ClinicalSummaryScreen.new),
    GoRoute(
      path: Routes.guides,
      builder: (BuildContext context, GoRouterState state) =>
          const GuidesScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          builder: (BuildContext context, GoRouterState state) =>
              GuideDetailScreen(guideId: state.pathParameters['id'] ?? ''),
        ),
      ],
    ),
  ],
);
