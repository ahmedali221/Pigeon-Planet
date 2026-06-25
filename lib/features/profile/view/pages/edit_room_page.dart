import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/profile_model.dart';
import '../../viewmodel/profile_bloc.dart';
import '../../../../l10n/app_localizations.dart';

class EditRoomPage extends StatefulWidget {
  final ProfileModel room;

  const EditRoomPage({super.key, required this.room});

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameCtrl;
  late String _selectedCountry;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController(text: widget.room.nickname ?? '');
    _selectedCountry = widget.room.country.isNotEmpty
        ? widget.room.country
        : ProfileModel.countryCodes.first;
    _selectedCurrency = widget.room.currency.isNotEmpty
        ? widget.room.currency
        : ProfileModel.countryCurrency[_selectedCountry] ?? '';
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.room.copyWith(
      nickname: _nicknameCtrl.text.trim(),
      country: _selectedCountry,
      currency: _selectedCurrency,
    );
    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.status == ProfileStatus.updated ||
          (curr.status == ProfileStatus.error &&
              prev.status == ProfileStatus.updating),
      listener: (context, state) {
        if (state.status == ProfileStatus.updated) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الغرفة بنجاح'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppLocalizations.of(context).errorOccurred4),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      buildWhen: (prev, curr) => curr.status != prev.status,
      builder: (context, state) {
        final isLoading = state.status == ProfileStatus.updating;
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(title: AppLocalizations.of(context).edit2),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(AppLocalizations.of(context).rooms3),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nicknameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecor(AppLocalizations.of(context).mthalHmamAlzajlAlthhby2),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return AppLocalizations.of(context).rooms4;
                      if (v.trim().length < 3) return AppLocalizations.of(context).no18;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _label(AppLocalizations.of(context).aldwla),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCountry,
                    decoration: _inputDecor(''),
                    items: ProfileModel.countryCodes
                        .map((code) => DropdownMenuItem(
                              value: code,
                              child: Text(
                                ProfileModel.countryCurrency.containsKey(code)
                                    ? '$code — ${ProfileModel.countryCurrency[code]}'
                                    : code,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _selectedCountry = val;
                        _selectedCurrency =
                            ProfileModel.countryCurrency[val] ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'حفظ التعديلات',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      );
}
