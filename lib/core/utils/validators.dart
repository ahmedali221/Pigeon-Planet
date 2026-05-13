import '../constants/app_strings.dart';

class AppValidators {
  AppValidators._();

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final regex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    if (value.length < 6) return AppStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    if (value != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final digits = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (digits.length < 9) return AppStrings.invalidPhone;
    return null;
  }
}
