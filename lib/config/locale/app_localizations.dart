import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/enums.dart';
import '../../injection_container.dart';
import 'app_localizations_delegate.dart';

class AppLocalizations {
  Locale? locale;
  AppLocalizations(this.locale);
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();
  late Map<String, String> _localizedStrings;

  Future<void> load({Locale? locale}) async {
    this.locale = locale ?? Locale(sharedPreferences.getLanguageCode().name);
    String jsonString = await rootBundle.loadString(
      'lang/${locale?.languageCode ?? this.locale?.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map<String, String>((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String text(String key) => _localizedStrings[key] ?? '$key not found';
  bool get isEnLocale => locale?.languageCode == LanguageCode.en.name;
  bool get isArLocale => locale?.languageCode == LanguageCode.ar.name;
}

extension AppLocalizationsExtension on String {
  String get tr {
    String translate = appLocalizations.text(this);
    return translate;
  }
}
