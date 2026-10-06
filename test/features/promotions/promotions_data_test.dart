import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/api/api_endpoints.dart';
import 'package:ssm/core/error/exceptions.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/zone/zone_repository.dart';
import 'package:ssm/features/promotions/data/datasources/promotions_remote_data_source.dart';
import 'package:ssm/features/promotions/data/models/promotion_model.dart';
import 'package:ssm/features/promotions/data/repos/promotions_repository_impl.dart';
import 'package:ssm/features/promotions/domain/entities/store_promotion.dart';

import '../../helpers/fake_dio_consumer.dart';

class _FakeZoneRepository implements ZoneRepository {
  Either<Failure, List<int>> answer = const Right<Failure, List<int>>(<int>[7]);
  int calls = 0;

  @override
  Future<Either<Failure, List<int>>> ensureZoneIds() async {
    calls++;
    return answer;
  }

  @override
  Future<Either<Failure, Unit>> selectZoneIds(List<int> zoneIds) =>
      throw UnimplementedError();

  @override
  List<int> get currentZoneIds => throw UnimplementedError();

  @override
  Stream<List<int>> get zoneChanges => throw UnimplementedError();
}

/// The documented example entry.
Map<String, dynamic> _promotionJson() => <String, dynamic>{
  'id': 1,
  'store_id': 20,
  'store_path': '/stores/20',
  'store_url': 'https://ssm.husseintech.com/customer/stores/20',
  'store': <String, dynamic>{'id': 20, 'name': 'Mansoura Al Shifa Pharmacy'},
  'mobile_banner_url': 'https://cdn.example.com/mobile.webp',
  'desktop_banner_url': 'https://cdn.example.com/desktop.webp',
  'video_url': 'https://cdn.example.com/store.mp4',
};

Map<String, dynamic> _page(List<dynamic> promotions) => <String, dynamic>{
  'total_size': promotions.length,
  'limit': 10,
  'offset': 1,
  'promotions': promotions,
};

