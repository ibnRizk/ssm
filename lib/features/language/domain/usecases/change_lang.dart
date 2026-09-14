import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../repositories/lang_repository.dart';

class ChangeLangUseCase implements UseCase<bool, LanguageCode> {
  final LangRepository repository;

  ChangeLangUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(LanguageCode langCode) async =>
      await repository.changeLang(langCode: langCode);
}
