import 'package:flutter/material.dart' show Locale, LocalizationsDelegate;

import '../../core/utils/enums.dart';
import '../../injection_container.dart';
import 'app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => LanguageCode.values
      .map((LanguageCode code) => code.name)
      .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations appLocalizations = AppLocalizations(locale);
    await appLocalizations.load();
    // Registered so the `'key'.tr` extension resolves without a BuildContext.
    ServiceLocator.injectAppLocalizations(appLocalizations);
    return appLocalizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
