import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../application/auth_controller.dart';
import '../domain/validators.dart';
import 'widgets/auth_header.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscured = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Accept the terms to continue.')),
        );
      return;
    }

    final bool success = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      context.go(Routes.profileSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool isBusy = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: AppSpacing.lg),
                const AuthHeader(
                  title: 'Create your account',
                  subtitle:
                      'This is the first step towards your digital health twin.',
                ),
                const SizedBox(height: AppSpacing.huge),
                AppTextField(
                  label: 'Full name',
                  controller: _name,
                  hintText: 'Ada Okoro',
                  textInputAction: TextInputAction.next,
                  validator: Validators.fullName,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Email address',
                  controller: _email,
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Password',
                  controller: _password,
                  hintText: 'At least 8 characters',
                  obscureText: _obscured,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
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
                const SizedBox(height: AppSpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox.square(
                      dimension: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (bool? value) =>
                            setState(() => _acceptedTerms = value ?? false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'I understand MedGuardian gives health guidance, not '
                          'a medical diagnosis, and my records stay under my '
                          'control.',
                          style: text.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
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
                      : const Text('Create account'),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
