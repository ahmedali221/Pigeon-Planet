import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodel/auth_bloc.dart';
import '../widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _DemoAccount {
  const _DemoAccount({required this.label, required this.phone, required this.role});
  final String label;
  final String phone;
  final String role;
}

const _demoAccounts = [
  _DemoAccount(label: 'عميل 1 — EG Pigeons', phone: '+201000000001', role: 'customer'),
  _DemoAccount(label: 'عميل 2 — Gulf Wings', phone: '+201000000002', role: 'customer'),
  _DemoAccount(label: 'عميل 5 — Doha Pigeons', phone: '+201000000005', role: 'customer'),
  _DemoAccount(label: 'بائع 1 — EG Pigeons', phone: '+201000000001', role: 'seller'),
  _DemoAccount(label: 'بائع 2 — Gulf Wings', phone: '+201000000002', role: 'seller'),
  _DemoAccount(label: 'بائع 5 — Doha Pigeons', phone: '+201000000005', role: 'seller'),
];

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController(text: '+201000000001');
  final _passwordCtrl = TextEditingController(text: 'Test@1234');

  void _fillDemo(_DemoAccount account) {
    _phoneCtrl.text = account.phone;
    _passwordCtrl.text = 'Test@1234';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        phoneNumber: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PPWAppBar(
        title: AppStrings.login,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.loginSuccess),
                backgroundColor: AppColors.success,
              ),
            );
            context.go(AppRoutes.home);
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.login,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.welcomeBack,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  AppTextField(
                    label: AppStrings.phoneNumber,
                    hint: AppStrings.phoneHint,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: AppValidators.phone,
                  ),

                  const SizedBox(height: 18),

                  AppPasswordField(
                    label: AppStrings.password,
                    hint: AppStrings.passwordHint,
                    controller: _passwordCtrl,
                    validator: AppValidators.password,
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(AppStrings.login),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'حسابات تجريبية',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _demoAccounts.map((account) {
                      return OutlinedButton(
                        onPressed: () => _fillDemo(account),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: Text(account.label),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: '${AppStrings.noAccount} ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                AppStrings.createNewAccount,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
