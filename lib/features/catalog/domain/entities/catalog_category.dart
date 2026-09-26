import 'package:equatable/equatable.dart';

/// A store type of the current zone (restaurants, supermarkets, …) — the
/// stores under it are listed by its [id].
class CatalogCategory extends Equatable {
  final int id;

  /// As the backend localized it for the request's language.
  final String name;

  /// Per-language names; null when the backend doesn't send them.
  final String? nameAr;
  final String? nameEn;

  /// Null when the backend has no usable image — show an icon instead.
  final String? imageUrl;

  const CatalogCategory({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.imageUrl,
  });

  /// The name in [languageCode] (`ar` / `en`), else [name]. The cached
  /// [name] was localized for whichever language was active when it was
  /// fetched, so this follows a language switch without a refetch.
  String nameFor(String languageCode) =>
      switch (languageCode) {
        'ar' => nameAr,
        'en' => nameEn,
        _ => null,
      } ??
      name;

  @override
  List<Object?> get props => [id, name, nameAr, nameEn, imageUrl];
}
