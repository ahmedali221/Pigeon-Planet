import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/profile_model.dart';
import '../../viewmodel/profile_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameCtrl;
  late String _selectedCountry;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile!;
    _nicknameCtrl = TextEditingController(text: profile.nickname ?? '');
    _selectedCountry = profile.country.isNotEmpty
        ? profile.country
        : ProfileModel.countryCodes.first;
    _selectedCurrency = profile.currency.isNotEmpty
        ? profile.currency
        : ProfileModel.countryCurrency[_selectedCountry] ?? '';
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final profile = context.read<ProfileBloc>().state.profile!;
    final updated = profile.copyWith(
      nickname: profile.isSeller ? _nicknameCtrl.text.trim() : null,
      country: _selectedCountry,
      currency: _selectedCurrency,
    );
    context.read<ProfileBloc>().add(ProfileUpdateRequested(updated));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف الملف الشخصي'),
        content: Text(
          'هل أنت متأكد من حذف هذا الملف الشخصي؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).delete, style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProfileBloc>().add(ProfileDeleteRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          curr.status == ProfileStatus.updated ||
          curr.status == ProfileStatus.deleted ||
          (curr.status == ProfileStatus.error &&
              (prev.status == ProfileStatus.updating ||
                  prev.status == ProfileStatus.deleting)),
      listener: (context, state) {
        if (state.status == ProfileStatus.updated) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث الملف الشخصي'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (state.status == ProfileStatus.deleted) {
          Navigator.of(context)
            ..pop()
            ..pop();
          return;
        }
        if (state.status == ProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppLocalizations.of(context).errorOccurred),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isBusy =
            state.status == ProfileStatus.updating ||
            state.status == ProfileStatus.deleting;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(
            title: AppLocalizations.of(context).editProfile,
            actions: [
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile.isSeller) ...[
                    _sectionLabel('الاسم المعروض'),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nicknameCtrl,
                      enabled: !isBusy,
                      decoration: _inputDecoration(
                        hint: 'اسمك في المنصة',
                        icon: Icons.badge_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'الاسم مطلوب';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                  _sectionLabel(AppLocalizations.of(context).country),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCountry,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      hint: 'اختر دولتك',
                      icon: Icons.flag_outlined,
                    ),
                    items: ProfileModel.countryCodes.map((code) {
                      final name = _countryNameFor(code);
                      return DropdownMenuItem(
                        value: code,
                        child: Text('$name ($code)'),
                      );
                    }).toList(),
                    onChanged: isBusy
                        ? null
                        : (val) {
                            if (val == null) return;
                            setState(() {
                              _selectedCountry = val;
                              _selectedCurrency =
                                  ProfileModel.countryCurrency[val] ??
                                  _selectedCurrency;
                            });
                          },
                  ),
                  SizedBox(height: 20),
                  _sectionLabel('العملة'),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency.isNotEmpty
                        ? _selectedCurrency
                        : null,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      hint: 'اختر العملة',
                      icon: Icons.currency_exchange_outlined,
                    ),
                    items: ProfileModel.countryCurrency.values
                        .toSet()
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() => _selectedCurrency = val);
                            }
                          },
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isBusy && state.status == ProfileStatus.updating
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'حفظ التغييرات',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Divider(),
                  SizedBox(height: 16),
                  _sectionLabel('منطقة الخطر', color: Colors.red.shade700),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1.5,
                      ),
                      color: Colors.red.shade50,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade600,
                      ),
                      title: Text(
                        'حذف الملف الشخصي',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'سيتم تعطيل هذا الحساب نهائياً',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.red.shade400,
                      ),
                      onTap: isBusy ? null : () => _confirmDelete(context),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text, {Color? color}) => Text(
    text,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.textSecondary,
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

String _countryNameFor(String code) {
  final names = {
    'EG': 'مصر',
    'SA': 'السعودية',
    'AE': 'الإمارات',
    'KW': 'الكويت',
    'QA': 'قطر',
    'BH': 'البحرين',
    'OM': 'عُمان',
    'JO': 'الأردن',
    'IQ': 'العراق',
    'LB': 'لبنان',
    'SY': 'سوريا',
    'PS': 'فلسطين',
    'YE': 'اليمن',
    'MA': 'المغرب',
    'TN': 'تونس',
    'DZ': 'الجزائر',
    'LY': 'ليبيا',
    'SD': 'السودان',
    'TR': 'تركيا',
  };
  return names[code] ?? code;
}
