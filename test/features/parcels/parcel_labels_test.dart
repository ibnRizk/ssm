import 'package:flutter_base/core/location/geo_point.dart';
import 'package:flutter_base/core/widgets/vertical_timeline.dart';
import 'package:flutter_base/features/parcels/domain/entities/parcel.dart';
import 'package:flutter_base/features/parcels/presentation/utils/parcel_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/test_strings.dart';

Parcel _parcel(ParcelStatus status, {GeoPoint? dropoff}) => Parcel(
  id: 1,
  reference: 'SSM-P1',
  status: status,
  paymentType: ParcelPaymentType.prepaid,
  codAmount: 0,
  deliveryFee: 0,
  currency: 'SAR',
  dropoffLocation: dropoff,
);

const GeoPoint _point = GeoPoint(latitude: 24.7, longitude: 46.7);

List<TimelineStepState> _states(Parcel parcel) =>
    parcel.timeline.map((TimelineStep s) => s.state).toList();

void main() {
  setUpAll(() async {
    installEnglishStrings();
    await initializeDateFormatting('en');
  });

  tearDownAll(removeTestStrings);

  group('ParcelStatus', () {
    // The timeline compares enum positions; reordering the declaration
    // would silently mark the wrong steps done.
    test('is declared in delivery order', () {
      expect(ParcelStatus.values, <ParcelStatus>[
        ParcelStatus.processing,
        ParcelStatus.atWarehouse,
        ParcelStatus.outForDelivery,
        ParcelStatus.delivered,
      ]);
    });
  });

  group('timeline step states', () {
    test('processing: nothing reached yet', () {
      expect(_states(_parcel(ParcelStatus.processing)), <TimelineStepState>[
        TimelineStepState.pending,
        TimelineStepState.pending,
        TimelineStepState.pending,
      ]);
    });

    test('at the warehouse: the first step is current', () {
      expect(_states(_parcel(ParcelStatus.atWarehouse)), <TimelineStepState>[
        TimelineStepState.active,
        TimelineStepState.pending,
        TimelineStepState.pending,
      ]);
    });

    test('out for delivery: warehouse done, delivery current', () {
      expect(_states(_parcel(ParcelStatus.outForDelivery)), <TimelineStepState>[
        TimelineStepState.completed,
        TimelineStepState.active,
        TimelineStepState.pending,
      ]);
    });

    test('delivered: every step done', () {
      expect(_states(_parcel(ParcelStatus.delivered)), <TimelineStepState>[
        TimelineStepState.completed,
        TimelineStepState.completed,
        TimelineStepState.completed,
      ]);
    });
  });

  group('timeline subtitles', () {
    String deliveringSubtitle(Parcel parcel) => parcel.timeline[1].subtitle;

    test('asks for the location while none was sent', () {
      expect(
        deliveringSubtitle(_parcel(ParcelStatus.atWarehouse)),
        'Waiting for you to send your location',
      );
    });

    test('confirms a location that was sent', () {
      expect(
        deliveringSubtitle(_parcel(ParcelStatus.atWarehouse, dropoff: _point)),
        'Location received — delivery starts soon',
      );
    });

    test('says the driver is on the way once out for delivery', () {
      expect(
        deliveringSubtitle(_parcel(ParcelStatus.outForDelivery)),
        'The driver is on the way to you',
      );
    });

    test('the last step confirms delivery', () {
      expect(
        _parcel(ParcelStatus.delivered).timeline[2].subtitle,
        'Delivered to you',
      );
    });
  });

  group('parcelUpdatedLabel', () {
    final DateTime now = DateTime(2026, 9, 26, 10);

    String label(DateTime updatedAt) =>
        parcelUpdatedLabel(updatedAt, now, 'en');

    test('under a minute is "just now"', () {
      expect(
        label(now.subtract(const Duration(seconds: 30))),
        'Updated just now',
      );
    });

    test('a timestamp in the future (clock skew) is "just now"', () {
      expect(label(now.add(const Duration(minutes: 3))), 'Updated just now');
    });

    test('minutes', () {
      expect(
        label(now.subtract(const Duration(minutes: 5))),
        'Updated 5 min ago',
      );
    });

    test('hours', () {
      expect(label(now.subtract(const Duration(hours: 3))), 'Updated 3 h ago');
    });

    test('a day or more shows the date', () {
      expect(label(DateTime(2026, 9, 24, 10)), 'Updated Sep 24, 2026');
    });
  });
}
