import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/features/loyalty/data/models/loyalty_history_model.dart';
import 'package:ssm/features/loyalty/data/models/loyalty_progress_model.dart';
import 'package:ssm/features/loyalty/domain/entities/loyalty_history.dart';
import 'package:ssm/features/loyalty/domain/entities/loyalty_progress.dart';
import 'package:flutter_test/flutter_test.dart';

LoyaltyProgress _progress(int current, int target) => LoyaltyProgress(
  currentProgress: current,
  eligibleOrdersRequired: target,
  ordersRemainingForNextReward: 0,
  availableFreeDeliveries: 0,
);

void main() {
  group('LoyaltyProgress.percent', () {
    test('7 of 10 is 70', () {
      expect(_progress(7, 10).percent, 70);
    });

    test('rounds to the nearest whole percent', () {
      expect(_progress(1, 3).percent, 33);
    });

    test('is 0 when no target is configured', () {
      expect(_progress(4, 0).percent, 0);
    });

    test('never exceeds 100', () {
      expect(_progress(12, 10).percent, 100);
    });
  });

  group('LoyaltyProgressModel.fromJson', () {
    test('reads all four fields from the data envelope', () {
      final LoyaltyProgress progress = LoyaltyProgressModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'current_progress': 7,
            'eligible_orders_required': 10,
            'orders_remaining_for_next_reward': 3,
            'available_free_deliveries': 2,
          },
        },
      );

      expect(
        progress.props,
        const LoyaltyProgress(
          currentProgress: 7,
          eligibleOrdersRequired: 10,
          ordersRemainingForNextReward: 3,
          availableFreeDeliveries: 2,
        ).props,
      );
    });

    test('accepts numeric strings', () {
      final LoyaltyProgress progress = LoyaltyProgressModel.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'current_progress': '2',
            'eligible_orders_required': '10',
            'orders_remaining_for_next_reward': '8',
            'available_free_deliveries': '0',
          },
        },
      );

      expect(progress.currentProgress, 2);
      expect(progress.ordersRemainingForNextReward, 8);
    });

    test('throws ServerException when a field is missing', () {
      expect(
        () => LoyaltyProgressModel.fromJson(<String, dynamic>{
          'data': <String, dynamic>{
            'current_progress': 7,
            'eligible_orders_required': 10,
            'orders_remaining_for_next_reward': 3,
          },
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

  group('LoyaltyHistoryModel.fromJson', () {
    test('reads the page size and the paginated total', () {
      final LoyaltyHistory history = LoyaltyHistoryModel.fromJson(
        <String, dynamic>{
          'data': <dynamic>[<String, dynamic>{}, <String, dynamic>{}],
          'pagination': <String, dynamic>{'total': 14},
        },
      );

      expect(
        history.props,
        const LoyaltyHistory(total: 14, recentCount: 2).props,
      );
    });

    test('falls back to the page size without pagination', () {
      final LoyaltyHistory history = LoyaltyHistoryModel.fromJson(
        <String, dynamic>{
          'data': <dynamic>[<String, dynamic>{}],
        },
      );

      expect(history.total, 1);
    });

    test('throws ServerException when data is not a list', () {
      expect(
        () => LoyaltyHistoryModel.fromJson(<String, dynamic>{'data': null}),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
