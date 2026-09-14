import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';

abstract class LangRepository {
  Future<Either<Failure, bool>> changeLang({required LanguageCode langCode});

  Future<Either<Failure, LanguageCode>> getSavedLang();
}
