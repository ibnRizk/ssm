import 'package:dartz/dartz.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/subscriptions/data/datasources/subscriptions_remote_data_source.dart';
import 'package:ssm/features/subscriptions/data/models/active_subscription_model.dart';
import 'package:ssm/features/subscriptions/data/models/delivery_zone_model.dart';
import 'package:ssm/features/subscriptions/data/models/parcel_subscription_model.dart';
import 'package:ssm/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:ssm/features/subscriptions/data/repos/subscriptions_repository_impl.dart';
import 'package:ssm/features/subscriptions/domain/entities/active_subscription.dart';
import 'package:ssm/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio_consumer.dart';

SubscriptionPlan _plan(int id, {required int deliveries, double price = 100}) =>
    SubscriptionPlan(
      id: id,
      name: 'Plan $id',
      deliveriesCount: deliveries,
      validityDays: 30,
      price: price,
      currency: 'SAR',
    );

void main() {
  group('DeliveryZoneModel.listFromJson', () {
    test('reads a bare array, skipping unusable entries', () {
      final List<DeliveryZoneModel> zones = DeliveryZoneModel.listFromJson(
        <dynamic>[
          <String, dynamic>{'id': 1, 'name': 'تربة'},
          <String, dynamic>{'id': '2', 'display_name': 'العلاوة', 'name': 'x'},
          <String, dynamic>{'name': 'No id'},
        ],
      );

      expect(zones.map((z) => (z.id, z.name)), <(int, String)>[
        (1, 'تربة'),
        (2, 'العلاوة'),
      ]);
    });

    test('throws ServerException when the body is not a list', () {
      expect(
        () => DeliveryZoneModel.listFromJson(<String, dynamic>{'data': []}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('SubscriptionPlanModel.listFromJson', () {
    test('maps every plan field, price as a decimal string', () {
      final List<SubscriptionPlanModel> plans =
          SubscriptionPlanModel.listFromJson(<String, dynamic>{
            'data': <dynamic>[
              <String, dynamic>{
                'id': 5,
                'name': 'Monthly',
                'deliveries_count': 11,
                'validity_days': 30,
                'price': '100.00',
                'currency': 'SAR',
              },
            ],
          });

      expect(
        plans.single.props,
        const SubscriptionPlan(
          id: 5,
          name: 'Monthly',
          deliveriesCount: 11,
          validityDays: 30,
          price: 100,
          currency: 'SAR',
        ).props,
      );
    });

    test('skips a plan without a price', () {
      final List<SubscriptionPlanModel> plans =
          SubscriptionPlanModel.listFromJson(<String, dynamic>{
            'data': <dynamic>[
              <String, dynamic>{
                'id': 5,
                'name': 'Monthly',
                'deliveries_count': 11,
                'validity_days': 30,
              },
            ],
          });

      expect(plans, isEmpty);
    });
  });

  group('parcel plans', () {
    test('read the distance and weight limits', () {
      final List<SubscriptionPlanModel> plans =
          SubscriptionPlanModel.listFromJson(<String, dynamic>{
            'data': <dynamic>[
              <String, dynamic>{
                'id': 3,
                'name': 'Parcel 30',
                'deliveries_count': 30,
                'validity_days': 30,
                'price': '50.00',
                'max_distance_km': '5.00',
                'max_weight_kg': 5,
              },
            ],
          });

      expect(plans.single.maxDistanceKm, 5);
      expect(plans.single.maxWeightKg, 5);
    });

    test('store plans have no limits', () {
      final List<SubscriptionPlanModel> plans =
          SubscriptionPlanModel.listFromJson(<String, dynamic>{
            'data': <dynamic>[
              <String, dynamic>{
                'id': 5,
                'name': 'Monthly',
                'deliveries_count': 11,
                'validity_days': 30,
                'price': 100,
              },
            ],
          });

      expect(plans.single.maxDistanceKm, isNull);
      expect(plans.single.maxWeightKg, isNull);
    });
  });

  group('ParcelSubscriptionModel.listFromJson', () {
    test('reads balances, expiry and the plan name', () {
      final List<ActiveSubscription> subscriptions =
          ParcelSubscriptionModel.listFromJson(<String, dynamic>{
            'data': <dynamic>[
              <String, dynamic>{
                'id': 4,
                'status': 'active',
                'remaining_deliveries': 29,
                'expires_at': '2026-11-08T00:00:00.000000Z',
                'plan': <String, dynamic>{
                  'name': 'Parcel 30',
                  'deliveries_count': 30,
                },
              },
            ],
          });

      expect(
        subscriptions.single,
        ActiveSubscription(
          id: 4,
          deliveriesTotal: 30,
          deliveriesRemaining: 29,
          expiresAt: DateTime.utc(2026, 11, 8),
          planName: 'Parcel 30',
        ),
      );
    });

    test('skips inactive entries and entries without a balance', () {
      final List<ActiveSubscription> subscriptions =
          ParcelSubscriptionModel.listFromJson(<dynamic>[
            <String, dynamic>{
              'id': 1,
              'status': 'expired',
              'remaining_deliveries': 3,
            },
            <String, dynamic>{'id': 2, 'status': 'active'},
            <String, dynamic>{'id': 3, 'deliveries_remaining': 2},
          ]);

      expect(subscriptions.map((ActiveSubscription s) => s.id), <int>[3]);
      // No total anywhere: the remaining count stands in for it.
      expect(subscriptions.single.deliveriesTotal, 2);
    });

    test('reads a paginated body', () {
      final List<ActiveSubscription> subscriptions =
          ParcelSubscriptionModel.listFromJson(<String, dynamic>{
            'data': <String, dynamic>{
              'data': <dynamic>[
                <String, dynamic>{
                  'id': 1,
                  'remaining_deliveries': 5,
                  'deliveries_total': 10,
                },
              ],
            },
          });

      expect(subscriptions.single.deliveriesTotal, 10);
    });

    test('throws ServerException when the body holds no list', () {
      expect(
        () => ParcelSubscriptionModel.listFromJson(<String, dynamic>{
          'data': null,
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('ActiveSubscriptionModel.fromJson', () {
    test('is null when there is no active subscription', () {
      expect(
        ActiveSubscriptionModel.fromJson(<String, dynamic>{'data': null}),
        isNull,
      );
    });

    test('reads counts, expiry and the embedded plan name', () {
      final ActiveSubscription? current = ActiveSubscriptionModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'id': 9,
            'deliveries_total': 11,
            'deliveries_used': 4,
            'deliveries_remaining': 7,
            'expires_at': '2026-10-26T00:00:00.000000Z',
            'plan': <String, dynamic>{'name': 'Monthly'},
          },
        },
      );

      expect(current!.deliveriesRemaining, 7);
      expect(current.expiresAt, DateTime.utc(2026, 10, 26));
      expect(current.planName, 'Monthly');
    });

    test('throws ServerException without the data key', () {
      expect(
        () => ActiveSubscriptionModel.fromJson(<String, dynamic>{}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('SubscriptionPlan.bestValueId', () {
    test('is the plan with the most deliveries', () {
      expect(
        SubscriptionPlan.bestValueId(<SubscriptionPlan>[
          _plan(1, deliveries: 11),
          _plan(4, deliveries: 44),
          _plan(2, deliveries: 22),
        ]),
        4,
      );
    });

    test('breaks a delivery-count tie by price', () {
      expect(
        SubscriptionPlan.bestValueId(<SubscriptionPlan>[
          _plan(1, deliveries: 20, price: 100),
          _plan(2, deliveries: 20, price: 150),
        ]),
        2,
      );
    });

    test('is null for a single plan', () {
      expect(
        SubscriptionPlan.bestValueId(<SubscriptionPlan>[
          _plan(1, deliveries: 11),
        ]),
        isNull,
      );
    });
  });

  group('SubscriptionsRemoteDataSource', () {
    test('plans are requested for the zone_id query parameter', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'data': <dynamic>[]},
      );

      await SubscriptionsRemoteDataSourceImpl(consumer: consumer).getPlans(3);

      expect(consumer.lastPath, ApiEndpoints.subscriptionPlans);
      expect(consumer.lastQuery, <String, dynamic>{'zone_id': 3});
    });

    test('parcel plans come from their own endpoint', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'data': <dynamic>[]},
      );

      await SubscriptionsRemoteDataSourceImpl(
        consumer: consumer,
      ).getParcelPlans(3);

      expect(consumer.lastPath, ApiEndpoints.c2cParcelSubscriptionPlans);
      expect(consumer.lastQuery, <String, dynamic>{'zone_id': 3});
    });

    test('parcel balances come from their own endpoint', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{'data': <dynamic>[]},
      );

      await SubscriptionsRemoteDataSourceImpl(
        consumer: consumer,
      ).getParcelSubscriptions();

      expect(consumer.lastPath, ApiEndpoints.c2cParcelSubscriptions);
    });

    test('a purchase intent posts the plan id', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: <String, dynamic>{
          'data': <String, dynamic>{
            'status': 'pending',
            'payment_status': 'unpaid',
          },
        },
      );

      final Either<Failure, Unit> result = await SubscriptionsRepositoryImpl(
        remote: SubscriptionsRemoteDataSourceImpl(consumer: consumer),
      ).createPurchaseIntent(5);

      expect(result, const Right<Failure, Unit>(unit));
      expect(consumer.lastVerb, 'POST');
      expect(consumer.lastPath, ApiEndpoints.subscriptionPurchaseIntent);
      expect(consumer.lastBody, <String, dynamic>{'plan_id': 5});
    });

    test('an unknown plan maps to a failure, not a throw', () async {
      final FakeDioConsumer consumer = FakeDioConsumer()
        ..error = const ServerException(message: 'Plan not found');

      final Either<Failure, Unit> result = await SubscriptionsRepositoryImpl(
        remote: SubscriptionsRemoteDataSourceImpl(consumer: consumer),
      ).createPurchaseIntent(999999);

      expect(
        result,
        const Left<Failure, Unit>(ServerFailure(message: 'Plan not found')),
      );
    });
  });
}
