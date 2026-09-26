import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../catalog/domain/entities/store.dart';
import '../../domain/entities/pharmacy_request.dart';
import '../../domain/entities/prescription_image.dart';

/// The pharmacy request form. Not a state union: the form stays on screen
/// through picking, submitting and failures, so those are fields of it.
class PharmacyOrderState extends Equatable {
  final PharmacyOptions options;
  final int? pharmacyId;
  final int? addressId;
  final PrescriptionImage? prescription;

  /// The camera or gallery is open.
  final bool picking;
  final bool submitting;

  /// Set once the backend accepted the request (HTTP 201).
  final PharmacyRequestReceipt? receipt;

  /// One-shot feedback; any later state clears it.
  final PharmacyNotice? notice;

  const PharmacyOrderState({
    this.options = const PharmacyOptionsLoading(),
    this.pharmacyId,
    this.addressId,
    this.prescription,
    this.picking = false,
    this.submitting = false,
    this.receipt,
    this.notice,
  });

  Store? get selectedPharmacy => switch (options) {
    PharmacyOptionsLoaded(:final pharmacies) =>
      pharmacies.where((Store s) => s.id == pharmacyId).firstOrNull,
    _ => null,
  };

  Address? get selectedAddress => switch (options) {
    PharmacyOptionsLoaded(:final addresses) =>
      addresses.where((Address a) => a.id == addressId).firstOrNull,
    _ => null,
  };

  /// Nullable fields are replaced as given; pass them explicitly to keep
  /// them (see the cubit), since `null` also means "clear".
  PharmacyOrderState copyWith({
    PharmacyOptions? options,
    int? pharmacyId,
    int? addressId,
    PrescriptionImage? prescription,
    bool clearPrescription = false,
    bool? picking,
    bool? submitting,
    PharmacyRequestReceipt? receipt,
    PharmacyNotice? notice,
  }) => PharmacyOrderState(
    options: options ?? this.options,
    pharmacyId: pharmacyId ?? this.pharmacyId,
    addressId: addressId ?? this.addressId,
    prescription: clearPrescription ? null : prescription ?? this.prescription,
    picking: picking ?? this.picking,
    submitting: submitting ?? this.submitting,
    receipt: receipt ?? this.receipt,
    notice: notice,
  );

  @override
  List<Object?> get props => [
    options,
    pharmacyId,
    addressId,
    prescription,
    picking,
    submitting,
    receipt,
    notice,
  ];
}

// --- What the customer can choose from ---

sealed class PharmacyOptions extends Equatable {
  const PharmacyOptions();

  @override
  List<Object?> get props => [];
}

final class PharmacyOptionsLoading extends PharmacyOptions {
  const PharmacyOptionsLoading();
}

final class PharmacyOptionsLoaded extends PharmacyOptions {
  final List<Store> pharmacies;
  final List<Address> addresses;

  const PharmacyOptionsLoaded({
    required this.pharmacies,
    required this.addresses,
  });

  @override
  List<Object?> get props => [pharmacies, addresses];
}

final class PharmacyOptionsError extends PharmacyOptions {
  final Failure failure;

  const PharmacyOptionsError(this.failure);

  @override
  List<Object?> get props => [failure];
}

// --- One-shot feedback ---

/// [seq] makes each notice distinct, so the same problem twice in a row is
/// still shown twice.
sealed class PharmacyNotice extends Equatable {
  final int seq;

  const PharmacyNotice(this.seq);

  @override
  List<Object?> get props => [seq];
}

/// The form isn't complete yet.
final class PharmacyIncomplete extends PharmacyNotice {
  final PharmacyRequestIssue issue;

  const PharmacyIncomplete(super.seq, this.issue);

  @override
  List<Object?> get props => [seq, issue];
}

/// The picked image wasn't attached — the backend would refuse it.
final class PrescriptionRejected extends PharmacyNotice {
  final PrescriptionImageIssue issue;

  const PrescriptionRejected(super.seq, this.issue);

  @override
  List<Object?> get props => [seq, issue];
}

/// Picking or sending failed.
final class PharmacyActionFailed extends PharmacyNotice {
  final Failure failure;

  const PharmacyActionFailed(super.seq, this.failure);

  @override
  List<Object?> get props => [seq, failure];
}
