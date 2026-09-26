import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../../account/domain/entities/customer_profile.dart';
import '../../../account/domain/repos/account_repository.dart';
import '../../../catalog/domain/entities/catalog_category.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/repos/catalog_repository.dart';
import 'home_state.dart';

/// Screen-scoped (provided at the Home tab's route).
class HomeCubit extends Cubit<HomeState> {
  final AccountRepository accountRepository;
  final CatalogRepository catalogRepository;
  final ZoneRepository zoneRepository;

  /// The catalog shown belongs to one zone — a new zone reloads it.
  late final StreamSubscription<List<int>> _zoneChanges;

  HomeCubit({
    required this.accountRepository,
    required this.catalogRepository,
    required this.zoneRepository,
  }) : super(const HomeInitial()) {
    _zoneChanges = zoneRepository.zoneChanges.listen((_) => load());
  }

  /// How many stores the Home preview shows; "view all" opens the rest.
  static const int storesPreviewCount = 5;

  bool _loading = false;

  /// Fetches the greeting's profile, the categories and the first stores
  /// concurrently. A refresh keeps the screen visible while it runs, and a
  /// failed refresh keeps what's already shown.
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    final HomeLoaded? before = state is HomeLoaded ? state as HomeLoaded : null;
    if (before == null) emit(const HomeLoading());

    final (
      Either<Failure, CustomerProfile> profile,
      Either<Failure, List<CatalogCategory>> categories,
      Either<Failure, CatalogPage<Store>> stores,
    ) = await (
      accountRepository.getProfile(),
      catalogRepository.getCategories(),
      catalogRepository.getStores(page: 1, pageSize: storesPreviewCount),
    ).wait;

    _loading = false;
    if (isClosed) return;

    final Failure? failure = categories.fold(
      (Failure f) => f,
      (_) => stores.fold((Failure f) => f, (_) => null),
    );
    if (failure != null) {
      if (before == null) emit(HomeError(failure));
      return;
    }

    emit(
      HomeLoaded(
        customerName: profile.fold(
          // Keep the name through a failed refresh of the profile alone.
          (_) => before?.customerName,
          (CustomerProfile p) => p.firstName,
        ),
        categories: categories.getOrElse(() => const <CatalogCategory>[]),
        stores: stores.fold(
          (_) => const <Store>[],
          (CatalogPage<Store> page) => page.items,
        ),
        zoneIds: zoneRepository.currentZoneIds,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _zoneChanges.cancel();
    return super.close();
  }
}
