import '../api/api_endpoints.dart';
import '../api/dio_consumer.dart';

abstract class PushTokenRemoteDataSource {
  /// Pushes go to this device from now on (one device per customer).
  Future<void> register(String token);

  /// Pushes stop. Must run while the bearer token is still valid.
  Future<void> remove();
}

class PushTokenRemoteDataSourceImpl implements PushTokenRemoteDataSource {
  final DioConsumer consumer;

  const PushTokenRemoteDataSourceImpl({required this.consumer});

  @override
  Future<void> register(String token) => consumer.put(
    ApiEndpoints.fcmToken,
    body: <String, dynamic>{'cm_firebase_token': token},
  );

  @override
  Future<void> remove() => consumer.post(ApiEndpoints.removeFcmToken);
}
