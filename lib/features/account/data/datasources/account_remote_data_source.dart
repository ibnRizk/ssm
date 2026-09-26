import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/customer_profile_model.dart';

abstract class AccountRemoteDataSource {
  Future<CustomerProfileModel> getProfile();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final DioConsumer consumer;

  const AccountRemoteDataSourceImpl({required this.consumer});

  @override
  Future<CustomerProfileModel> getProfile() async =>
      CustomerProfileModel.fromJson(
        await consumer.get(ApiEndpoints.customerInfo),
      );
}
