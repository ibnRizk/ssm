import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../guest/guest_session.dart';
import '../guest/guest_session_manager.dart';
import 'api_endpoints.dart';
import 'status_code.dart';

/// Authorizes a guest's cart and order calls — see `SSM_GUEST_MODE_API.md`.
///
/// Applies only when the request carries no bearer token and its path is
/// guest-scoped ([ApiEndpoints.isGuestScoped]); browsing calls and signed-in
/// calls pass through untouched. For those it:
/// - starts a guest session on first use (lazily — a guest who only
///   browses never creates one),
/// - sends the token as `X-Guest-Token` and the id as `guest_id`,
/// - on a 401 (`guest_session_required` / `invalid_guest_session` — the
///   only 401s a guest call gets), replaces the session and retries once.
class GuestSessionInterceptor extends Interceptor {
  /// Resolved per call: the manager's own requests go through the same Dio
  /// client this interceptor sits on.
  final GuestSessionManager Function() sessions;

  /// Re-sends a request through the client, interceptors included.
  final Future<Response<dynamic>> Function(RequestOptions options) retry;

  GuestSessionInterceptor({required this.sessions, required this.retry});

  static const String tokenHeader = 'X-Guest-Token';
  static const String guestIdField = 'guest_id';

  static const String _sessionKey = 'guest_session';
  static const String _retriedKey = 'guest_session_retried';

  @visibleForTesting
  static bool appliesTo(RequestOptions options) =>
      !options.headers.containsKey(HttpHeaders.authorizationHeader) &&
      ApiEndpoints.isGuestScoped(options.path);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!appliesTo(options)) return handler.next(options);
    try {
      attach(options, await sessions().ensure());
      handler.next(options);
    } on DioException catch (error) {
      handler.reject(error);
    } catch (error) {
      // Typically the AppException from starting the session; the mapper
      // passes it through unchanged.
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  /// Overwrites any earlier values: a retry carries a *new* session.
  @visibleForTesting
  static void attach(RequestOptions options, GuestSession session) {
    options.headers[tokenHeader] = session.token;
    options.queryParameters = <String, dynamic>{
      ...options.queryParameters,
      guestIdField: session.guestId,
    };
    final Object? data = options.data;
    if (data is Map<String, dynamic>) {
      options.data = <String, dynamic>{...data, guestIdField: session.guestId};
    }
    options.extra[_sessionKey] = session;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;
    final Object? used = options.extra[_sessionKey];
    if (err.response?.statusCode != StatusCode.unauthorized ||
        used is! GuestSession ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }
    try {
      await sessions().renew(used);
      options.extra[_retriedKey] = true;
      // Re-runs onRequest, which attaches the renewed session.
      handler.resolve(await retry(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }
}
