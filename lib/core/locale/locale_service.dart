import 'package:flutter/material.dart';

class LocaleService {
  LocaleService._();

  static final ValueNotifier<Locale> notifier =
      ValueNotifier<Locale>(const Locale('ar'));

  static bool get isArabic => notifier.value.languageCode == 'ar';

  static void toggle() {
    notifier.value =
        isArabic ? const Locale('en') : const Locale('ar');
  }

  static void setLocale(Locale locale) {
    notifier.value = locale;
  }
}
