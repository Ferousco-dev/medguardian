import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/auth_controller.dart';
import '../domain/validators.dart';
import 'widgets/auth_header.dart';
import 'widgets/forgot_password_sheet.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscured = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool success = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text.trim(), password: _password.text);

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(Routes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool isBusy = ref.watch(authControllerProvider).isLoading;

    ref.listen(authControllerProvider, (_, AsyncValue<Object?> next) {
      if (next.hasError && !next.isLoading) {
        AppSnack.error(context, next.error!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.huge),
                  const AuthHeader(
                    title: 'Welcome back',
                    subtitle: 'Sign in to open your digital twin.',
                  ),
                  const SizedBox(height: AppSpacing.huge),
                  AppTextField(
                    label: 'Email address',
                    controller: _email,
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    autofillHints: const <String>[AutofillHints.email],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: 'Password',
                    controller: _password,
                    obscureText: _obscured,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                    autofillHints: const <String>[AutofillHints.password],
                    suffix: IconButton(
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => ForgotPasswordSheet.show(
                        context,
                        initialEmail: _email.text.trim(),
                      ),
                      child: const Text('Forgot password'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: isBusy ? null : _submit,
                    child: isBusy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('New to MedGuardian?', style: text.bodyMedium),
                        TextButton(
                          onPressed: () => context.push(Routes.signUp),
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