void main() {
  group('PromotionModel.tryFromJson', () {
    test('reads the documented example', () {
      expect(
        PromotionModel.tryFromJson(_promotionJson())!.props,
        const StorePromotion(
          id: 1,
          storeId: 20,
          storeName: 'Mansoura Al Shifa Pharmacy',
          bannerUrl: 'https://cdn.example.com/mobile.webp',
          videoUrl: 'https://cdn.example.com/store.mp4',
        ).props,
      );
    });

    test('accepts numeric strings', () {
      final PromotionModel model = PromotionModel.tryFromJson(
        _promotionJson()
          ..['id'] = '3'
          ..['store_id'] = '21',
      )!;
      expect((model.id, model.storeId), (3, 21));
    });

    test('falls back to store.id when store_id is missing', () {
      expect(
        PromotionModel.tryFromJson(
          _promotionJson()..remove('store_id'),
        )!.storeId,
        20,
      );
    });

    test('a null video means no video', () {
      final PromotionModel model = PromotionModel.tryFromJson(
        _promotionJson()..['video_url'] = null,
      )!;
      expect(model.hasVideo, isFalse);
    });

    test('a relative video path means no video', () {
      expect(
        PromotionModel.tryFromJson(
          _promotionJson()..['video_url'] = 'store-promotions/store.mp4',
        )!.videoUrl,
        isNull,
      );
    });

    test('keeps a promotion without a banner for its store name', () {
      final PromotionModel model = PromotionModel.tryFromJson(
        _promotionJson()..['mobile_banner_url'] = null,
      )!;
      expect(
        (model.bannerUrl, model.storeName),
        (null, 'Mansoura Al Shifa Pharmacy'),
      );
    });

    test('skips a promotion with neither banner nor store name', () {
      expect(
        PromotionModel.tryFromJson(
          _promotionJson()
            ..['mobile_banner_url'] = ''
            ..['store'] = null,
        ),
        isNull,
      );
    });

    test('skips a promotion with no store to open', () {
      expect(
        PromotionModel.tryFromJson(
          _promotionJson()
            ..remove('store_id')
            ..['store'] = <String, dynamic>{'name': 'Orphan'},
        ),
        isNull,
      );
    });

    test('skips a promotion without an id', () {
      expect(
        PromotionModel.tryFromJson(_promotionJson()..remove('id')),
        isNull,
      );
    });
  });

  group('PromotionModel.listFromJson', () {
    test('skips unusable entries, keeping the backend order', () {
      final List<PromotionModel> promotions = PromotionModel.listFromJson(
        _page(<dynamic>[
          _promotionJson()..['id'] = 2,
          'not an object',
          _promotionJson()..remove('id'),
          _promotionJson()..['id'] = 1,
        ]),
      );
      expect(promotions.map((PromotionModel p) => p.id), <int>[2, 1]);
    });

    test('reads an empty list', () {
      expect(PromotionModel.listFromJson(_page(<dynamic>[])), isEmpty);
    });

    test('throws ServerException without a promotions list', () {
      expect(
        () =>
            PromotionModel.listFromJson(<String, dynamic>{'promotions': null}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('PromotionsRemoteDataSourceImpl', () {
    test('GETs the featured promotions page by page and limit', () async {
      final FakeDioConsumer consumer = FakeDioConsumer(
        response: _page(<dynamic>[_promotionJson()]),
      );

      final List<PromotionModel> promotions =
          await PromotionsRemoteDataSourceImpl(
            consumer: consumer,
          ).getFeaturedPromotions(page: 2, limit: 10);

      expect(consumer.lastVerb, 'GET');
      expect(consumer.lastPath, ApiEndpoints.featuredPromotions);
      expect(consumer.lastPath, '/api/v1/stores/featured-promotions');
      expect(consumer.lastQuery, <String, dynamic>{'limit': 10, 'page': 2});
      expect(promotions.single.storeId, 20);
    });
  });

  group('PromotionsRepositoryImpl', () {
    late FakeDioConsumer consumer;
    late _FakeZoneRepository zone;
    late PromotionsRepositoryImpl repository;

    setUp(() {
      consumer = FakeDioConsumer(response: _page(<dynamic>[_promotionJson()]));
      zone = _FakeZoneRepository();
      repository = PromotionsRepositoryImpl(
        remote: PromotionsRemoteDataSourceImpl(consumer: consumer),
        zoneRepository: zone,
      );
    });

    test('ensures a zone before fetching page 1 of 10', () async {
      final Either<Failure, List<StorePromotion>> result = await repository
          .getFeaturedPromotions();

      expect(zone.calls, 1);
      expect(consumer.lastQuery, <String, dynamic>{'limit': 10, 'page': 1});
      expect(result.getOrElse(() => const <StorePromotion>[]), hasLength(1));
    });

    test('without a zone, fails without calling the endpoint', () async {
      zone.answer = const Left<Failure, List<int>>(ZoneUnavailableFailure());

      final Either<Failure, List<StorePromotion>> result = await repository
          .getFeaturedPromotions();

      expect(
        result,
        const Left<Failure, List<StorePromotion>>(ZoneUnavailableFailure()),
      );
      expect(consumer.lastPath, isNull);
    });

    test('maps a refused request to its failure', () async {
      consumer.error = const ForbiddenException();

      final Either<Failure, List<StorePromotion>> result = await repository
          .getFeaturedPromotions();

      expect(
        result.fold((Failure f) => f, (_) => null),
        isA<ForbiddenFailure>(),
      );
    });

    test('maps a malformed body to a ServerFailure', () async {
      consumer.response = <String, dynamic>{'data': <dynamic>[]};

      final Either<Failure, List<StorePromotion>> result = await repository
          .getFeaturedPromotions();

      expect(result.fold((Failure f) => f, (_) => null), isA<ServerFailure>());
    });
  });
}
