import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/push/notification_target.dart';
import 'package:ssm/core/push/push_banner_copy.dart';
import 'package:ssm/core/push/push_payload.dart';

void main() {
  group('NotificationTarget.resolve', () {
    test('an order with an id opens that order', () {
      expect(
        NotificationTarget.resolve(entityType: 'order', entityId: '42'),
        const OrderTarget(42),
      );
    });

    test('namespaced and plural order types are recognised', () {
      expect(
        NotificationTarget.resolve(
          entityType: r'App\Models\Order',
          entityId: '7',
        ),
        const OrderTarget(7),
      );
      expect(
        NotificationTarget.resolve(entityType: 'Orders', entityId: '7'),
        const OrderTarget(7),
      );
    });

    test('an order without a usable id falls back to the inbox', () {
      expect(
        NotificationTarget.resolve(entityType: 'order', entityId: 'abc'),
        const InboxTarget(),
      );
    });

    test('a parcel opens the parcels tab, with or without an id', () {
      expect(
        NotificationTarget.resolve(entityType: 'parcel', entityId: '3'),
        const ParcelsTarget(),
      );
      expect(
        NotificationTarget.resolve(entityType: 'parcel'),
        const ParcelsTarget(),
      );
    });

    test('a subscription opens the subscriptions tab', () {
      expect(
        NotificationTarget.resolve(entityType: 'subscription', entityId: '1'),
        const SubscriptionsTarget(),
      );
    });

    test('an unknown or missing type opens the inbox', () {
      expect(
        NotificationTarget.resolve(entityType: 'pharmacy_request'),
        const InboxTarget(),
      );
      expect(NotificationTarget.resolve(), const InboxTarget());
    });
  });

  group('PushPayload', () {
    test('parses the minimal data payload, strings only', () {
      final PushPayload payload = PushPayload.fromData(<String, dynamic>{
        'notification_id': '15',
        'type': 'order_status_changed',
        'entity_type': 'order',
        'entity_id': '42',
        'unread_count': '3',
      });

      expect(payload.notificationId, '15');
      expect(payload.unreadCount, 3);
      expect(payload.target, const OrderTarget(42));
    });

    test('blank values read as absent', () {
      final PushPayload payload = PushPayload.fromData(<String, dynamic>{
        'entity_type': ' ',
        'unread_count': '',
      });

      expect(payload.entityType, isNull);
      expect(payload.unreadCount, isNull);
    });

    test('toData round-trips through fromData', () {
      const PushPayload payload = PushPayload(
        notificationId: '9',
        entityType: 'parcel',
        entityId: '5',
        unreadCount: 0,
      );

      expect(PushPayload.fromData(payload.toData()), payload);
    });
  });

  group('PushBannerCopy', () {
    test('uses the payload text when the backend sends it', () {
      final PushBannerCopy copy = PushBannerCopy.forPayload(
        const PushPayload(title: 'Delivered', body: 'Enjoy!'),
        languageCode: 'en',
      );

      expect(copy.title, 'Delivered');
      expect(copy.body, 'Enjoy!');
    });

    test('falls back to generic copy naming the order', () {
      final PushBannerCopy copy = PushBannerCopy.forPayload(
        const PushPayload(entityType: 'order', entityId: '42'),
        languageCode: 'en',
      );

      expect(copy.title, 'Order update');
      expect(copy.body, contains('#42'));
    });

    test('anything but English reads as Arabic, the app default', () {
      final PushBannerCopy copy = PushBannerCopy.forPayload(
        const PushPayload(),
        languageCode: 'fr',
      );

      expect(copy.title, 'إشعار جديد');
    });
  });
}
