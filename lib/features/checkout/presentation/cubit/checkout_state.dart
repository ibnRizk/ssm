import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../domain/entities/order_request.dart';

class CheckoutState extends Equatable {
  final CheckoutAddresses addresses;
  final int? addressId;
  final bool placing;

  /// Set once the order is placed — the screen moves on to tracking.
  final PlacedOrder? placedOrder;

  /// One-shot feedback; see [CheckoutNotice].
  final CheckoutNotice? notice;

  const CheckoutState({
    this.addresses = const CheckoutAddressesLoading(),
    this.addressId,
    this.placing = false,
    this.placedOrder,
    this.notice,
  });

  Address? get selectedAddress => switch (addresses) {
    CheckoutAddressesLoaded(:final List<Address> items) =>
      items.where((Address a) => a.id == addressId).firstOrNull,
    _ => null,
  };

  /// Every change clears [notice] unless a new one is passed.
  CheckoutState copyWith({
    CheckoutAddresses? addresses,
    int? addressId,
    bool? placing,
    PlacedOrder? placedOrder,
    CheckoutNotice? notice,
  }) => CheckoutState(
    addresses: addresses ?? this.addresses,
    addressId: addressId ?? this.addressId,
    placing: placing ?? this.placing,
    placedOrder: placedOrder ?? this.placedOrder,
    notice: notice,
  );

  @override
  List<Object?> get props => [
    addresses,
    addressId,
    placing,
    placedOrder,
    notice,
  ];
}

sealed class CheckoutAddresses extends Equatable {
  const CheckoutAddresses();

  @override
  List<Object?> get props => [];
}

final class CheckoutAddressesLoading extends CheckoutAddresses {
  const CheckoutAddressesLoading();
}

final class CheckoutAddressesLoaded extends CheckoutAddresses {
  final List<Address> items;

  const CheckoutAddressesLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

final class CheckoutAddressesError extends CheckoutAddresses {
  final Failure failure;

  const CheckoutAddressesError(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Feedback that isn't part of the form. [seq] makes each notice distinct,
/// so the same one twice still fires the listener.
sealed class CheckoutNotice extends Equatable {
  final int seq;

  const CheckoutNotice(this.seq);

  @override
  List<Object?> get props => [seq];
}

/// Nothing was sent — see [CheckoutIssue].
final class CheckoutIncomplete extends CheckoutNotice {
  final CheckoutIssue issue;

  const CheckoutIncomplete(super.seq, this.issue);

  @override
  List<Object?> get props => [seq, issue];
}

/// The order was refused or couldn't be sent. Refusals are
/// [ForbiddenFailure]s carrying an `OrderRefusalCode`.
final class CheckoutFailed extends CheckoutNotice {
  final Failure failure;

  const CheckoutFailed(super.seq, this.failure);

  @override
  List<Object?> get props => [seq, failure];
}
