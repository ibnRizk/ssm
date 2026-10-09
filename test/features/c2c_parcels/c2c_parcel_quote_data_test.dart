import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/features/c2c_parcels/data/datasources/c2c_parcels_remote_data_source.dart';
import 'package:ssm/features/c2c_parcels/data/datasources/c2c_photo_picker_data_source.dart';
import 'package:ssm/features/c2c_parcels/data/models/c2c_parcel_quote_model.dart';
import 'package:ssm/features/c2c_parcels/data/repos/c2c_parcels_repository_impl.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_draft.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_quote.dart';

import '../../helpers/fake_dio_consumer.dart';

const C2cQuoteRequest _request = C2cQuoteRequest(
  sender: GeoPoint(latitude: 24.7136, longitude: 46.6753),
  recipient: GeoPoint(latitude: 24.75, longitude: 46.7),
  category: ParcelCategory.medium,
  weightKg: 3,
  isFragile: false,
  title: 'Gift Box',
);

class _NoPhotos implements C2cPhotoPickerDataSource {
  @override
  Future<List<C2cParcelPhoto>> pick(
    C2cPhotoSource source, {
    required int limit,
  }) async => const <C2cParcelPhoto>[];
}

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

    test('reads the documented body: expiry and minutes, no plan', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'distance_km': 2.4,
            'base_fee': 5,
            'per_km_fee': 4.8,
            'total_fee': 14.8,
            'currency': 'EGP',
            'estimated_delivery_minutes': 16,
            'quote_token': 'eyJ0Ijo',
            'quote_expires_at': '2026-10-08T12:15:00+00:00',
          },
        },
      );

      expect(quote.totalFee, 14.8);
      expect(quote.baseTotalFee, 14.8);
      expect(quote.currency, 'EGP');
      expect(quote.estimatedDeliveryMinutes, 16);
      expect(quote.expiresAt, DateTime.utc(2026, 10, 8, 12, 15));
      expect(quote.appliedSubscription, isNull);
    });

    test('reads a body without the data wrapper', () {
      final C2cParcelQuote quote = C2cParcelQuoteModel.fromJson(
        <String, dynamic>{'base_total_fee': 18, 'total_fee': 18},
      );

      expect(quote.totalFee, 18);
      expect(quote.baseTotalFee, 18);
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
      // No base fee sent: the total plus the discount.
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

  group('C2cParcelQuote.isValidAt', () {
    final C2cParcelQuote quote = C2cParcelQuote(
      quoteToken: 'tok',
      baseTotalFee: 10,
      subscriptionDiscount: 0,
      totalFee: 10,
      currency: 'SAR',
      expiresAt: DateTime.utc(2026, 10, 8, 12, 15),
    );

    test('holds before the expiry', () {
      expect(quote.isValidAt(DateTime.utc(2026, 10, 8, 12, 14)), isTrue);
    });

    test('lapses at the expiry', () {
      expect(quote.isValidAt(DateTime.utc(2026, 10, 8, 12, 15)), isFalse);
    });

    test('never holds without a token', () {
      const C2cParcelQuote untokened = C2cParcelQuote(
        baseTotalFee: 10,
        subscriptionDiscount: 0,
        totalFee: 10,
        currency: 'SAR',
      );
      expect(untokened.isValidAt(DateTime.utc(2026)), isFalse);
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
          category: ParcelCategory.documents,
          weightKg: 1,
          isFragile: true,
        ),
      );

      expect(consumer.lastBody!.containsKey('title'), isFalse);
      expect(consumer.lastBody!['category'], 'documents');
    });
  });

  group('C2cParcelsRepositoryImpl.getQuote', () {
    test('maps a refused quote to a failure, not a throw', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ServerException(
          message: 'Too far',
          code: 'distance_too_long',
        );

      final Either<Failure, C2cParcelQuote> result =
          await C2cParcelsRepositoryImpl(
            remote: C2cParcelsRemoteDataSourceImpl(consumer: consumer),
            photoPicker: _NoPhotos(),
          ).getQuote(_request);

      expect(
        result,
        const Left<Failure, C2cParcelQuote>(
          ServerFailure(message: 'Too far', code: 'distance_too_long'),
        ),
      );
    });
  });
}
