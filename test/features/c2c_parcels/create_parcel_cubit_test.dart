import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/location/geo_point.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_draft.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_quote.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_status.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/create_parcel_cubit.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/create_parcel_state.dart';

import 'fake_c2c_parcels_repository.dart';

final DateTime _now = DateTime.utc(2026, 10, 8, 12);

const C2cQuoteRequest _request = C2cQuoteRequest(
  sender: GeoPoint(latitude: 30.04, longitude: 31.23),
  recipient: GeoPoint(latitude: 30.06, longitude: 31.24),
  category: ParcelCategory.medium,
  weightKg: 3,
  isFragile: false,
  title: 'Gift',
);

C2cParcelQuote _quote({String token = 'tok-1', double total = 14.8}) =>
    C2cParcelQuote(
      quoteToken: token,
      baseTotalFee: total,
      subscriptionDiscount: 0,
      totalFee: total,
      currency: 'SAR',
      expiresAt: _now.add(const Duration(minutes: 15)),
    );

const C2cParcelPhoto _photo = C2cParcelPhoto(
  path: '/tmp/a.jpg',
  fileName: 'a.jpg',
  sizeBytes: 1000,
);

const C2cParcelDetails _created = C2cParcelDetails(
  id: 12,
  reference: 'C2C-1',
  viewerRole: C2cViewerRole.sender,
  status: C2cParcelStatus.dispatching,
  statusVersion: 3,
  item: C2cParcelItem(),
  sender: C2cParty(),
  recipient: C2cParty(),
);

const CreateParcelForm _form = CreateParcelForm(
  senderName: 'Sara',
  senderPhone: '0500000001',
  senderAddress: '12 Tahrir St',
  recipientName: 'Rami',
  recipientPhone: '0500000002',
  recipientAddress: '5 Zamalek St',
  title: 'Gift',
  prohibitedItemsAcknowledged: true,
);

