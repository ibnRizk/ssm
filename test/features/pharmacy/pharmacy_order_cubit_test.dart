import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/features/addresses/domain/entities/address.dart';
import 'package:ssm/features/addresses/domain/repos/address_repository.dart';
import 'package:ssm/features/pharmacy/domain/entities/pharmacy_request.dart';
import 'package:ssm/features/pharmacy/domain/entities/prescription_image.dart';
import 'package:ssm/features/pharmacy/domain/repos/pharmacy_repository.dart';
import 'package:ssm/features/pharmacy/presentation/cubit/pharmacy_order_cubit.dart';
import 'package:ssm/features/pharmacy/presentation/cubit/pharmacy_order_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_catalog_repository.dart';

class _FakeAddressRepository implements AddressRepository {
  Either<Failure, List<Address>> answer = const Right<Failure, List<Address>>(
    <Address>[],
  );

  @override
  Future<Either<Failure, List<Address>>> getAddresses() async => answer;

  @override
  Future<Either<Failure, Unit>> addAddress(NewAddress address) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAddress(int id) =>
      throw UnimplementedError();
}

class _FakePharmacyRepository implements PharmacyRepository {
  PharmacyRequestDraft? submitted;
  Either<Failure, PharmacyRequestReceipt> submitAnswer =
      const Right<Failure, PharmacyRequestReceipt>(
        PharmacyRequestReceipt(id: 12, warning: 'Prices may change.'),
      );
  Either<Failure, PrescriptionImage?> pickAnswer =
      const Right<Failure, PrescriptionImage?>(null);

  @override
  Future<Either<Failure, PharmacyRequestReceipt>> submit(
    PharmacyRequestDraft draft,
  ) async {
    submitted = draft;
    return submitAnswer;
  }

  @override
  Future<Either<Failure, PrescriptionImage?>> pickPrescription(
    PrescriptionSource source,
  ) async => pickAnswer;
}

const Address _home = Address(
  id: 3,
  type: AddressType.home,
  contactPersonName: 'Sara Customer',
  contactPersonNumber: '+966512345678',
  address: 'Olaya St 12, Riyadh',
  location: GeoPoint(latitude: 24.71, longitude: 46.68),
);

const PrescriptionImage _photo = PrescriptionImage(
  path: '/tmp/rx.jpg',
  fileName: 'rx.jpg',
  sizeBytes: 1024,
);

