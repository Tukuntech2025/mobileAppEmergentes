import 'package:flutter/material.dart';

class LanguageManager {
  static final LanguageManager instance = LanguageManager._internal();
  LanguageManager._internal();

  final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(const Locale('en'));

  Locale get currentLocale => localeNotifier.value;

  void setLocale(Locale locale) {
    if (locale.languageCode == 'en' || locale.languageCode == 'es') {
      localeNotifier.value = locale;
    }
  }

  void toggleLanguage() {
    if (localeNotifier.value.languageCode == 'en') {
      localeNotifier.value = const Locale('es');
    } else {
      localeNotifier.value = const Locale('en');
    }
  }
}
