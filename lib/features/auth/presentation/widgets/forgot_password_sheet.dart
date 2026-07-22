import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../domain/validators.dart';

class ForgotPasswordSheet extends ConsumerStatefulWidget {
  const ForgotPasswordSheet({super.key, this.initialEmail = ''});

  final String initialEmail;

  static Future<void> show(BuildContext context, {String initialEmail = ''}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (BuildContext context) =>
          ForgotPasswordSheet(initialEmail: initialEmail),
    );
  }

  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );

  bool _isSending = false;
  bool _isSent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSending = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(_email.text.trim());
      if (mounted) {
        setState(() => _isSent = true);
      }
    } catch (error) {
      if (mounted) {
        AppSnack.error(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        right: AppSpacing.page,
        top: AppSpacing.xl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_isSent) ...<Widget>[
            Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(
                color: AppColors.successTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 21,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Check your email', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'If ${_email.text.trim()} has an account, a reset link is on its '
              'way. It expires in 30 minutes.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ] else ...<Widget>[
            Text('Reset your password', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter the email on your account and we will send you a link to '
              'set a new password.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Form(
              key: _formKey,
              child: AppTextField(
                label: 'Email address',
                controller: _email,
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: _isSending ? null : _submit,
              child: _isSending
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Send reset link'),
            ),
          ],
        ],
      ),
    );
  }
}
