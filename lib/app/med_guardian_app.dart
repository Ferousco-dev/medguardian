import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class MedGuardianApp extends StatelessWidget {
  const MedGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MedGuardian',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
