import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../auth/application/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _hold = Duration(milliseconds: 1800);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _scheduleNext();
  }

  Future<void> _scheduleNext() async {
    final List<Object?> results = await Future.wait(<Future<Object?>>[
      Future<void>.delayed(_hold),
      ref.read(authControllerProvider.future),
    ]);

    if (!mounted) {
      return;
    }

    final bool isSignedIn = results[1] != null;
    context.go(isSignedIn ? Routes.dashboard : Routes.onboarding);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _rise,
                child: Column(
                  children: <Widget>[
                    const BrandMark(size: 84),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('MedGuardian', style: text.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Your health, watched over', style: text.bodyMedium),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Text(
                'Powered by Ontomorph Digital Twin',
                style: text.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
