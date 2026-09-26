import 'package:dartz/dartz.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// The repository-boundary catch: runs [call] and folds any exception into a
/// typed [Failure], so nothing thrown by the data layer escapes to a cubit.
Future<Either<Failure, T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return Right<Failure, T>(await call());
  } on AppException catch (error) {
    return Left<Failure, T>(error.toFailure());
  } catch (_) {
    return const Left(ServerFailure());
  }
}
