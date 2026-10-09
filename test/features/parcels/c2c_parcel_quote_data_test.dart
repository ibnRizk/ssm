import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/features/parcels/data/datasources/c2c_parcels_remote_data_source.dart';
import 'package:ssm/features/parcels/data/models/c2c_parcel_quote_model.dart';
import 'package:ssm/features/parcels/data/repos/c2c_parcels_repository_impl.dart';
import 'package:ssm/features/parcels/domain/entities/c2c_parcel_quote.dart';

import '../../helpers/fake_dio_consumer.dart';

const C2cQuoteRequest _request = C2cQuoteRequest(
  sender: GeoPoint(latitude: 24.7136, longitude: 46.6753),
  recipient: GeoPoint(latitude: 24.75, longitude: 46.7),
  size: ParcelSize.medium,
  weightKg: 3,
  isFragile: false,
  title: 'Gift Box',
);

void main() {
  group('C2cParcelQuoteModel.fromJson', () {
    test('reads the fees and the applied plan inside data', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'quote_token': 'tok-1',
            'base_total_fee': '50.00',
            'subscription_discount': '50.00',
            'total_fee': '0.00',
            'currency': 'SAR',
            'distance_km': 4.2,
            'applied_subscription': <String, dynamic>{
              'id': 7,
              'remaining_deliveries': 29,
              'plan': <String, dynamic>{'name': 'Parcel 30'},
            },
          },
        },
      );

      expect(
        quote.props,
        const C2cParcelQuote(
          quoteToken: 'tok-1',
          baseTotalFee: 50,
          subscriptionDiscount: 50,
          totalFee: 0,
          currency: 'SAR',
          distanceKm: 4.2,
          appliedSubscription: AppliedParcelSubscription(
            remainingDeliveries: 29,
            subscriptionId: 7,
            planName: 'Parcel 30',
          ),
        ).props,
      );
    });

    test('reads a body without the data wrapper', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{'base_total_fee': 18, 'total_fee': 18},
      );

      expect(quote.totalFee, 18);
      expect(quote.baseTotalFee, 18);
    });

    test('no applied plan means no discount', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'base_total_fee': 25,
            'subscription_discount': 0,
            'total_fee': 25,
            'applied_subscription': null,
          },
        },
      );

      expect(quote.appliedSubscription, isNull);
      expect(quote.subscriptionDiscount, 0);
    });

    test('ignores a discount reported without an applied plan', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'base_total_fee': 25,
            'subscription_discount': 5,
            'total_fee': 25,
          },
        },
      );

      expect(quote.subscriptionDiscount, 0);
    });

    test('an applied plan without a count still applies', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'subscription_discount': 10,
            'total_fee': 15,
            'applied_subscription': <String, dynamic>{},
          },
        },
      );

      expect(quote.appliedSubscription, const AppliedParcelSubscription());
      expect(quote.subscriptionDiscount, 10);
    });

    test('a missing base fee is the total plus the discount', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'subscription_discount': 10,
            'total_fee': 15,
            'applied_subscription': <String, dynamic>{
              'remaining_deliveries': 3,
            },
          },
        },
      );

      expect(quote.baseTotalFee, 25);
    });

    test('throws ServerException without a total fee', () {
      expect(
        () => C2cParcelQuoteModel.fromJson(<String, dynamic>{
          'data': <String, dynamic>{'base_total_fee': 25},
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('C2cParcelsRemoteDataSource.getQuote', () {
    test('posts the coordinates and parcel details as numbers', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'data': <String, dynamic>{'total_fee': 18},
        },
      );

      await C2cParcelsRemoteDataSourceImpl(
        consumer: consumer,
      ).getQuote(_request);

      expect(consumer.lastVerb, 'POST');
      expect(consumer.lastPath, ApiEndpoints.c2cParcelQuote);
      expect(consumer.lastBody, <String, dynamic>{
        'sender_latitude': 24.7136,
        'sender_longitude': 46.6753,
        'recipient_latitude': 24.75,
        'recipient_longitude': 46.7,
        'category': 'medium',
        'weight_kg': 3.0,
        'is_fragile': false,
        'title': 'Gift Box',
      });
    });

    test('leaves out a missing title', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'data': <String, dynamic>{'total_fee': 18},
        },
      );

      await C2cParcelsRemoteDataSourceImpl(consumer: consumer).getQuote(
        const C2cQuoteRequest(
          sender: GeoPoint(latitude: 1, longitude: 2),
          recipient: GeoPoint(latitude: 3, longitude: 4),
          size: ParcelSize.small,
          weightKg: 1,
          isFragile: true,
        ),
      );

      expect(consumer.lastBody!.containsKey('title'), isFalse);
      expect(consumer.lastBody!['category'], 'small');
    });
  });

  group('C2cParcelsRepositoryImpl.getQuote', () {
    test('maps a refused quote to a failure, not a throw', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ServerException(message: 'Too far');

      final Either<Failure, C2cParcelQuote> result =
          await C2cParcelsRepositoryImpl(
            remote: C2cParcelsRemoteDataSourceImpl(consumer: consumer),
          ).getQuote(_request);

      expect(
        result,
        const Left<Failure, C2cParcelQuote>(ServerFailure(message: 'Too far')),
      );
    });
  });
}
