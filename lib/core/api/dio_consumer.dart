import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/env/app_env.dart';
import '../../injection_container.dart';
import '../error/exceptions.dart';
import '../utils/extension.dart';
import '../utils/log_utils.dart';
import '../utils/values/strings.dart';
import 'api_error_mapper.dart';

/// Thin, typed wrapper over Dio. Data sources depend on this abstraction, not
/// on Dio itself, which keeps them unit-testable with a fake consumer.
abstract class DioConsumer {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});

  /// [headers] are added to this request only.
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  });

  void updateLanguageCodeHeader();

  void updateDeviceTokenHeader(String token);

  void updateDeviceTypeHeader();
}

class DioConsumerImpl implements DioConsumer {
  final Dio client;

  DioConsumerImpl({required this.client}) {
    client.options
      ..baseUrl = AppEnv.baseUrl
      ..connectTimeout = AppEnv.connectTimeout
      ..receiveTimeout = AppEnv.receiveTimeout
      ..contentType = Headers.jsonContentType
      ..headers = <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.acceptLanguageHeader: sharedPreferences
            .getLanguageCode()
            .name,
        'device-lang': sharedPreferences.getLanguageCode().name,
        'device-type': _devicePlatform,
      };

    client.interceptors.add(appInterceptors);
    // Bodies carry passwords and responses carry bearer tokens — never print
    // them from a release build, whatever `.env` says.
    if (AppEnv.enableNetworkLogs && kDebugMode) {
      client.interceptors.add(logInterceptor);
    }
  }

  static String get _devicePlatform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  /// Re-read on every request so a login/logout mid-session takes effect
  /// without rebuilding the client.
  Future<void> _attachAccessToken() async {
    final String? accessToken = await secureStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      client.options.headers[HttpHeaders.authorizationHeader] =
          'Bearer $accessToken';
    } else {
      client.options.headers.remove(HttpHeaders.authorizationHeader);
    }
  }

  @override
  void updateLanguageCodeHeader() {
    final String code = sharedPreferences.getLanguageCode().name;
    client.options.headers[HttpHeaders.acceptLanguageHeader] = code;
    client.options.headers['device-lang'] = code;
  }

  @override
  void updateDeviceTokenHeader(String token) =>
      client.options.headers['device-token'] = token;

  @override
  void updateDeviceTypeHeader() =>
      client.options.headers['device-type'] = _devicePlatform;

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _request(
        'GET',
        path,
        () => client.get<dynamic>(path, queryParameters: queryParameters),
        details: 'params: $queryParameters',
      );

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _request(
    'POST',
    path,
    () => client.post<dynamic>(
      path,
      queryParameters: queryParameters,
      data: formData ?? body,
      options: headers == null ? null : Options(headers: headers),
    ),
    details: 'formData: ${formData?.toPrint}, body: $body',
  );

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _request(
    'PUT',
    path,
    () => client.put<dynamic>(
      path,
      queryParameters: queryParameters,
      data: formData ?? body,
    ),
    details: 'formData: ${formData?.toPrint}, body: $body',
  );

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _request(
    'PATCH',
    path,
    () => client.patch<dynamic>(
      path,
      queryParameters: queryParameters,
      data: formData ?? body,
    ),
    details: 'formData: ${formData?.toPrint}, body: $body',
  );

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) => _request(
    'DELETE',
    path,
    () => client.delete<dynamic>(
      path,
      queryParameters: queryParameters,
      data: data,
    ),
    details: 'data: $data',
  );

  /// Single funnel for every verb: logging, token attachment and error mapping
  /// live here instead of being copy-pasted per method.
  Future<dynamic> _request(
    String verb,
    String path,
    Future<Response<dynamic>> Function() send, {
    String details = '',
  }) async {
    try {
      Log.i('[$verb][$path] $details');
      await _attachAccessToken();
      final Response<dynamic> response = await send();
      Log.i('[$verb][$path] response: ${response.data}');
      return response.data;
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on DioException catch (error) {
      throw mapDioException(error);
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }
}
