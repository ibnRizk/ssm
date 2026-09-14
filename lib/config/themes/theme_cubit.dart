import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/enums.dart';
import '../../injection_container.dart';

/// Holds the active [Themes] and persists it to SharedPreferences so the
/// choice survives a restart.
class ThemeCubit extends Cubit<Themes> {
  ThemeCubit() : super(sharedPreferences.getAppTheme());

  Future<void> setTheme(Themes theme) async {
    if (theme == state) return;
    await sharedPreferences.saveAppTheme(theme);
    emit(theme);
  }

  Future<void> toggle() =>
      setTheme(state == Themes.dark ? Themes.light : Themes.dark);
}
