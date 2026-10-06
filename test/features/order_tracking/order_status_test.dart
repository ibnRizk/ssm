import 'package:ssm/features/order_tracking/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderStatus.resolve', () {
    test('the canonical status wins', () {
      expect(
        OrderStatus.resolve(OrderStatus.preparing, 'canceled'),
        OrderStatus.preparing,
      );
    });

    test('without one, a legacy cancellation still shows', () {
      expect(OrderStatus.resolve(null, 'canceled'), OrderStatus.cancelled);
      expect(OrderStatus.resolve(null, 'delivered'), OrderStatus.delivered);
    });

    // A customer cancel is recorded in the legacy status only — ssm_status
    // can stay at pending_merchant after it.
    test('a legacy cancellation wins over a canonical pending', () {
      expect(
        OrderStatus.resolve(OrderStatus.pendingMerchant, 'canceled'),
        OrderStatus.cancelled,
      );
    });

    test('anything else reads as pending', () {
      expect(OrderStatus.resolve(null, 'pending'), OrderStatus.pendingMerchant);
      expect(OrderStatus.resolve(null, null), OrderStatus.pendingMerchant);
    });
  });

  group('OrderStatus.stage', () {
    test('maps the canonical flow onto the five customer steps', () {
      expect(
        <OrderStage?>[for (final OrderStatus s in OrderStatus.values) s.stage],
        <OrderStage?>[
          OrderStage.placed,
          OrderStage.preparing,
          OrderStage.preparing,
          OrderStage.preparing,
          OrderStage.courierToStore,
          OrderStage.courierToStore,
          OrderStage.courierToStore,
          OrderStage.courierToCustomer,
          OrderStage.courierToCustomer,
          OrderStage.delivered,
          null,
          null,
          OrderStage.courierToStore,
        ],
      );
    });

    test('delivered and the failures are final', () {
      expect(
        OrderStatus.values.where((OrderStatus s) => s.isFinal),
        <OrderStatus>[
          OrderStatus.delivered,
          OrderStatus.rejected,
          OrderStatus.cancelled,
        ],
      );
    });

    test('no courier yet is not final: the store can retry dispatch', () {
      expect(OrderStatus.assignmentFailed.isFinal, isFalse);
      expect(OrderStatus.assignmentFailed.isFailed, isFalse);
    });

    test('only a pending order can be cancelled', () {
      expect(
        OrderStatus.values.where((OrderStatus s) => s.canBeCancelled),
        <OrderStatus>[OrderStatus.pendingMerchant],
      );
    });

    test('only out-for-delivery needs the delivery OTP', () {
      expect(
        OrderStatus.values.where((OrderStatus s) => s.needsDeliveryOtp),
        <OrderStatus>[OrderStatus.outForDelivery],
      );
    });
  });
}
