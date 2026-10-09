import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/features/c2c_parcels/data/datasources/c2c_parcels_remote_data_source.dart';
import 'package:ssm/features/c2c_parcels/data/models/c2c_parcel_models.dart';
import 'package:ssm/features/c2c_parcels/data/models/requests/c2c_parcel_form.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_draft.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_quote.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_status.dart';

import '../../helpers/fake_dio_consumer.dart';

/// The sender view from the API guide's `GET /{id}` example.
Map<String, dynamic> _details({
  String role = 'sender',
  String status = 'driver_accepted',
  Map<String, dynamic>? actions,
}) => <String, dynamic>{
  'data': <String, dynamic>{
    'id': 12,
    'reference': 'C2C-261008-K3J9QX',
    'viewer_role': role,
    'status': status,
    'status_version': '5',
    'parcel': <String, dynamic>{
      'title': 'Birthday gift',
      'description': 'Wrapped box with a watch',
      'category': 'medium',
      'weight_kg': 3,
      'declared_value': 300,
      'is_fragile': 0,
      'pickup_instructions': 'Call on arrival',
      'delivery_instructions': 'Hand over only with the code',
    },
    'sender': <String, dynamic>{
      'name': 'Sara Ahmed',
      'phone': '+201000000001',
      'address': '12 Tahrir St',
      'latitude': 30.04,
      'longitude': 31.23,
      'details': <String, dynamic>{'floor': '3'},
    },
    'recipient': <String, dynamic>{
      'name': 'Rami Ali',
      'address': '5 Zamalek St',
      'latitude': '30.06',
      'longitude': '31.24',
      'details': <String, dynamic>{},
    },
    'pricing': <String, dynamic>{
      'distance_km': 2.4,
      'total_fee': 14.8,
      'currency': 'EGP',
    },
    'payment_method': 'cash_by_recipient',
    'images': <dynamic>[
      <String, dynamic>{'id': 3},
    ],
    'driver': <String, dynamic>{'id': 4, 'name': 'Ahmed M', 'phone': '+2010'},
    'timeline': <dynamic>[
      <String, dynamic>{
        'status': 'quoted',
        'status_version': 1,
        'occurred_at': '2026-10-08T12:00:00Z',
      },
      <String, dynamic>{'status': 'driver_accepted', 'status_version': 5},
    ],
    'actions': ?actions,
  },
};

const C2cQuoteRequest _request = C2cQuoteRequest(
  sender: GeoPoint(latitude: 30.0444, longitude: 31.2357),
  recipient: GeoPoint(latitude: 30.0626, longitude: 31.2497),
  category: ParcelCategory.medium,
  weightKg: 3,
  isFragile: false,
);

C2cParcelDraft _draft({List<C2cParcelPhoto>? photos}) => C2cParcelDraft(
  request: _request,
  sender: const C2cContact(
    name: 'Sara Ahmed',
    phone: '+966500000001',
    address: '12 Tahrir St',
    location: GeoPoint(latitude: 30.0444, longitude: 31.2357),
    floor: '3',
    notes: '  ',
  ),
  recipient: const C2cContact(
    name: 'Rami Ali',
    phone: '+966500000002',
    address: '5 Zamalek St',
    location: GeoPoint(latitude: 30.0626, longitude: 31.2497),
  ),
  title: ' Birthday gift ',
  description: 'Wrapped box',
  declaredValue: 300,
  paymentMethod: C2cPaymentMethod.cashByRecipient,
  photos: photos ?? const <C2cParcelPhoto>[],
  prohibitedItemsAcknowledged: true,
  quoteToken: 'tok-1',
);

