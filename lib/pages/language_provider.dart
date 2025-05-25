import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale('en'); // Langue par défaut

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'fr', 'ar'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}
