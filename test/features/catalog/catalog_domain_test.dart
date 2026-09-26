import 'package:ssm/features/catalog/domain/entities/catalog_category.dart';
import 'package:ssm/features/catalog/domain/entities/catalog_page.dart';
import 'package:ssm/features/catalog/domain/entities/store.dart';
import 'package:ssm/features/catalog/domain/entities/store_item.dart';
import 'package:flutter_test/flutter_test.dart';

StoreItem _item({
  double price = 40,
  double discount = 0,
  DiscountType type = DiscountType.amount,
}) => StoreItem(
  id: 1,
  name: 'Meal',
  price: price,
  discount: discount,
  discountType: type,
);

void main() {
  group('StoreItem.finalPrice', () {
    test('takes a percentage off the list price', () {
      expect(_item(discount: 25, type: DiscountType.percent).finalPrice, 30);
    });

    test('takes a fixed amount off the list price', () {
      expect(_item(discount: 5).finalPrice, 35);
    });

    test('never goes below zero', () {
      expect(_item(discount: 50).finalPrice, 0);
      expect(_item(discount: 150, type: DiscountType.percent).finalPrice, 0);
    });

    test('hasDiscount is false without one', () {
      expect(_item().hasDiscount, isFalse);
      expect(_item(discount: 5).hasDiscount, isTrue);
    });
  });

  group('Store.hasRating', () {
    test('is false until someone has rated the store', () {
      expect(const Store(id: 1, name: 'A').hasRating, isFalse);
      expect(
        const Store(id: 1, name: 'A', rating: 4.5, ratingCount: 3).hasRating,
        isTrue,
      );
    });
  });

  group('CatalogCategory.nameFor', () {
    const CatalogCategory category = CatalogCategory(
      id: 1,
      name: 'Restaurants',
      nameAr: 'مطاعم',
      nameEn: 'Restaurants',
    );

    test('picks the name in the given language', () {
      expect(category.nameFor('ar'), 'مطاعم');
      expect(category.nameFor('en'), 'Restaurants');
    });

    test('falls back to name without a translation', () {
      expect(
        const CatalogCategory(id: 1, name: 'Restaurants').nameFor('ar'),
        'Restaurants',
      );
      expect(category.nameFor('fr'), 'Restaurants');
    });
  });

  group('CatalogPage.hasMoreAfter', () {
    const CatalogPage<int> page = CatalogPage<int>(
      items: <int>[1, 2],
      totalSize: 5,
    );

    test('is true while fewer than the total are loaded', () {
      expect(page.hasMoreAfter(2), isTrue);
    });

    test('is false once the total is reached', () {
      expect(page.hasMoreAfter(5), isFalse);
    });

    test('an empty page ends the list even if the total disagrees', () {
      expect(
        const CatalogPage<int>(items: <int>[], totalSize: 5).hasMoreAfter(2),
        isFalse,
      );
    });
  });
}