void main() {
  late FakeC2cParcelsRepository repository;
  late CreateParcelCubit cubit;
  late int keys;
  late DateTime now;

  CreateParcelCubit build(C2cParcelQuote quote) => CreateParcelCubit(
    repository: repository,
    request: _request,
    quote: quote,
    newIdempotencyKey: () => 'key-${++keys}',
    now: () => now,
  );

  setUp(() {
    repository = FakeC2cParcelsRepository()
      ..onPick = ((_, _) async => const Right(<C2cParcelPhoto>[_photo]));
    keys = 0;
    now = _now;
    cubit = build(_quote());
  });

  tearDown(() => cubit.close());

  Future<void> withPhoto() => cubit.pickPhotos(C2cPhotoSource.gallery);

  group('photos', () {
    test('adds the picked photos', () async {
      await withPhoto();

      expect(cubit.state.photos, <C2cParcelPhoto>[_photo]);
    });

    test('asks only for the room left of five', () async {
      int? asked;
      repository.onPick = (_, int limit) async {
        asked = limit;
        return const Right(<C2cParcelPhoto>[_photo]);
      };
      await cubit.pickPhotos(C2cPhotoSource.gallery);
      await cubit.pickPhotos(C2cPhotoSource.gallery);

      expect(asked, 4);
    });

    test('leaves out a photo over 5 MB, and says so', () async {
      const C2cParcelPhoto big = C2cParcelPhoto(
        path: '/tmp/b.jpg',
        fileName: 'b.jpg',
        sizeBytes: C2cParcelPhoto.maxBytes + 1,
      );
      repository.onPick = (_, _) async =>
          const Right(<C2cParcelPhoto>[_photo, big]);

      await cubit.pickPhotos(C2cPhotoSource.gallery);

      expect(cubit.state.photos, <C2cParcelPhoto>[_photo]);
      expect(cubit.state.notice, const PhotosRejected(C2cPhotoIssue.tooLarge));
    });

    test('a refused gallery is reported', () async {
      repository.onPick = (_, _) async => const Left(MediaPickerFailure());

      await cubit.pickPhotos(C2cPhotoSource.gallery);

      expect(cubit.state.notice, const CreateFailed(MediaPickerFailure()));
      expect(cubit.state.picking, isFalse);
    });

    test('a photo can be removed', () async {
      await withPhoto();

      cubit.removePhoto(_photo);

      expect(cubit.state.photos, isEmpty);
    });
  });

  group('submit', () {
    test('needs at least one photo', () async {
      await cubit.submit(_form);

      expect(cubit.state.notice, const PhotosRequired());
      expect(repository.creates, isEmpty);
    });

    test('sends the draft at the quoted price, phones in E.164', () async {
      await withPhoto();
      repository.onCreate = (_, _) async => const Right(_created);

      await cubit.submit(_form);

      final (C2cParcelDraft draft, String key) = repository.creates.single;
      expect(key, 'key-1');
      expect(draft.request, _request);
      expect(draft.sender.location, _request.sender);
      expect(draft.sender.phone, '+966500000001');
      expect(draft.recipient.phone, '+966500000002');
      expect(draft.quoteToken, 'tok-1');
      expect(draft.photos, <C2cParcelPhoto>[_photo]);
      expect(cubit.state.created, _created);
    });

    test('a lost answer is retried with the same key', () async {
      await withPhoto();
      repository.onCreate = (_, _) async => const Left(NetworkFailure());
      await cubit.submit(_form);

      repository.onCreate = (_, _) async => const Right(_created);
      await cubit.submit(_form);

      expect(repository.creates.map((c) => c.$2), <String>['key-1', 'key-1']);
    });

    test('a form changed after a lost answer still reuses the key', () async {
      // If the first attempt landed, the server must see the same key —
      // a new one would create a second parcel.
      await withPhoto();
      repository.onCreate = (_, _) async => const Left(NetworkFailure());
      await cubit.submit(_form);

      repository.onCreate = (_, _) async => const Right(_created);
      cubit.setPaymentMethod(C2cPaymentMethod.cashByRecipient);
      await cubit.submit(_form);

      expect(repository.creates.map((c) => c.$2), <String>['key-1', 'key-1']);
    });

    test('idempotency_conflict says the parcel may already be sent', () async {
      await withPhoto();
      repository.onCreate = (_, _) async => const Left(
        ConflictFailure(code: C2cParcelErrorCode.idempotencyConflict),
      );

      await cubit.submit(_form);

      expect(cubit.state.notice, const MaybeAlreadySent());
      expect(cubit.state.submitting, isFalse);
    });

    test('request_in_progress keeps the key too', () async {
      await withPhoto();
      repository.onCreate = (_, _) async => const Left(
        ConflictFailure(code: C2cParcelErrorCode.requestInProgress),
      );
      await cubit.submit(_form);
      await cubit.submit(_form);

      expect(repository.creates.map((c) => c.$2), <String>['key-1', 'key-1']);
    });

    test('a refusal frees the key', () async {
      await withPhoto();
      repository.onCreate = (_, _) async =>
          const Left(ServerFailure(code: C2cParcelErrorCode.prohibitedContent));
      await cubit.submit(_form);
      await cubit.submit(_form);

      expect(repository.creates.map((c) => c.$2), <String>['key-1', 'key-2']);
      expect(
        cubit.state.notice,
        const CreateFailed(
          ServerFailure(code: C2cParcelErrorCode.prohibitedContent),
        ),
      );
    });

    test('price_changed fetches the new price and shows it', () async {
      await withPhoto();
      repository
        ..onCreate = ((_, _) async =>
            const Left(ConflictFailure(code: C2cParcelErrorCode.priceChanged)))
        ..onQuote = ((_) async => Right(_quote(token: 'tok-2', total: 16)));

      await cubit.submit(_form);

      expect(repository.quotes.single, _request);
      expect(cubit.state.quote.quoteToken, 'tok-2');
      expect(
        cubit.state.notice,
        PriceChanged(_quote(token: 'tok-2', total: 16)),
      );
      expect(cubit.state.created, isNull);
    });

    test('an expired price is refreshed before sending', () async {
      await withPhoto();
      now = _now.add(const Duration(minutes: 16));
      repository.onQuote = (_) async => Right(_quote(token: 'tok-2'));

      await cubit.submit(_form);

      expect(repository.creates, isEmpty);
      expect(cubit.state.notice, isA<PriceChanged>());
    });

    test('nothing more once created', () async {
      await withPhoto();
      repository.onCreate = (_, _) async => const Right(_created);
      await cubit.submit(_form);

      await cubit.submit(_form);

      expect(repository.creates, hasLength(1));
    });
  });
}
