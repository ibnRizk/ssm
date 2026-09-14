import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '/injection_container.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    options.headers['Content-Type'] = 'application/json';
    //options.headers['Authorization'] = 'Bearer 3|tiLlHT6fseS3KLa5yiDLur94T6HCibEw2opQ4NYS27f0ce1d';

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // debugPrint(
    //     'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      eventBus.emitUnauthorized(); // 🔥 Trigger navigation to Login
    }
    debugPrint(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path} => RESPONSE: ${err.response?.toString()}',
    );
    super.onError(err, handler);
  }
}
