import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import 'data/datasources/lang_local_data_source.dart';
import 'data/repositories/lang_repository_impl.dart';
import 'domain/repositories/lang_repository.dart';
import 'domain/usecases/change_lang.dart';
import 'domain/usecases/get_saved_lang.dart';
import 'presentation/cubit/locale_cubit/locale_cubit.dart';

Future<void> initLanguageFeatureInjection() async {
  /// Cubits — LocaleCubit is a lazy singleton because it holds app-wide state.
  ServiceLocator.instance.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(
      changeLangUseCase: ServiceLocator.instance(),
      getSavedLangUseCase: ServiceLocator.instance(),
    ),
  );

  /// UseCases
  ServiceLocator.instance.registerLazySingleton<GetSavedLangUseCase>(
    () => GetSavedLangUseCase(repository: ServiceLocator.instance()),
  );
  ServiceLocator.instance.registerLazySingleton<ChangeLangUseCase>(
    () => ChangeLangUseCase(repository: ServiceLocator.instance()),
  );

  /// Repository
  ServiceLocator.instance.registerLazySingleton<LangRepository>(
    () => LangRepositoryImpl(langLocalDataSource: ServiceLocator.instance()),
  );

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<LangLocalDataSource>(
    () => const LangLocalDataSourceImpl(),
  );
}

/// Provided app-wide in `app.dart` — the whole tree rebuilds on a locale change.
List<BlocProvider<StateStreamableSource<Object?>>> get languageBlocs =>
    <BlocProvider<StateStreamableSource<Object?>>>[
      BlocProvider<LocaleCubit>(
        create: (BuildContext context) =>
            ServiceLocator.instance<LocaleCubit>(),
      ),
    ];
