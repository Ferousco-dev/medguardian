import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final Widget? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
      error: (Object error, StackTrace _) =>
          ErrorState(error: error, onRetry: onRetry),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  ApiException get _failure => error is ApiException
      ? error as ApiException
      : const ApiException(
          title: 'Something went wrong',
          message: 'That did not work. Please try again.',
        );

  IconData get _icon => switch (_failure.kind) {
    ApiErrorKind.network => Icons.wifi_off_rounded,
    ApiErrorKind.timeout => Icons.hourglass_empty_rounded,
    ApiErrorKind.unauthorised => Icons.lock_outline_rounded,
    ApiErrorKind.forbidden => Icons.block_rounded,
    ApiErrorKind.notFound => Icons.search_off_rounded,
    ApiErrorKind.validation => Icons.edit_note_rounded,
    ApiErrorKind.rateLimited => Icons.timer_outlined,
    ApiErrorKind.server => Icons.cloud_off_rounded,
    ApiErrorKind.cancelled => Icons.cancel_outlined,
    ApiErrorKind.unknown => Icons.error_outline_rounded,
  };

  bool get _canRetry =>
      onRetry != null &&
      _failure.kind != ApiErrorKind.forbidden &&
      _failure.kind != ApiErrorKind.unauthorised;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 24, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _failure.title ?? 'Something went wrong',
              style: text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _failure.message,
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (_canRetry) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (body != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(body!, style: text.bodyMedium, textAlign: TextAlign.center),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class AppSnack {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                size: 18,
                color: isError ? AppColors.dangerTint : AppColors.successTint,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(message)),
            ],
          ),
          duration: Duration(seconds: isError ? 5 : 3),
        ),
      );
  }

  static void error(BuildContext context, Object error) {
    final String message = error is ApiException
        ? error.message
        : 'That did not work. Please try again.';
    show(context, message, isError: true);
  }

  const AppSnack._();
}
