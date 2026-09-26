import 'package:equatable/equatable.dart';

/// One page of a paginated catalog list.
class CatalogPage<T> extends Equatable {
  final List<T> items;

  /// Total across all pages.
  final int totalSize;

  const CatalogPage({required this.items, required this.totalSize});

  /// Whether more remain after [loadedCount] items. An empty page ends the
  /// list even if [totalSize] disagrees, so a miscount can't loop forever.
  bool hasMoreAfter(int loadedCount) =>
      items.isNotEmpty && loadedCount < totalSize;

  @override
  List<Object?> get props => [items, totalSize];
}
