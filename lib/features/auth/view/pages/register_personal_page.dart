import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodel/auth_bloc.dart';
import '../widgets/app_text_field.dart';
import '../widgets/avatar_picker_widget.dart';
import '../widgets/country_city_picker.dart';
import '../widgets/register_header.dart';
import 'otp_page.dart';

class RegisterPersonalPage extends StatefulWidget {
  const RegisterPersonalPage({super.key});

  @override
  State<RegisterPersonalPage> createState() => _RegisterPersonalPageState();
}

class _RegisterPersonalPageState extends State<RegisterPersonalPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _country = '';
  String? _avatarPath;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
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
          AuthRegisterPersonalRequested(
            username: _usernameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text,
            country: _country,
            avatarPath: _avatarPath,
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          AppStrings.personalAccount,
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
                      icon: Icons.person_rounded,
                      color: AppColors.primary,
                      title: AppStrings.personalAccount,
                      subtitle: AppStrings.personalAccountSub,
                    ),

                    const SizedBox(height: 20),

                    AvatarPickerWidget(
                      onChanged: (path) =>
                          setState(() => _avatarPath = path),
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      label: AppStrings.username,
                      hint: AppStrings.usernameHint,
                      controller: _usernameCtrl,
                      keyboardType: TextInputType.text,
                      validator: AppValidators.username,
                    ),

                    const SizedBox(height: 16),

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
      );
  }
}
