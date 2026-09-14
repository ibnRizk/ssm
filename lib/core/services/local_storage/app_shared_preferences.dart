import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/enum_extensions.dart';
import '../../utils/enums.dart';

abstract class _Keys {
  static const String userId = 'userId';
  static const String user = 'user';
  static const String appTheme = 'appTheme';
  static const String languageCode = 'languageCode';
  static const String userType = 'userType';
  static const String userCycle = 'userCycle';
}

/// Non-sensitive key/value storage. Anything secret (tokens, refresh tokens)
/// belongs in [AppSecureStorage] instead.
///
/// Note the user is stored as a raw `Map<String, dynamic>` on purpose: `core`
/// must not import a feature's model, or the dependency direction the
/// architecture enforces gets inverted. Decode it into your own model at the
/// feature's data-source boundary.
abstract class AppSharedPreferences {
  final SharedPreferences instance;

  const AppSharedPreferences({required this.instance});

  // --- User id ---
  int? getUserId();

  Future<bool> saveUserId(int id);

  Future<bool> removeUserId();

  // --- User payload ---
  Map<String, dynamic>? getUser();

  Future<bool> saveUser(Map<String, dynamic> user);

  Future<bool> removeUser();

  // --- Language ---
  LanguageCode getLanguageCode();

  Future<bool> saveLanguageCode(String value);

  Future<bool> removeLanguageCode();

  // --- Theme ---
  Themes getAppTheme();

  Future<bool> saveAppTheme(Themes theme);

  Future<bool> removeAppTheme();

  // --- User type / lifecycle ---
  UserType getUserType();

  Future<bool> saveUserType(UserType value);

  Future<bool> removeUserType();

  UserCycle getUserCycle();

  Future<bool> saveUserCycle(UserCycle value);

  Future<bool> removeUserCycle();

  Future<bool> clearAll();
}

class AppSharedPreferencesImpl extends AppSharedPreferences {
  const AppSharedPreferencesImpl({required super.instance});

  // --- User id ---
  @override
  int? getUserId() => instance.getInt(_Keys.userId);

  @override
  Future<bool> saveUserId(int id) => instance.setInt(_Keys.userId, id);

  @override
  Future<bool> removeUserId() => instance.remove(_Keys.userId);

  // --- User payload ---
  @override
  Map<String, dynamic>? getUser() {
    final String? raw = instance.getString(_Keys.user);
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<bool> saveUser(Map<String, dynamic> user) =>
      instance.setString(_Keys.user, jsonEncode(user));

  @override
  Future<bool> removeUser() => instance.remove(_Keys.user);

  // --- Language ---
  @override
  LanguageCode getLanguageCode() => LanguageCodeExtension.fromString(
    instance.getString(_Keys.languageCode) ?? LanguageCode.en.name,
  );

  @override
  Future<bool> saveLanguageCode(String value) => instance.setString(
    _Keys.languageCode,
    LanguageCodeExtension.fromString(value).name,
  );

  @override
  Future<bool> removeLanguageCode() => instance.remove(_Keys.languageCode);

  // --- Theme ---
  @override
  Themes getAppTheme() =>
      ThemesExtension.fromString(instance.getString(_Keys.appTheme) ?? '');

  @override
  Future<bool> saveAppTheme(Themes theme) =>
      instance.setString(_Keys.appTheme, theme.name);

  @override
  Future<bool> removeAppTheme() => instance.remove(_Keys.appTheme);

  // --- User type / lifecycle ---
  @override
  UserType getUserType() =>
      UserTypeExtension.fromString(instance.getString(_Keys.userType) ?? '');

  @override
  Future<bool> saveUserType(UserType value) =>
      instance.setString(_Keys.userType, value.name);

  @override
  Future<bool> removeUserType() => instance.remove(_Keys.userType);

  @override
  UserCycle getUserCycle() =>
      UserCycleExtension.fromString(instance.getString(_Keys.userCycle) ?? '');

  @override
  Future<bool> saveUserCycle(UserCycle value) =>
      instance.setString(_Keys.userCycle, value.name);

  @override
  Future<bool> removeUserCycle() => instance.remove(_Keys.userCycle);

  @override
  Future<bool> clearAll() => instance.clear();
}
