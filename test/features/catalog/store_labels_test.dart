import 'package:flutter_base/features/catalog/domain/entities/store.dart';
import 'package:flutter_base/features/catalog/presentation/utils/store_labels.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_strings.dart';

void main() {
  setUpAll(installEnglishStrings);
  tearDownAll(removeTestStrings);

  group('StoreLabels.deliveryFeeLabel', () {
    test('says free delivery when the store offers it', () {
      expect(
        const Store(
          id: 1,
          name: 'A',
          freeDelivery: true,
          minimumDeliveryFee: 7,
        ).deliveryFeeLabel,
        'Free delivery',
      );
    });

    test('quotes the minimum charge as a starting price', () {
      expect(
        const Store(id: 1, name: 'A', minimumDeliveryFee: 7).deliveryFeeLabel,
        'Delivery from 7 SAR',
      );
    });

    test('is null when the fee is unknown', () {
      expect(const Store(id: 1, name: 'A').deliveryFeeLabel, isNull);
    });
  });

  group('StoreLabels.deliveryTimeLabel', () {
    test("prefers the merchant's own wording", () {
      expect(
        const Store(
          id: 1,
          name: 'A',
          deliveryTime: '30-40 min',
          minDeliveryTime: 25,
        ).deliveryTimeLabel,
        '30-40 min',
      );
    });

    test('falls back to the fastest delivery in minutes', () {
      expect(
        const Store(id: 1, name: 'A', minDeliveryTime: 25).deliveryTimeLabel,
        '25 min',
      );
    });

    test('is null when neither is known', () {
      expect(const Store(id: 1, name: 'A').deliveryTimeLabel, isNull);
    });
  });

  group('StoreLabels.subtitle', () {
    test('prefers the tags, falling back to the address', () {
      expect(
        const Store(
          id: 1,
          name: 'A',
          tags: <String>['Burger', 'Grill'],
          address: 'Turbah',
        ).subtitle,
        'Burger  •  Grill',
      );
      expect(
        const Store(id: 1, name: 'A', address: 'Turbah').subtitle,
        'Turbah',
      );
    });
  });
}