/// Bloc delivers stream events asynchronously — let them arrive.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeCatalogRepository catalog;
  late _FakeAddressRepository addresses;
  late _FakePharmacyRepository pharmacy;
  late PharmacyOrderCubit cubit;
  late List<PharmacyNotice> notices;
  late StreamSubscription<PharmacyOrderState> subscription;

  setUp(() {
    catalog = FakeCatalogRepository();
    addresses = _FakeAddressRepository();
    pharmacy = _FakePharmacyRepository();
    cubit = PharmacyOrderCubit(
      pharmacyRepository: pharmacy,
      catalogRepository: catalog,
      addressRepository: addresses,
    );
    notices = <PharmacyNotice>[];
    subscription = cubit.stream.listen((PharmacyOrderState state) {
      if (state.notice case final PharmacyNotice notice) notices.add(notice);
    });
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  Future<void> loadOptions({
    List<Address> saved = const <Address>[_home],
  }) async {
    addresses.answer = Right<Failure, List<Address>>(saved);
    final Future<void> load = cubit.loadOptions();
    catalog.storeCalls.last.succeed(storesPage(<int>[4, 5], total: 2));
    await load;
  }

  test('offers the zone stores and preselects the first address', () async {
    await loadOptions();

    expect(catalog.storeCalls.single.page, 1);
    expect(cubit.state.options, isA<PharmacyOptionsLoaded>());
    expect(cubit.state.selectedAddress, _home);
    expect(cubit.state.selectedPharmacy, isNull, reason: 'the customer picks');
  });

  test('a failed options load is an error the screen can retry', () async {
    final Future<void> load = cubit.loadOptions();
    catalog.storeCalls.single.fail(const NetworkFailure());
    await load;

    expect(cubit.state.options, const PharmacyOptionsError(NetworkFailure()));
  });

  test('says what is missing, in order, without sending', () async {
    await loadOptions(saved: const <Address>[]);

    await cubit.submit('Vitamin D');
    cubit.selectPharmacy(4);
    await cubit.submit('Vitamin D');

    await _settle();

    expect(notices, <PharmacyNotice>[
      const PharmacyIncomplete(1, PharmacyRequestIssue.noPharmacy),
      const PharmacyIncomplete(2, PharmacyRequestIssue.noAddress),
    ]);
    expect(pharmacy.submitted, isNull);
  });

  test('needs a text or a photo', () async {
    await loadOptions();
    cubit.selectPharmacy(4);

    await cubit.submit('   ');

    await _settle();

    expect(
      notices.single,
      const PharmacyIncomplete(1, PharmacyRequestIssue.noContent),
    );
  });

  test('sends the request with the chosen address as recipient', () async {
    await loadOptions();
    cubit.selectPharmacy(4);

    await cubit.submit('  Vitamin D  ');

    expect(
      pharmacy.submitted,
      const PharmacyRequestDraft(
        pharmacyStoreId: 4,
        requestText: 'Vitamin D',
        recipientName: 'Sara Customer',
        recipientPhone: '+966512345678',
        deliveryAddress: 'Olaya St 12, Riyadh',
        location: GeoPoint(latitude: 24.71, longitude: 46.68),
      ),
    );
    expect(
      cubit.state.receipt,
      const PharmacyRequestReceipt(id: 12, warning: 'Prices may change.'),
    );
    expect(cubit.state.submitting, isFalse);
  });

  test('a photo alone is enough', () async {
    await loadOptions();
    cubit.selectPharmacy(4);
    pharmacy.pickAnswer = const Right<Failure, PrescriptionImage?>(_photo);
    await cubit.pickPrescription(PrescriptionSource.gallery);

    await cubit.submit('');

    expect(pharmacy.submitted?.prescription, _photo);
    expect(pharmacy.submitted?.requestText, isNull);
  });

  test('a refused request keeps the form and reports why', () async {
    await loadOptions();
    cubit.selectPharmacy(5);
    pharmacy.submitAnswer = const Left<Failure, PharmacyRequestReceipt>(
      ServerFailure(message: 'Not an active pharmacy'),
    );

    await cubit.submit('Vitamin D');

    expect(cubit.state.receipt, isNull);
    expect(cubit.state.pharmacyId, 5);
    await _settle();
    expect(
      notices.single,
      const PharmacyActionFailed(
        1,
        ServerFailure(message: 'Not an active pharmacy'),
      ),
    );
  });

  test('a photo the backend would refuse is not attached', () async {
    pharmacy.pickAnswer = const Right<Failure, PrescriptionImage?>(
      PrescriptionImage(
        path: '/tmp/rx.heic',
        fileName: 'rx.heic',
        sizeBytes: 1,
      ),
    );

    await cubit.pickPrescription(PrescriptionSource.camera);

    expect(cubit.state.prescription, isNull);
    await _settle();
    expect(
      notices.single,
      const PrescriptionRejected(1, PrescriptionImageIssue.unsupportedType),
    );
  });

  test('a cancelled pick changes nothing', () async {
    await cubit.pickPrescription(PrescriptionSource.gallery);

    expect(cubit.state.prescription, isNull);
    expect(cubit.state.picking, isFalse);
    await _settle();
    expect(notices, isEmpty);
  });

  test('a camera that will not open is reported', () async {
    pharmacy.pickAnswer = const Left<Failure, PrescriptionImage?>(
      MediaPickerFailure(),
    );

    await cubit.pickPrescription(PrescriptionSource.camera);

    await _settle();

    expect(notices.single, const PharmacyActionFailed(1, MediaPickerFailure()));
  });

  test('removing the photo detaches it', () async {
    pharmacy.pickAnswer = const Right<Failure, PrescriptionImage?>(_photo);
    await cubit.pickPrescription(PrescriptionSource.gallery);

    cubit.removePrescription();

    expect(cubit.state.prescription, isNull);
  });

  test('a reload keeps choices that still exist', () async {
    await loadOptions();
    cubit.selectPharmacy(5);

    await loadOptions();

    expect(cubit.state.pharmacyId, 5);
    expect(cubit.state.addressId, _home.id);
    expect(cubit.state.selectedPharmacy?.id, 5);
  });
}
