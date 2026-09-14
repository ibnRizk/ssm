import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';

abstract class AppLocalizationsSetup {
  /// Order matters: the first entry is the fallback when the device locale is
  /// unsupported.
  static const Iterable<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale>? supported,
  ) {
    final Iterable<Locale> locales = supported ?? supportedLocales;
    if (locale == null) return locales.first;

    // Exact match on language + country.
    for (final Locale supportedLocale in locales) {
      if (supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }
    // Fall back to language-only (e.g. ar_EG -> ar).
    for (final Locale supportedLocale in locales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    return locales.first;
  }
}
