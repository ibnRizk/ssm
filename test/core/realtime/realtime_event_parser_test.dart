import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/realtime/realtime_event.dart';
import 'package:ssm/core/realtime/realtime_event_parser.dart';
import 'package:ssm/core/realtime/status_version_gate.dart';

void main() {
  group('parseRealtimeEvent', () {
    test('status_changed carries the order, status and version', () {
      expect(
        parseRealtimeEvent(
          name: 'ssm.order.status_changed',
          channelName: 'private-customer.1',
          data: <String, dynamic>{
            'order_id': 42,
            'ssm_status': 'picked_up',
            'status_version': '5',
          },
        ),
        const OrderStatusChanged(42, status: 'picked_up', statusVersion: 5),
      );
    });

    test("Echo's leading-dot spelling is accepted", () {
      expect(
        parseRealtimeEvent(
          name: '.ssm.driver.assigned',
          channelName: null,
          data: <String, dynamic>{'order_id': 42},
        ),
        const DriverAssigned(42),
      );
    });

    test('the order id may come from a nested order', () {
      expect(
        parseRealtimeEvent(
          name: 'ssm.driver.location_updated',
          channelName: null,
          data: <String, dynamic>{
            'order': <String, dynamic>{'id': 9},
          },
        ),
        const DriverLocationUpdated(9),
      );
    });

    test('the order id falls back to the private-order channel name', () {
      expect(
        parseRealtimeEvent(
          name: 'ssm.driver.location_updated',
          channelName: 'private-order.77',
          data: <String, dynamic>{'latitude': 24.7},
        ),
        const DriverLocationUpdated(77),
      );
    });

    test('an order event without any order id is dropped', () {
      expect(
        parseRealtimeEvent(
          name: 'ssm.order.status_changed',
          channelName: 'private-customer.1',
          data: const <String, dynamic>{},
        ),
        isNull,
      );
    });

    test('notification.created carries the unread count when sent', () {
      expect(
        parseRealtimeEvent(
          name: 'ssm.notification.created',
          channelName: 'private-customer.1',
          data: <String, dynamic>{'unread_count': 4},
        ),
        const NotificationCreated(unreadCount: 4),
      );
    });

    test('unknown events are ignored', () {
      expect(
        parseRealtimeEvent(
          name: 'ssm.something.else',
          channelName: null,
          data: null,
        ),
        isNull,
      );
    });
  });

  group('StatusVersionGate', () {
    test('admits a newer version', () {
      final StatusVersionGate gate = StatusVersionGate();

      expect(gate.admit(1, 3), isTrue);
      expect(gate.admit(1, 4), isTrue);
    });

    test('drops an older version', () {
      final StatusVersionGate gate = StatusVersionGate()..admit(1, 5);

      expect(gate.admit(1, 4), isFalse);
    });

    test('drops the duplicate copy of the same version', () {
      final StatusVersionGate gate = StatusVersionGate()..admit(1, 5);

      expect(gate.admit(1, 5), isFalse);
    });

    test('tracks each order on its own', () {
      final StatusVersionGate gate = StatusVersionGate()..admit(1, 5);

      expect(gate.admit(2, 1), isTrue);
    });

    test('always admits an event without a version', () {
      final StatusVersionGate gate = StatusVersionGate()..admit(1, 5);

      expect(gate.admit(1, null), isTrue);
    });

    test('reset forgets every version', () {
      final StatusVersionGate gate = StatusVersionGate()..admit(1, 5);
      gate.reset();

      expect(gate.admit(1, 2), isTrue);
    });
  });
}
