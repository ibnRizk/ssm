import 'package:ssm/features/orders/domain/entities/order_list_entry.dart';
import 'package:ssm/features/orders/presentation/utils/order_list_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/test_strings.dart';

void main() {
  setUpAll(() async {
    installEnglishStrings();
    await initializeDateFormatting('en');
  });
  tearDownAll(removeTestStrings);

  group('itemsLabel', () {
    test('lists the products with their quantities', () {
      const OrderListEntry order = OrderListEntry(
        id: 1,
        status: OrderListStatus.pending,
        items: <OrderItemSummary>[
          OrderItemSummary(name: 'Burger', quantity: 2),
          OrderItemSummary(name: 'Fries', quantity: 1),
        ],
      );

      expect(order.itemsLabel, 'Burger ×2 + Fries');
    });

    test('falls back to the item count', () {
      const OrderListEntry order = OrderListEntry(
        id: 1,
        status: OrderListStatus.pending,
        itemCount: 8,
      );

      expect(order.itemsLabel, '8 items');
    });
  });

  group('orderDateLabel', () {
    final DateTime now = DateTime(2026, 9, 26, 21);

    test('today and yesterday show the time', () {
      expect(
        orderDateLabel(DateTime(2026, 9, 26, 20, 24), now, 'en'),
        'Today, 8:24 PM',
      );
      expect(
        orderDateLabel(DateTime(2026, 9, 25, 18, 12), now, 'en'),
        'Yesterday, 6:12 PM',
      );
    });

    test('earlier this year shows the day, other years the year too', () {
      expect(orderDateLabel(DateTime(2026, 8, 18), now, 'en'), 'August 18');
      expect(orderDateLabel(DateTime(2025, 8, 18), now, 'en'), 'Aug 18, 2025');
    });
  });

  test('the order number follows the date', () {
    final OrderListEntry order = OrderListEntry(
      id: 1048,
      status: OrderListStatus.delivered,
      createdAt: DateTime(2026, 8, 18),
    );

    expect(
      order.dateAndNumber(DateTime(2026, 9, 26), 'en'),
      'August 18 · #1048',
    );
    expect(
      const OrderListEntry(
        id: 7,
        status: OrderListStatus.pending,
      ).dateAndNumber(DateTime(2026, 9, 26), 'en'),
      '#7',
    );
  });
}
