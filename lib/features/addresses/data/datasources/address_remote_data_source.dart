import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../models/address_model.dart';
import '../models/requests/add_address_request.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();

  Future<void> addAddress(AddAddressRequest request);

  Future<void> deleteAddress(int id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final DioConsumer consumer;

  const AddressRemoteDataSourceImpl({required this.consumer});

  @override
  Future<List<AddressModel>> getAddresses() async =>
      AddressModel.listFromJson(await consumer.get(ApiEndpoints.addressList));

  /// The 200 body echoes the new address and its `zone_ids`; the list is
  /// refetched afterwards instead, so it isn't parsed here.
  @override
  Future<void> addAddress(AddAddressRequest request) =>
      consumer.post(ApiEndpoints.addressAdd, body: request.toJson());

  @override
  Future<void> deleteAddress(int id) => consumer.delete(
    ApiEndpoints.addressDelete,
    queryParameters: <String, dynamic>{'address_id': id},
  );
}
