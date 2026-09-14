import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../injection_container.dart';
import '../../../domain/usecases/change_lang.dart';
import '../../../domain/usecases/get_saved_lang.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final GetSavedLangUseCase getSavedLangUseCase;
  final ChangeLangUseCase changeLangUseCase;

  LocaleCubit({
    required this.getSavedLangUseCase,
    required this.changeLangUseCase,
  }) : super(LocaleState(Locale(sharedPreferences.getLanguageCode().name)));

  LanguageCode currentLangCode = sharedPreferences.getLanguageCode();

  Future<void> getSavedLang() async {
    final response = await getSavedLangUseCase(NoParams());
    response.fold((failure) => debugPrint('Failed to read saved language'), (
      value,
    ) {
      currentLangCode = value;
      emit(LocaleState(Locale(currentLangCode.name)));
    });
  }

  Future<void> changeLanguage(LanguageCode langCode) async {
    if (langCode == currentLangCode) return;

    final Either<Failure, bool> response = await changeLangUseCase(langCode);
    final LanguageCode? persisted = response.fold((Failure failure) {
      debugPrint('Failed to persist language: ${failure.message}');
      return null;
    }, (_) => langCode);
    if (persisted == null) return;

    currentLangCode = persisted;
    final Locale newLocale = Locale(persisted.name);

    // Must complete before emitting: the new JSON has to be in memory by the
    // time widgets rebuild, or every `.tr` renders "<key> not found".
    await appLocalizations.load(locale: newLocale);
    dioConsumer.updateLanguageCodeHeader();

    emit(LocaleState(newLocale));
  }
}
