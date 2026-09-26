import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/repos/address_repository.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/requests/add_address_request.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remote;

  const AddressRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Address>>> getAddresses() =>
      safeApiCall(remote.getAddresses);

  @override
  Future<Either<Failure, Unit>> addAddress(NewAddress address) =>
      safeApiCall(() async {
        await remote.addAddress(AddAddressRequest(address));
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteAddress(int id) => safeApiCall(() async {
    await remote.deleteAddress(id);
    return unit;
  });
}
