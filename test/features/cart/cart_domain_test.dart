import 'package:flutter_base/features/cart/domain/entities/cart.dart';
import 'package:flutter_test/flutter_test.dart';

CartLine _line(int id, {int quantity = 1, double price = 10, int? storeId}) =>
    CartLine(
      id: id,
      itemId: id * 10,
      name: 'Item $id',
      unitPrice: price,
      quantity: quantity,
      storeId: storeId,
    );

void main() {
  group('Cart totals', () {
    final Cart cart = Cart(<CartLine>[
      _line(1, quantity: 2, price: 12.5),
      _line(2, quantity: 1, price: 3),
    ]);

    test('the subtotal sums every line', () {
      expect(cart.subtotal, 28);
    });

    test('the item count sums quantities, not lines', () {
      expect(cart.itemCount, 3);
    });

    test('an empty cart is zero', () {
      expect(Cart.empty.subtotal, 0);
      expect(Cart.empty.itemCount, 0);
    });
  });

  group('Cart.conflictsWithStore', () {
    final Cart cart = Cart(<CartLine>[_line(1, storeId: 7)]);

    test('an item from the same store fits', () {
      expect(cart.conflictsWithStore(7), isFalse);
    });

    test('an item from another store conflicts', () {
      expect(cart.conflictsWithStore(8), isTrue);
    });

    test('an unknown store never conflicts', () {
      expect(cart.conflictsWithStore(null), isFalse);
      expect(Cart(<CartLine>[_line(1)]).conflictsWithStore(8), isFalse);
    });

    test('an empty cart takes any store', () {
      expect(Cart.empty.conflictsWithStore(8), isFalse);
    });
  });

  test('lineForItem finds the line holding an item', () {
    final Cart cart = Cart(<CartLine>[_line(1), _line(2)]);

    expect(cart.lineForItem(20)?.id, 2);
    expect(cart.lineForItem(99), isNull);
  });
}
