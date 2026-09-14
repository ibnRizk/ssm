import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/log_utils.dart';
import '../../domain/repositories/lang_repository.dart';
import '../datasources/lang_local_data_source.dart';

/// Repository template: this is the only layer that catches [AppException] and
/// converts it to a [Failure]. Everything above it works with
/// `Either<Failure, T>` and never sees an exception.
class LangRepositoryImpl implements LangRepository {
  final LangLocalDataSource langLocalDataSource;

  const LangRepositoryImpl({required this.langLocalDataSource});

  @override
  Future<Either<Failure, bool>> changeLang({
    required LanguageCode langCode,
  }) async {
    try {
      return Right<Failure, bool>(
        await langLocalDataSource.changeLang(langCode: langCode),
      );
    } on AppException catch (error) {
      Log.e('[changeLang] [${error.runtimeType}] ---- ${error.message}');
      return Left<Failure, bool>(error.toFailure());
    }
  }

  @override
  Future<Either<Failure, LanguageCode>> getSavedLang() async {
    try {
      return Right<Failure, LanguageCode>(
        await langLocalDataSource.getSavedLang(),
      );
    } on AppException catch (error) {
      Log.e('[getSavedLang] [${error.runtimeType}] ---- ${error.message}');
      return Left<Failure, LanguageCode>(error.toFailure());
    }
  }
}
