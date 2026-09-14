import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/local_storage/app_shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final AppSharedPreferences _sharedPreferences;
  static const String _themeKey = 'app_theme_mode';

  ThemeCubit({required AppSharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        super(_loadThemeMode(sharedPreferences));

  static ThemeMode _loadThemeMode(AppSharedPreferences prefs) {
    final String? themeStr = prefs.instance.getString(_themeKey);
    if (themeStr == 'light') return ThemeMode.light;
    if (themeStr == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String themeStr;
    switch (mode) {
      case ThemeMode.light:
        themeStr = 'light';
        break;
      case ThemeMode.dark:
        themeStr = 'dark';
        break;
      case ThemeMode.system:
        themeStr = 'system';
        break;
    }
    await _sharedPreferences.instance.setString(_themeKey, themeStr);
    emit(mode);
  }

  Future<void> toggleTheme() async {
    // Treat system as light for toggling simplicity or explicitly check brightness.
    // For manual toggle, just switch between light and dark.
    final ThemeMode newMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
