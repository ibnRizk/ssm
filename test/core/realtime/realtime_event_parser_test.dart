import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/core/realtime/realtime_event.dart';
import 'package:ssm/core/realtime/realtime_event_parser.dart';
import 'package:ssm/core/realtime/status_version_gate.dart';

void main() {
  group('parseRealtimeEvent — door-to-door parcels', () {
    test('every status event reads as a status change', () {
      for (final String name in <String>[
        'parcel.created',
        'parcel.status_changed',
        'parcel.driver_assigned',
        'parcel.cancelled',
        'parcel.failed_delivery',
        'parcel.return_started',
        'parcel.returned_to_sender',
        '.parcel.delivered',
      ]) {
        expect(
          parseRealtimeEvent(
            name: name,
            channelName: null,
            data: <String, dynamic>{
              'parcel_id': 12,
              'status': 'picked_up',
              'status_version': 7,
            },
          ),
          const ParcelStatusChanged(12, status: 'picked_up', statusVersion: 7),
          reason: name,
        );
      }
    });

    test('a driver location carries the position', () {
      expect(
        parseRealtimeEvent(
          name: 'parcel.driver_location_updated',
          channelName: 'private-c2c-parcel.12.tracking',
          data: <String, dynamic>{
            'driver_id': 4,
            'latitude': '30.05',
            'longitude': 31.24,
            'heading': 90,
            'recorded_at': '2026-10-08T12:05:00Z',
          },
        ),
        ParcelDriverLocationUpdated(
          12,
          location: const GeoPoint(latitude: 30.05, longitude: 31.24),
          heading: 90,
          recordedAt: DateTime.utc(2026, 10, 8, 12, 5),
        ),
      );
    });

    test('a location without coordinates is dropped', () {
      expect(
        parseRealtimeEvent(
          name: 'parcel.driver_location_updated',
          channelName: 'private-c2c-parcel.12.tracking',
          data: <String, dynamic>{'latitude': 30.05},
        ),
        isNull,
      );
    });

    test('a status event without any parcel id is dropped', () {
      expect(
        parseRealtimeEvent(
          name: 'parcel.status_changed',
          channelName: 'private-customer.1',
          data: <String, dynamic>{'status': 'picked_up'},
        ),
        isNull,
      );
    });
  });

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
