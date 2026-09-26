import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/loyalty_history.dart';
import '../entities/loyalty_progress.dart';

abstract class LoyaltyRepository {
  Future<Either<Failure, LoyaltyProgress>> getProgress();

  Future<Either<Failure, LoyaltyHistory>> getHistory();
}
