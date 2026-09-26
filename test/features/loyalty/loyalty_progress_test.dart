import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/features/loyalty/data/models/loyalty_progress_model.dart';
import 'package:flutter_base/features/loyalty/domain/entities/loyalty_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoyaltyProgress.percent', () {
    test('7 of 10 is 70', () {
      expect(
        const LoyaltyProgress(
          currentProgress: 7,
          eligibleOrdersRequired: 10,
        ).percent,
        70,
      );
    });

    test('rounds to the nearest whole percent', () {
      expect(
        const LoyaltyProgress(
          currentProgress: 1,
          eligibleOrdersRequired: 3,
        ).percent,
        33,
      );
    });

    test('is 0 when no target is configured', () {
      expect(
        const LoyaltyProgress(
          currentProgress: 4,
          eligibleOrdersRequired: 0,
        ).percent,
        0,
      );
    });

    test('never exceeds 100', () {
      expect(
        const LoyaltyProgress(
          currentProgress: 12,
          eligibleOrdersRequired: 10,
        ).percent,
        100,
      );
    });
  });

  group('LoyaltyProgressModel.fromJson', () {
    test('reads progress from the data envelope', () {
      final LoyaltyProgress progress = LoyaltyProgressModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'current_progress': 7,
            'eligible_orders_required': 10,
            'orders_remaining_for_next_reward': 3,
          },
        },
      );

      expect(progress.currentProgress, 7);
      expect(progress.eligibleOrdersRequired, 10);
    });

    test('accepts numeric strings', () {
      final LoyaltyProgress progress = LoyaltyProgressModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'current_progress': '2',
            'eligible_orders_required': '10',
          },
        },
      );

      expect(progress.currentProgress, 2);
      expect(progress.eligibleOrdersRequired, 10);
    });

    test('throws ServerException when fields are missing', () {
      expect(
        () => LoyaltyProgressModel.fromJson(<String, dynamic>{
          'data': <String, dynamic>{},
        }),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException without the data envelope', () {
      expect(
        () => LoyaltyProgressModel.fromJson(<String, dynamic>{
          'current_progress': 7,
          'eligible_orders_required': 10,
        }),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
