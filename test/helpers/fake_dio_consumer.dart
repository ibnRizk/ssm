import 'package:dio/dio.dart';
import 'package:ssm/core/api/dio_consumer.dart';

/// Records the last request and answers with [response] (or throws
/// [error]), so data sources can be tested without a network.
class FakeDioConsumer implements DioConsumer {
  dynamic response;
  Object? error;

  String? lastVerb;
  String? lastPath;
  Map<String, dynamic>? lastBody;
  Map<String, dynamic>? lastQuery;
  Map<String, String>? lastHeaders;
  FormData? lastFormData;

  FakeDioConsumer({this.response});

  Future<dynamic> _record(
    String verb,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    FormData? formData,
    Map<String, String>? headers,
  }) async {
    lastVerb = verb;
    lastFormData = formData;
    lastHeaders = headers;
    lastPath = path;
    lastBody = body;
    lastQuery = query;
    if (error case final Object e) throw e;
    return response;
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _record('GET', path, query: queryParameters);

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _record(
    'POST',
    path,
    body: body,
    query: queryParameters,
    formData: formData,
    headers: headers,
  );

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _record('PUT', path, body: body, query: queryParameters);

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _record('PATCH', path, body: body, query: queryParameters);

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) => _record(
    'DELETE',
    path,
    query: queryParameters,
    // A DELETE body (e.g. `cart_id`) is recorded like a POST body.
    body: data is Map<String, dynamic> ? data : null,
  );

  @override
  void updateLanguageCodeHeader() {}

  @override
  void updateDeviceTokenHeader(String token) {}

  @override
  void updateDeviceTypeHeader() {}
}
