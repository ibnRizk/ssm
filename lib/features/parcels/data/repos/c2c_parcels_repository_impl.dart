import 'package:dartz/dartz.dart';

import '../../../../core/api/safe_api_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/repos/c2c_parcels_repository.dart';
import '../datasources/c2c_parcels_remote_data_source.dart';

class C2cParcelsRepositoryImpl implements C2cParcelsRepository {
  final C2cParcelsRemoteDataSource remote;

  const C2cParcelsRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, C2cParcelQuote>> getQuote(C2cQuoteRequest request) =>
      safeApiCall(() => remote.getQuote(request));
}
