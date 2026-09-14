import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import 'presentation/cubit/home_cubit.dart';

/// Per-feature registration. Copy this file's shape for every new feature and
/// call it from `ServiceLocator.init()`.
///
/// Convention: cubits are `registerFactory` (fresh instance per screen), while
/// use cases, repositories and data sources are `registerLazySingleton`
/// (stateless, shared).
Future<void> initHomeFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerFactory<HomeCubit>(() => HomeCubit());

  /// UseCases — e.g.
  /// ServiceLocator.instance.registerLazySingleton(
  ///   () => GetItemsUseCase(repository: ServiceLocator.instance()),
  /// );

  /// Repository — e.g.
  /// ServiceLocator.instance.registerLazySingleton<HomeRepository>(
  ///   () => HomeRepositoryImpl(remote: ServiceLocator.instance()),
  /// );

  /// DataSource — e.g.
  /// ServiceLocator.instance.registerLazySingleton<HomeRemoteDataSource>(
  ///   () => HomeRemoteDataSourceImpl(),
  /// );
}

/// Providers this feature contributes to the widget tree. Spread into
/// `MultiBlocProvider` in `app.dart` only for app-wide cubits; screen-scoped
/// cubits should be provided at the route instead.
List<BlocProvider<StateStreamableSource<Object?>>> get homeBlocs =>
    <BlocProvider<StateStreamableSource<Object?>>>[
      BlocProvider<HomeCubit>(
        create: (BuildContext context) => ServiceLocator.instance<HomeCubit>(),
      ),
    ];
