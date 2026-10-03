import 'package:dartz/dartz.dart';

import '../error/failures.dart';
import 'app_config.dart';

abstract class AppConfigRepository {
  Future<Either<Failure, AppConfig>> getConfig();
}
