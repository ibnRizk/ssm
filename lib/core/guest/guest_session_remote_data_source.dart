import '../api/api_endpoints.dart';
import '../api/dio_consumer.dart';
import 'guest_session.dart';
import 'guest_session_model.dart';

abstract class GuestSessionRemoteDataSource {
  /// `POST /auth/guest/request`. The token in the answer is returned once
  /// only — the backend keeps just its hash.
  Future<GuestSession> request({String? fcmToken});
}

class GuestSessionRemoteDataSourceImpl implements GuestSessionRemoteDataSource {
  final DioConsumer consumer;

  const GuestSessionRemoteDataSourceImpl({required this.consumer});

  @override
  Future<GuestSession> request({String? fcmToken}) async =>
      GuestSessionModel.fromJson(
        await consumer.post(
          ApiEndpoints.guestSession,
          body: <String, dynamic>{'fcm_token': ?fcmToken},
        ),
      );
}
