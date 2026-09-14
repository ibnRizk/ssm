import '../../../../core/utils/enums.dart';
import '../../../../injection_container.dart';

/// Data source for the language feature.
///
/// This one is local-only. A remote source looks the same, except its methods
/// call `dioConsumer` and map the response into a model — see the README.
abstract class LangLocalDataSource {
  Future<bool> changeLang({required LanguageCode langCode});

  Future<LanguageCode> getSavedLang();
}

class LangLocalDataSourceImpl implements LangLocalDataSource {
  const LangLocalDataSourceImpl();

  @override
  Future<bool> changeLang({required LanguageCode langCode}) =>
      sharedPreferences.saveLanguageCode(langCode.name);

  @override
  Future<LanguageCode> getSavedLang() async =>
      sharedPreferences.getLanguageCode();
}
