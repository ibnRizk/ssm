import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../repositories/lang_repository.dart';

class GetSavedLangUseCase implements UseCase<LanguageCode, NoParams> {
  final LangRepository repository;

  GetSavedLangUseCase({required this.repository});

  @override
  Future<Either<Failure, LanguageCode>> call(NoParams params) async =>
      await repository.getSavedLang();
}