void main() {
  group('C2cParcelModels.detailsFromJson', () {
    test('reads the sender view', () {
      final C2cParcelDetails parcel = C2cParcelModels.detailsFromJson(
        _details(),
      );

      expect(parcel.id, 12);
      expect(parcel.viewerRole, C2cViewerRole.sender);
      expect(parcel.status, C2cParcelStatus.driverAccepted);
      expect(parcel.statusVersion, 5);
      expect(parcel.item.category, ParcelCategory.medium);
      expect(
        parcel.recipient.location,
        const GeoPoint(latitude: 30.06, longitude: 31.24),
      );
      expect(parcel.sender.details, <String, String>{'floor': '3'});
      expect(parcel.pricing!.totalFee, 14.8);
      expect(parcel.paymentMethod, C2cPaymentMethod.cashByRecipient);
      expect(parcel.imageCount, 1);
      expect(parcel.driver!.name, 'Ahmed M');
      expect(
        parcel.timeline.map((C2cTimelineEntry e) => e.status),
        <C2cParcelStatus>[
          C2cParcelStatus.quoted,
          C2cParcelStatus.driverAccepted,
        ],
      );
    });

    test('a sender sees the sender-only details', () {
      final C2cParcelDetails parcel = C2cParcelModels.detailsFromJson(
        _details(),
      );

      expect(parcel.description, 'Wrapped box with a watch');
      expect(parcel.declaredValue, 300);
      expect(parcel.pickupInstructions, 'Call on arrival');
    });

    test('a recipient never sees the sender-only details', () {
      // Even if a response carried them.
      final C2cParcelDetails parcel = C2cParcelModels.detailsFromJson(
        _details(role: 'recipient'),
      );

      expect(parcel.description, isNull);
      expect(parcel.declaredValue, isNull);
      expect(parcel.pickupInstructions, isNull);
      expect(parcel.item.deliveryInstructions, 'Hand over only with the code');
    });

    test('without actions, the guide rules apply to role and status', () {
      final C2cParcelDetails sender = C2cParcelModels.detailsFromJson(
        _details(),
      );
      final C2cParcelDetails recipient = C2cParcelModels.detailsFromJson(
        _details(role: 'recipient'),
      );

      expect(sender.canCancel, isTrue);
      expect(recipient.canCancel, isFalse);
    });

    test('the server flags win', () {
      final C2cParcelDetails parcel = C2cParcelModels.detailsFromJson(
        _details(actions: <String, dynamic>{'can_cancel': false}),
      );

      expect(parcel.canCancel, isFalse);
    });

    test('no cancel once the driver has the parcel', () {
      final C2cParcelDetails parcel = C2cParcelModels.detailsFromJson(
        _details(
          status: 'picked_up',
          // A wrong flag can't re-open it.
          actions: <String, dynamic>{'can_cancel': true},
        ),
      );

      expect(parcel.canCancel, isFalse);
    });

    test('a return code is for the sender only', () {
      final Map<String, dynamic> actions = <String, dynamic>{
        'can_request_return_otp': true,
      };
      expect(
        C2cParcelModels.detailsFromJson(
          _details(status: 'returning_to_sender', actions: actions),
        ).canRequestOtp,
        isTrue,
      );
      expect(
        C2cParcelModels.detailsFromJson(
          _details(
            role: 'recipient',
            status: 'returning_to_sender',
            actions: actions,
          ),
        ).canRequestOtp,
        isFalse,
      );
    });

    test('an unknown status reads as unknown, not a crash', () {
      expect(
        C2cParcelModels.detailsFromJson(_details(status: 'teleported')).status,
        C2cParcelStatus.unknown,
      );
    });

    test('throws ServerException without an id', () {
      expect(
        () => C2cParcelModels.detailsFromJson(<String, dynamic>{
          'data': <String, dynamic>{'status': 'quoted'},
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('C2cParcelModels.pageFromJson', () {
    test('reads rows and paging, skipping rows without an id', () {
      final C2cParcelPage page = C2cParcelModels.pageFromJson(
        <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'id': 12,
              'reference': 'C2C-1',
              'viewer_role': 'sender',
              'status': 'out_for_delivery',
              'status_version': 8,
              'counterpart_name': 'Rami Ali',
              'total_fee': '14.80',
            },
            <String, dynamic>{'reference': 'no id'},
          ],
          'total_size': 31,
          'limit': 15,
          'offset': 2,
        },
        limit: 15,
        offset: 2,
      );

      expect(page.parcels.single.status, C2cParcelStatus.outForDelivery);
      expect(page.parcels.single.totalFee, 14.8);
      expect(page.hasMore, isTrue);
    });

    test('the last page has no more', () {
      final C2cParcelPage page = C2cParcelModels.pageFromJson(
        <String, dynamic>{'data': <dynamic>[], 'total_size': 30},
        limit: 15,
        offset: 2,
      );

      expect(page.hasMore, isFalse);
    });
  });

  group('C2cParcelModels.trackingFromJson', () {
    test('reads the live view', () {
      final C2cParcelTracking tracking = C2cParcelModels.trackingFromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'status': 'picked_up',
            'status_version': 7,
            'is_terminal': false,
            'pickup': <String, dynamic>{'latitude': 30.04, 'longitude': 31.23},
            'destination': <String, dynamic>{
              'latitude': 30.06,
              'longitude': 31.24,
            },
            'driver_location': <String, dynamic>{
              'latitude': 30.05,
              'longitude': 31.24,
              'recorded_at': '2026-10-08T12:05:00Z',
            },
            'eta_minutes': 6,
            'polling_interval_seconds': 15,
          },
        },
      );

      expect(tracking.status, C2cParcelStatus.pickedUp);
      expect(
        tracking.driverLocation!.point,
        const GeoPoint(latitude: 30.05, longitude: 31.24),
      );
      expect(tracking.etaMinutes, 6);
      expect(tracking.pollingIntervalSeconds, 15);
    });

    test('a recipient has no pickup point', () {
      final C2cParcelTracking tracking = C2cParcelModels.trackingFromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'status': 'delivered',
            'status_version': 9,
            'pickup': null,
            'driver_location': null,
            'polling_interval_seconds': null,
          },
        },
      );

      expect(tracking.pickup, isNull);
      expect(tracking.isTerminal, isTrue);
      expect(tracking.pollingIntervalSeconds, isNull);
    });
  });

  group('C2cParcelModels.otpFromJson', () {
    test('keeps the leading zeros of a numeric code', () {
      final C2cParcelOtp otp = C2cParcelModels.otpFromJson(<String, dynamic>{
        'data': <String, dynamic>{
          'otp': 42913,
          'expires_at': '2026-10-08T12:20:00+00:00',
          'purpose': 'delivery',
        },
      });

      expect(otp.code, '042913');
      expect(otp.purpose, C2cOtpPurpose.delivery);
    });

    test('reads a return code', () {
      final C2cParcelOtp otp = C2cParcelModels.otpFromJson(<String, dynamic>{
        'data': <String, dynamic>{'otp': '482913', 'purpose': 'return'},
      });

      expect(otp.purpose, C2cOtpPurpose.returnToSender);
    });

    test('throws ServerException without a code', () {
      expect(
        () => C2cParcelModels.otpFromJson(<String, dynamic>{
          'data': <String, dynamic>{},
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('C2cParcelForm.fields', () {
    test('sends every field the guide lists, blanks left out', () {
      expect(C2cParcelForm(_draft()).fields, <String, String>{
        'sender_name': 'Sara Ahmed',
        'sender_phone': '+966500000001',
        'sender_address': '12 Tahrir St',
        'sender_latitude': '30.0444',
        'sender_longitude': '31.2357',
        'sender_floor': '3',
        'recipient_name': 'Rami Ali',
        'recipient_phone': '+966500000002',
        'recipient_address': '5 Zamalek St',
        'recipient_latitude': '30.0626',
        'recipient_longitude': '31.2497',
        'category': 'medium',
        'weight_kg': '3.0',
        'is_fragile': '0',
        'title': 'Birthday gift',
        'description': 'Wrapped box',
        'declared_value': '300',
        'payment_method': 'cash_by_recipient',
        'prohibited_items_acknowledged': '1',
        'quote_token': 'tok-1',
      });
    });

    test('`jpg` goes as image/jpeg', () {
      expect(
        C2cParcelForm.mimeSubtype(
          const C2cParcelPhoto(path: 'p', fileName: 'a.JPG', sizeBytes: 1),
        ),
        'jpeg',
      );
    });
  });

  group('C2cParcelPhoto.issue', () {
    test('over 5 MB is refused', () {
      expect(
        const C2cParcelPhoto(
          path: 'p',
          fileName: 'a.png',
          sizeBytes: C2cParcelPhoto.maxBytes + 1,
        ).issue,
        C2cPhotoIssue.tooLarge,
      );
    });

    test('HEIC is refused', () {
      expect(
        const C2cParcelPhoto(path: 'p', fileName: 'a.heic', sizeBytes: 1).issue,
        C2cPhotoIssue.unsupportedType,
      );
    });

    test('a WebP under 5 MB is fine', () {
      expect(
        const C2cParcelPhoto(path: 'p', fileName: 'a.webp', sizeBytes: 1).issue,
        isNull,
      );
    });
  });

  group('C2cParcelsRemoteDataSource commands', () {
    late FakeDioConsumer consumer;
    late C2cParcelsRemoteDataSourceImpl remote;

    setUp(() {
      consumer = FakeDioConsumer(response: <String, dynamic>{'message': 'ok'});
      remote = C2cParcelsRemoteDataSourceImpl(consumer: consumer);
    });

    test('create is multipart with the Idempotency-Key', () async {
      consumer.response = _details();

      final C2cParcelDetails parcel = await remote.createParcel(
        _draft(),
        idempotencyKey: 'key-1',
      );

      expect(consumer.lastPath, ApiEndpoints.c2cParcels);
      expect(consumer.lastHeaders, <String, String>{
        'Idempotency-Key': 'key-1',
      });
      expect(consumer.lastFormData, isNotNull);
      expect(parcel.id, 12);
    });

    test('cancel sends the reason, note and expected_version', () async {
      await remote.cancelParcel(
        12,
        reason: C2cCancelReason.wrongAddress,
        note: ' wrong door ',
        expectedVersion: 5,
        idempotencyKey: 'key-2',
      );

      expect(consumer.lastPath, ApiEndpoints.c2cParcelCancel(12));
      expect(consumer.lastBody, <String, dynamic>{
        'reason_code': 'wrong_address',
        'note': 'wrong door',
        'expected_version': 5,
      });
      expect(consumer.lastHeaders, <String, String>{
        'Idempotency-Key': 'key-2',
      });
    });

    test('retry dispatch sends expected_version', () async {
      await remote.retryDispatch(
        12,
        expectedVersion: 4,
        idempotencyKey: 'key-3',
      );

      expect(consumer.lastPath, ApiEndpoints.c2cParcelRetryDispatch(12));
      expect(consumer.lastBody, <String, dynamic>{'expected_version': 4});
    });

    test('support sends the reason and description', () async {
      await remote.openSupportCase(
        12,
        reason: C2cSupportReason.parcelDamaged,
        description: ' Box crushed ',
        idempotencyKey: 'key-4',
      );

      expect(consumer.lastPath, ApiEndpoints.c2cParcelSupport(12));
      expect(consumer.lastBody, <String, dynamic>{
        'reason_code': 'parcel_damaged',
        'description': 'Box crushed',
      });
    });

    test('received parcels page through the recipient endpoint', () async {
      consumer.response = <String, dynamic>{'data': <dynamic>[]};

      await remote.getParcels(C2cParcelBox.received, limit: 15, offset: 2);

      expect(consumer.lastPath, ApiEndpoints.c2cParcelsReceived);
      expect(consumer.lastQuery, <String, dynamic>{'limit': 15, 'offset': 2});
    });
  });
}
