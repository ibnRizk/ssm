import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_base/config/locale/app_localizations.dart';
import 'package:flutter_base/injection_container.dart';

/// `Strings.*` resolve through the [AppLocalizations] registered in get_it,
/// which the app loads from assets at startup. This registers one backed by
/// the real `lang/en.json`, read from disk, so tests assert on real copy —
/// and a missing key shows up as `"<key> not found"` in a failure.
///
/// Call from `setUpAll`; pair with [removeTestStrings] in `tearDownAll`.
void installEnglishStrings() {
  final Map<String, dynamic> json =
      jsonDecode(File('lang/en.json').readAsStringSync())
          as Map<String, dynamic>;
  removeTestStrings();
  ServiceLocator.injectAppLocalizations(
    _FileBackedLocalizations(
      json.map((String k, dynamic v) => MapEntry(k, v.toString())),
    ),
  );
}

void removeTestStrings() {
  if (ServiceLocator.instance.isRegistered<AppLocalizations>()) {
    ServiceLocator.instance.unregister<AppLocalizations>();
  }
}

class _FileBackedLocalizations extends AppLocalizations {
  final Map<String, String> _strings;

  _FileBackedLocalizations(this._strings) : super(const Locale('en'));

  @override
  String text(String key) => _strings[key] ?? '$key not found';
}
