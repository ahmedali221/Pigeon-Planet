import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodel/auth_bloc.dart';
import '../widgets/app_text_field.dart';
import '../widgets/country_city_picker.dart';
import '../widgets/register_header.dart';
import 'otp_page.dart';

class RegisterProviderPage extends StatefulWidget {
  const RegisterProviderPage({super.key});

  @override
  State<RegisterProviderPage> createState() => _RegisterProviderPageState();
}

class _RegisterProviderPageState extends State<RegisterProviderPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _country = '';
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_country.isEmpty) {
      _showError(context, 'يرجى اختيار الدولة');
      return;
    }
    if (!_agreedToTerms) {
      _showError(context, AppStrings.mustAgreeToTerms);
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterProviderRequested(
            phoneNumber: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text,
            country: _country,
          ),
        );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            AppStrings.serviceProvider,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthOtpRequired) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AuthBloc>(),
                    child: OtpPage(phone: state.phoneNumber),
                  ),
                ),
              );
            }
            if (state is AuthFailure) {
              _showError(context, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    RegisterHeader(
                      icon: Icons.work_rounded,
                      color: AppColors.orange,
                      title: AppStrings.serviceProvider,
                      subtitle: AppStrings.serviceProviderSub,
                    ),

                    const SizedBox(height: 24),

                    AppTextField(
                      label: AppStrings.phoneNumber,
                      hint: AppStrings.phoneHint,
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: AppValidators.phone,
                    ),

                    const SizedBox(height: 16),

                    CountryCityPicker(
                      onChanged: (country, _) =>
                          setState(() => _country = country),
                    ),

                    const SizedBox(height: 16),

                    AppPasswordField(
                      label: AppStrings.password,
                      hint: AppStrings.passwordHint,
                      controller: _passwordCtrl,
                      validator: AppValidators.password,
                    ),

                    const SizedBox(height: 16),

                    AppPasswordField(
                      label: AppStrings.confirmPassword,
                      hint: AppStrings.confirmPasswordHint,
                      controller: _confirmPasswordCtrl,
                      validator: (v) => AppValidators.confirmPassword(
                        v,
                        _passwordCtrl.text,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TermsCheckbox(
                      value: _agreedToTerms,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),

                    const SizedBox(height: 24),

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
                            : const Text(AppStrings.createAccount),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
