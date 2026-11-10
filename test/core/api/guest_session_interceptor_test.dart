import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_error_mapper.dart';
import 'package:ssm/core/api/guest_session_interceptor.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/guest/guest_session.dart';

import '../../helpers/fake_guest_session_manager.dart';

/// Answers each request with the next status in [statuses] (200 once they
/// run out) and records what was sent.
class _RecordingAdapter implements HttpClientAdapter {
  final List<int> statuses;
  final List<RequestOptions> sent = <RequestOptions>[];

  _RecordingAdapter([this.statuses = const <int>[]]);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent.add(options);
    final int status = sent.length <= statuses.length
        ? statuses[sent.length - 1]
        : 200;
    return ResponseBody.fromString(
      jsonEncode(
        status == 200
            ? <String, dynamic>{'ok': true}
            : <String, dynamic>{
                'errors': <Map<String, String>>[
                  <String, String>{
                    'code': 'invalid_guest_session',
                    'message': 'Invalid guest session.',
                  },
                ],
              },
      ),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const GuestSession _first = GuestSession(guestId: 11, token: 'first-token');
const GuestSession _second = GuestSession(guestId: 22, token: 'second-token');

const String _cartList = '/api/v1/customer/cart/list';
const String _cartAdd = '/api/v1/customer/cart/add';

void main() {
  late FakeGuestSessionManager sessions;
  late _RecordingAdapter adapter;
  late Dio dio;

  Dio build(List<int> statuses) {
    adapter = _RecordingAdapter(statuses);
    final Dio client = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    client.interceptors.add(
      GuestSessionInterceptor(sessions: () => sessions, retry: client.fetch),
    );
    return client;
  }

  setUp(() {
    sessions = FakeGuestSessionManager(session: _first, renewed: _second);
    dio = build(const <int>[]);
  });

  group('attaches the guest session', () {
    test('sends X-Guest-Token on a guest cart call', () async {
      await dio.get<dynamic>(_cartList);

      expect(adapter.sent.single.headers['X-Guest-Token'], 'first-token');
    });

    test('sends guest_id as a query parameter', () async {
      await dio.get<dynamic>(_cartList);

      expect(adapter.sent.single.queryParameters['guest_id'], 11);
    });

    test('adds guest_id to a JSON body', () async {
      await dio.post<dynamic>(
        _cartAdd,
        data: <String, dynamic>{'item_id': 5, 'quantity': 1},
      );

      expect(adapter.sent.single.data, <String, dynamic>{
        'item_id': 5,
        'quantity': 1,
        'guest_id': 11,
      });
    });

    test('also covers order calls', () async {
      await dio.get<dynamic>('/api/v1/customer/order/running-orders');

      expect(adapter.sent.single.headers['X-Guest-Token'], 'first-token');
    });
  });

  group('leaves other requests alone', () {
    test('a signed-in request (bearer token) gets no guest session', () async {
      await dio.get<dynamic>(
        _cartList,
        options: Options(
          headers: <String, String>{
            HttpHeaders.authorizationHeader: 'Bearer abc',
          },
        ),
      );

      expect(adapter.sent.single.headers.containsKey('X-Guest-Token'), isFalse);
      expect(sessions.ensureCalls, 0);
    });

    test('public browsing calls start no guest session', () async {
      await dio.get<dynamic>('/api/v1/stores/get-stores/all');

      expect(adapter.sent.single.headers.containsKey('X-Guest-Token'), isFalse);
      expect(sessions.ensureCalls, 0);
    });
  });

  group('on a 401', () {
    test('renews the session and retries once with the new one', () async {
      dio = build(const <int>[401]);

      final Response<dynamic> response = await dio.get<dynamic>(_cartList);

      expect(response.statusCode, 200);
      expect(sessions.renewCalls, <GuestSession?>[_first]);
      expect(adapter.sent, hasLength(2));
      expect(adapter.sent.last.headers['X-Guest-Token'], 'second-token');
      expect(adapter.sent.last.queryParameters['guest_id'], 22);
    });

    test('gives up after one retry', () async {
      dio = build(const <int>[401, 401]);

      await expectLater(
        dio.get<dynamic>(_cartList),
        throwsA(
          isA<DioException>().having(
            (DioException e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(adapter.sent, hasLength(2));
    });

    test('does not retry a signed-in request', () async {
      dio = build(const <int>[401]);

      await expectLater(
        dio.get<dynamic>(
          _cartList,
          options: Options(
            headers: <String, String>{
              HttpHeaders.authorizationHeader: 'Bearer abc',
            },
          ),
        ),
        throwsA(isA<DioException>()),
      );
      expect(sessions.renewCalls, isEmpty);
      expect(adapter.sent, hasLength(1));
    });
  });

  test('a failure to start the session keeps its typed cause', () async {
    sessions.error = const InternetConnectionException(message: 'offline');

    final DioException error = await dio
        .get<dynamic>(_cartList)
        .then<DioException>((_) => fail('expected a failure'))
        .catchError((Object e) => e as DioException);

    expect(adapter.sent, isEmpty);
    expect(
      mapDioException(error),
      const InternetConnectionException(message: 'offline'),
    );
  });
}
