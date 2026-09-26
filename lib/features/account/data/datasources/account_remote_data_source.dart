import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/customer_profile_model.dart';
import '../models/requests/update_profile_request.dart';

abstract class AccountRemoteDataSource {
  Future<CustomerProfileModel> getProfile();

  Future<void> updateProfile(UpdateProfileRequest request);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final DioConsumer consumer;

  const AccountRemoteDataSourceImpl({required this.consumer});

  @override
  Future<CustomerProfileModel> getProfile() async =>
      CustomerProfileModel.fromJson(
        await consumer.get(ApiEndpoints.customerInfo),
      );

  /// The 200 body is only a confirmation message — the caller already holds
  /// the values it sent, so nothing is parsed.
  @override
  Future<void> updateProfile(UpdateProfileRequest request) =>
      consumer.post(ApiEndpoints.updateProfile, body: request.toJson());
}
