import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.splash,
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: Routes.onboarding,
      builder: (BuildContext context, GoRouterState state) =>
          const OnboardingScreen(),
    ),
  ],
);
