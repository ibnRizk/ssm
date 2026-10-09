import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/pagination/load_more_status.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel.dart';
import 'package:ssm/features/c2c_parcels/domain/entities/c2c_parcel_status.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/c2c_parcels_list_cubit.dart';
import 'package:ssm/features/c2c_parcels/presentation/cubit/c2c_parcels_list_state.dart';

import 'fake_c2c_parcels_repository.dart';

C2cParcelSummary _row(int id) => C2cParcelSummary(
  id: id,
  reference: 'C2C-$id',
  viewerRole: C2cViewerRole.sender,
  status: C2cParcelStatus.dispatching,
  statusVersion: 1,
);

C2cParcelPage _page(List<int> ids, {required int offset, int total = 30}) =>
    C2cParcelPage(
      parcels: ids.map(_row).toList(),
      totalSize: total,
      limit: 15,
      offset: offset,
    );

void main() {
  late FakeC2cParcelsRepository repository;
  late C2cParcelsListCubit cubit;

  setUp(() {
    repository = FakeC2cParcelsRepository();
    cubit = C2cParcelsListCubit(
      box: C2cParcelBox.received,
      repository: repository,
    );
  });

  tearDown(() => cubit.close());

  C2cParcelsListLoaded loaded() => cubit.state as C2cParcelsListLoaded;

  test('loads the first page of its box', () async {
    repository.onPage = (_, _, int offset) async =>
        Right(_page(<int>[1, 2], offset: offset));

    await cubit.load();

    expect(repository.pages.single, (C2cParcelBox.received, 15, 1));
    expect(loaded().parcels.map((C2cParcelSummary p) => p.id), <int>[1, 2]);
    expect(loaded().hasMore, isTrue);
  });

  test('a failed first load is an error', () async {
    repository.onPage = (_, _, _) async => const Left(NetworkFailure());

    await cubit.load();

    expect(cubit.state, const C2cParcelsListError(NetworkFailure()));
  });

  test('a failed reload keeps the list', () async {
    repository.onPage = (_, _, int offset) async =>
        Right(_page(<int>[1], offset: offset));
    await cubit.load();

    repository.onPage = (_, _, _) async => const Left(NetworkFailure());
    await cubit.load();

    expect(loaded().parcels, hasLength(1));
  });

  test('loads the next page, skipping rows it already has', () async {
    repository.onPage = (_, _, int offset) async => Right(
      offset == 1
          ? _page(<int>[1, 2], offset: 1)
          // A new parcel shifted page 2 by one.
          : _page(<int>[2, 3], offset: 2),
    );
    await cubit.load();

    await cubit.loadMore();

    expect(repository.pages.last.$3, 2);
    expect(loaded().parcels.map((C2cParcelSummary p) => p.id), <int>[1, 2, 3]);
  });

  test('a failed next page shows a retry row', () async {
    repository.onPage = (_, _, int offset) async =>
        Right(_page(<int>[1], offset: offset));
    await cubit.load();

    repository.onPage = (_, _, _) async => const Left(NetworkFailure());
    await cubit.loadMore();

    expect(loaded().loadMore, const LoadMoreFailed(NetworkFailure()));
  });

  test('scrolling never retries a failed next page by itself', () async {
    repository.onPage = (_, _, int offset) async =>
        Right(_page(<int>[1], offset: offset));
    await cubit.load();
    repository.onPage = (_, _, _) async => const Left(NetworkFailure());
    await cubit.loadMore();
    final int before = repository.pages.length;

    cubit
      ..loadMoreOnScroll()
      ..loadMoreOnScroll();
    await pumpEventQueue();

    expect(repository.pages, hasLength(before));
  });

  test('the retry button still retries a failed next page', () async {
    repository.onPage = (_, _, int offset) async =>
        Right(_page(<int>[1], offset: offset));
    await cubit.load();
    repository.onPage = (_, _, _) async => const Left(NetworkFailure());
    await cubit.loadMore();
    final int before = repository.pages.length;

    await cubit.loadMore();

    expect(repository.pages, hasLength(before + 1));
  });

  test('re-reading one parcel keeps every page loaded', () async {
    repository.onPage = (_, _, int offset) async => Right(
      offset == 1 ? _page(<int>[1, 2], offset: 1) : _page(<int>[3], offset: 2),
    );
    await cubit.load();
    await cubit.loadMore();
    repository.onDetails = () async => const Right(
      C2cParcelDetails(
        id: 3,
        reference: 'C2C-3',
        viewerRole: C2cViewerRole.recipient,
        status: C2cParcelStatus.delivered,
        statusVersion: 9,
        item: C2cParcelItem(),
        sender: C2cParty(),
        recipient: C2cParty(),
      ),
    );
    final int pagesBefore = repository.pages.length;

    await cubit.refreshParcel(3);

    expect(repository.pages, hasLength(pagesBefore));
    expect(loaded().parcels.map((C2cParcelSummary p) => p.id), <int>[1, 2, 3]);
    expect(loaded().parcels.last.status, C2cParcelStatus.delivered);
    expect(loaded().page, 2);
  });

  test('no next page after the last', () async {
    repository.onPage = (_, _, int offset) async =>
        Right(_page(<int>[1], offset: offset, total: 1));
    await cubit.load();

    await cubit.loadMore();

    expect(repository.pages, hasLength(1));
  });
}
