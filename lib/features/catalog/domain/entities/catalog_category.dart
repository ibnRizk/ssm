import 'package:equatable/equatable.dart';

/// A top-level catalog category of the current zone.
class CatalogCategory extends Equatable {
  final int id;
  final String name;

  /// Null when the backend has no usable image — show an icon instead.
  final String? imageUrl;

  const CatalogCategory({required this.id, required this.name, this.imageUrl});

  @override
  List<Object?> get props => [id, name, imageUrl];
}
