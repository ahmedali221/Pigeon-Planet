import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../viewmodel/auth_bloc.dart';
import '../../../home/view/pages/home_page.dart';
import '../widgets/app_text_field.dart';
import '../widgets/avatar_picker_widget.dart';
import '../widgets/country_city_picker.dart';
import '../widgets/register_header.dart';

class RegisterProviderPage extends StatefulWidget {
  RegisterProviderPage({super.key});

  @override
  State<RegisterProviderPage> createState() => _RegisterProviderPageState();
}

class _RegisterProviderPageState extends State<RegisterProviderPage> {
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
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_country.isEmpty) {
      _showError(context, l.country);
      return;
    }
    if (!_agreedToTerms) {
      _showError(context, l.mustAgreeToTerms);
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterProviderRequested(
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PPWAppBar(
        title: l.sellerMode,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.registerSuccess),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
                (_) => false,
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
                      title: l.sellerMode,
                      subtitle: l.serviceProviderSubtitle,
                    ),

                    const SizedBox(height: 20),

                    AvatarPickerWidget(
                      onChanged: (path) =>
                          setState(() => _avatarPath = path),
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      label: l.username,
                      hint: l.usernameHint,
                      controller: _usernameCtrl,
                      keyboardType: TextInputType.text,
                      validator: AppValidators.username,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: l.phoneNumber,
                      hint: '+20 1xx xxx xxxx',
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
                      label: l.password,
                      hint: l.passwordHint,
                      controller: _passwordCtrl,
                      validator: AppValidators.password,
                    ),

                    const SizedBox(height: 16),

                    AppPasswordField(
                      label: l.confirmPassword,
                      hint: l.confirmPasswordHint,
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
                            : Text(l.register),
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
