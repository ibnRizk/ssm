import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/catalog_category.dart';
import '../../../catalog/domain/entities/store.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  /// Null when the profile couldn't be fetched — the greeting goes generic.
  final String? customerName;
  final List<CatalogCategory> categories;

  /// The first stores of the zone — a preview, not the full list.
  final List<Store> stores;

  /// The zone the catalog was loaded for.
  final List<int> zoneIds;

  const HomeLoaded({
    required this.categories,
    required this.stores,
    this.customerName,
    this.zoneIds = const <int>[],
  });

  @override
  List<Object?> get props => [customerName, categories, stores, zoneIds];
}

/// The catalog couldn't be fetched — the screen has nothing to browse.
final class HomeError extends HomeState {
  final Failure failure;

  const HomeError(this.failure);

  @override
  List<Object?> get props => [failure];
}
