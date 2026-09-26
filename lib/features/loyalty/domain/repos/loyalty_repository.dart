import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/loyalty_progress.dart';

abstract class LoyaltyRepository {
  Future<Either<Failure, LoyaltyProgress>> getProgress();
}
