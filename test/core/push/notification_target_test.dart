import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/push/notification_target.dart';

void main() {
  group('NotificationTarget.resolve — door-to-door parcels', () {
    test('`c2c_parcel` opens that parcel', () {
      expect(
        NotificationTarget.resolve(entityType: 'c2c_parcel', entityId: '12'),
        const C2cParcelTarget(12),
      );
    });

    test('the namespaced model opens it too', () {
      expect(
        NotificationTarget.resolve(
          entityType: r'App\Models\SsmC2cParcel',
          entityId: '12',
        ),
        const C2cParcelTarget(12),
      );
    });

    test('without an id it falls back to the inbox', () {
      expect(
        NotificationTarget.resolve(entityType: 'c2c_parcel'),
        const InboxTarget(),
      );
    });

    test('warehouse parcels still open the Parcels tab', () {
      expect(
        NotificationTarget.resolve(entityType: 'parcel', entityId: '3'),
        const ParcelsTarget(),
      );
    });
  });
}
