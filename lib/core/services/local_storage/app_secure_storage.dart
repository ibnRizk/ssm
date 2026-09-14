import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class _AppSecureStorageKeys {
  static const String accessToken = 'accessToken';
  static const String deviceToken = 'deviceToken';
}

abstract class AppSecureStorage {
  final FlutterSecureStorage instance;

  const AppSecureStorage({required this.instance});

  //region:: AccessToken
  Future<String?> getAccessToken();

  Future<void> saveAccessToken(String? token);

  Future<void> removeAccessToken();

  //endregion

  //region:: DeviceToken
  Future<String?> getDeviceToken();

  Future<void> saveDeviceToken(String token);

  Future<void> removeDeviceToken();

  //endregion

  Future<void> clearAll();
}

class AppSecureStorageImpl extends AppSecureStorage {
  AppSecureStorageImpl({required super.instance});

  //region:: AccessToken
  @override
  Future<String?> getAccessToken() =>
      instance.read(key: _AppSecureStorageKeys.accessToken);

  @override
  Future<void> saveAccessToken(String? token) =>
      instance.write(key: _AppSecureStorageKeys.accessToken, value: token);

  @override
  Future<void> removeAccessToken() =>
      instance.delete(key: _AppSecureStorageKeys.accessToken);

  //endregion

  //region:: DeviceToken
  @override
  Future<String?> getDeviceToken() =>
      instance.read(key: _AppSecureStorageKeys.deviceToken);

  @override
  Future<void> saveDeviceToken(String token) =>
      instance.write(key: _AppSecureStorageKeys.deviceToken, value: token);

  @override
  Future<void> removeDeviceToken() =>
      instance.delete(key: _AppSecureStorageKeys.deviceToken);

  //endregion

  @override
  Future<void> clearAll() => instance.deleteAll();
}
