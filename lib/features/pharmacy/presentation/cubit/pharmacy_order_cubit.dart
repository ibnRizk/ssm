import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../addresses/domain/repos/address_repository.dart';
import '../../../catalog/domain/entities/catalog_page.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../../catalog/domain/repos/catalog_repository.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../../domain/entities/prescription_image.dart';
import '../../domain/repos/pharmacy_repository.dart';
import 'pharmacy_order_state.dart';

/// Screen-scoped (one per pharmacy-order route). The request text lives in
/// the screen's text field and is handed to [submit].
class PharmacyOrderCubit extends Cubit<PharmacyOrderState> {
  final PharmacyRepository pharmacyRepository;
  final CatalogRepository catalogRepository;
  final AddressRepository addressRepository;

  PharmacyOrderCubit({
    required this.pharmacyRepository,
    required this.catalogRepository,
    required this.addressRepository,
  }) : super(const PharmacyOrderState());

  /// The backend's store category for pharmacies; only its stores are
  /// offered, so a restaurant or bakery can't be picked.
  static const int pharmacyCategoryId = 3;

  /// One generous page covers a zone; there's no paging in a picker sheet.
  static const int pharmaciesPageSize = 50;

  int _noticeSeq = 0;

  /// Fetches the pharmacies and the customer's addresses concurrently. Keeps
  /// the current choices when they still exist; otherwise the first
  /// address is chosen, while the pharmacy is left for the customer.
  Future<void> loadOptions() async {
    emit(state.copyWith(options: const PharmacyOptionsLoading()));
    final (
      Either<Failure, CatalogPage<Store>> stores,
      Either<Failure, List<Address>> addresses,
    ) = await (
      catalogRepository.getCategoryStores(
        categoryId: pharmacyCategoryId,
        page: 1,
        pageSize: pharmaciesPageSize,
      ),
      addressRepository.getAddresses(),
    ).wait;
    if (isClosed) return;

    final Failure? failure = stores.fold(
      (Failure f) => f,
      (_) => addresses.fold((Failure f) => f, (_) => null),
    );
    if (failure != null) {
      emit(state.copyWith(options: PharmacyOptionsError(failure)));
      return;
    }
    final List<Store> pharmacies = stores.fold(
      (_) => const <Store>[],
      (CatalogPage<Store> page) => page.items,
    );
    final List<Address> saved = addresses.getOrElse(() => const <Address>[]);

    emit(
      PharmacyOrderState(
        options: PharmacyOptionsLoaded(
          pharmacies: pharmacies,
          addresses: saved,
        ),
        pharmacyId: pharmacies.any((Store s) => s.id == state.pharmacyId)
            ? state.pharmacyId
            : null,
        addressId: saved.any((Address a) => a.id == state.addressId)
            ? state.addressId
            : saved.firstOrNull?.id,
        prescription: state.prescription,
        picking: state.picking,
        submitting: state.submitting,
        receipt: state.receipt,
      ),
    );
  }

  void selectPharmacy(int storeId) => emit(state.copyWith(pharmacyId: storeId));

  void selectAddress(int addressId) =>
      emit(state.copyWith(addressId: addressId));

  /// Attaches a photo from [source]. One the backend would refuse (too
  /// large, wrong type) isn't attached; the customer is told why instead.
  Future<void> pickPrescription(PrescriptionSource source) async {
    if (state.picking || state.submitting) return;
    emit(state.copyWith(picking: true));
    final Either<Failure, PrescriptionImage?> result = await pharmacyRepository
        .pickPrescription(source);
    if (isClosed) return;
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          picking: false,
          notice: PharmacyActionFailed(++_noticeSeq, failure),
        ),
      ),
      (PrescriptionImage? image) {
        final PrescriptionImageIssue? issue = image?.issue;
        if (image == null) {
          emit(state.copyWith(picking: false));
        } else if (issue != null) {
          emit(
            state.copyWith(
              picking: false,
              notice: PrescriptionRejected(++_noticeSeq, issue),
            ),
          );
        } else {
          emit(state.copyWith(picking: false, prescription: image));
        }
      },
    );
  }

  void removePrescription() {
    if (state.submitting) return;
    emit(state.copyWith(clearPrescription: true));
  }

  /// Sends the request, or says what's missing. Ignored while sending, and
  /// once sent.
  Future<void> submit(String requestText) async {
    if (state.submitting || state.receipt != null) return;
    final PharmacyRequestIssue? issue = _issue(requestText);
    if (issue != null) {
      emit(state.copyWith(notice: PharmacyIncomplete(++_noticeSeq, issue)));
      return;
    }
    final Address address = state.selectedAddress!;
    final String text = requestText.trim();
    final PharmacyRequestDraft draft = PharmacyRequestDraft(
      pharmacyStoreId: state.pharmacyId!,
      requestText: text.isEmpty ? null : text,
      prescription: state.prescription,
      recipientName: address.contactPersonName,
      recipientPhone: address.contactPersonNumber,
      deliveryAddress: address.address,
      location: address.location,
    );

    emit(state.copyWith(submitting: true));
    final Either<Failure, PharmacyRequestReceipt> result =
        await pharmacyRepository.submit(draft);
    if (isClosed) return;
    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          submitting: false,
          notice: PharmacyActionFailed(++_noticeSeq, failure),
        ),
        (PharmacyRequestReceipt receipt) =>
            state.copyWith(submitting: false, receipt: receipt),
      ),
    );
  }

  PharmacyRequestIssue? _issue(String requestText) {
    if (state.selectedPharmacy == null) return PharmacyRequestIssue.noPharmacy;
    if (state.selectedAddress == null) return PharmacyRequestIssue.noAddress;
    if (!PharmacyRequestDraft.hasContent(
      requestText: requestText,
      prescription: state.prescription,
    )) {
      return PharmacyRequestIssue.noContent;
    }
    return null;
  }
}
