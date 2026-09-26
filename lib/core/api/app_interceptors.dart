import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/locale/app_localizations.dart';
import '../zone/zone_repository.dart';
import '/injection_container.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    options.headers['Content-Type'] = 'application/json';
    // The backend translates messages by this header. Read per request so it
    // always matches the language the UI is currently showing.
    options.headers['X-localization'] = _languageCode;
    //options.headers['Authorization'] = 'Bearer 3|tiLlHT6fseS3KLa5yiDLur94T6HCibEw2opQ4NYS27f0ce1d';
    options.headers.addAll(zoneHeaders(sharedPreferences.getZoneIds()));

    super.onRequest(options, handler);
  }

  /// Catalog, cart and order calls are scoped by these headers. Read per
  /// request so switching the delivery address takes effect immediately;
  /// harmless on endpoints that ignore them. `zoneId` is omitted until a zone
  /// is known — an empty array would be rejected, not treated as "any zone".
  @visibleForTesting
  static Map<String, String> zoneHeaders(List<int> zoneIds) => <String, String>{
    'moduleId': '$defaultModuleId',
    if (zoneIds.isNotEmpty) 'zoneId': jsonEncode(zoneIds),
  };

  static String get _languageCode {
    if (ServiceLocator.instance.isRegistered<AppLocalizations>()) {
      final String? code = appLocalizations.locale?.languageCode;
      if (code != null) return code;
    }
    return sharedPreferences.getLanguageCode().name;
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // debugPrint(
    //     'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Only an authenticated request can mean "session expired". A 401 from
    // `/auth/login` is just a wrong password and must not reset the app.
    final bool sentToken = err.requestOptions.headers.containsKey(
      HttpHeaders.authorizationHeader,
    );
    if (err.response?.statusCode == 401 && sentToken) {
      eventBus.emitUnauthorized(); // 🔥 Trigger navigation to Login
    }
    // Transport failures (refused, DNS, TLS, permission) have no response —
    // `type` and `error` are the only record of what actually went wrong.
    debugPrint(
      'ERROR[${err.response?.statusCode}] ${err.type.name} => URL: ${err.requestOptions.uri} => CAUSE: ${err.error ?? err.message} => RESPONSE: ${err.response?.toString()}',
    );
    super.onError(err, handler);
  }
}
