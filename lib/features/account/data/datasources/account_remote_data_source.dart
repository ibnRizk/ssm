import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_error_mapper.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/customer_profile_model.dart';
import '../models/requests/update_profile_request.dart';

abstract class AccountRemoteDataSource {
  Future<CustomerProfileModel> getProfile();

  Future<void> updateProfile(UpdateProfileRequest request);

  /// Throws [ForbiddenException] for the HTTP 203 refusal.
  Future<void> deleteAccount();
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

  /// Success is an empty body; a refusal is a 203 with an `errors` body.
  @override
  Future<void> deleteAccount() async =>
      throwIfRefusal(await consumer.delete(ApiEndpoints.removeAccount));
}
