import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/local_storage/app_shared_preferences.dart';
import '../../core/utils/enums.dart';

/// Drives the app's locale override. `null` state means "no explicit choice
/// yet" — `MaterialApp.router` passes this straight through as its own
/// `locale`, so a `null` here leaves `localeResolutionCallback` in charge and
/// the app keeps following the device locale until the user picks one.
///
/// Once a locale is picked, Flutter recomputes `Directionality` and reloads
/// [AppLocalizations] on its own — nothing here flips layout manually.
class LocaleCubit extends Cubit<Locale?> {
  final AppSharedPreferences sharedPreferences;

  LocaleCubit({required this.sharedPreferences})
    : super(_localeFrom(sharedPreferences.getSavedLanguageCode() ?? LanguageCode.ar));

  Future<void> changeLocale(LanguageCode code) async {
    if (state?.languageCode == code.name) return;
    await sharedPreferences.saveLanguageCode(code.name);
    emit(Locale(code.name));
  }

  static Locale? _localeFrom(LanguageCode? code) =>
      code == null ? null : Locale(code.name);
}
