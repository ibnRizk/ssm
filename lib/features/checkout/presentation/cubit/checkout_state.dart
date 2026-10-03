import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../domain/entities/order_quote.dart';
import '../../domain/entities/order_request.dart';

class CheckoutState extends Equatable {
  final CheckoutAddresses addresses;
  final int? addressId;

  /// The server's price breakdown for the current cart and address. The
  /// order can only be placed once it's [CheckoutQuoteReady].
  final CheckoutQuote quote;
  final bool placing;

  /// Set once the order is placed — the screen moves on to tracking.
  final PlacedOrder? placedOrder;

  /// One-shot feedback; see [CheckoutNotice].
  final CheckoutNotice? notice;

  const CheckoutState({
    this.addresses = const CheckoutAddressesLoading(),
    this.addressId,
    this.quote = const CheckoutQuotePending(),
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
    CheckoutQuote? quote,
    bool? placing,
    PlacedOrder? placedOrder,
    CheckoutNotice? notice,
  }) => CheckoutState(
    addresses: addresses ?? this.addresses,
    addressId: addressId ?? this.addressId,
    quote: quote ?? this.quote,
    placing: placing ?? this.placing,
    placedOrder: placedOrder ?? this.placedOrder,
    notice: notice,
  );

  @override
  List<Object?> get props => [
    addresses,
    addressId,
    quote,
    placing,
    placedOrder,
    notice,
  ];
}

sealed class CheckoutQuote extends Equatable {
  const CheckoutQuote();

  @override
  List<Object?> get props => [];
}

/// Waiting for the cart or the addresses — nothing to quote yet.
final class CheckoutQuotePending extends CheckoutQuote {
  const CheckoutQuotePending();
}

final class CheckoutQuoteLoading extends CheckoutQuote {
  const CheckoutQuoteLoading();
}

/// Can't be quoted until the customer fixes [issue] (e.g. picks an
/// address with a map pin).
final class CheckoutQuoteUnavailable extends CheckoutQuote {
  final CheckoutIssue issue;

  const CheckoutQuoteUnavailable(this.issue);

  @override
  List<Object?> get props => [issue];
}

final class CheckoutQuoteReady extends CheckoutQuote {
  final OrderQuote quote;

  /// What [quote] was computed for; the order is placed with the same.
  final double distanceKm;

  const CheckoutQuoteReady(this.quote, {required this.distanceKm});

  @override
  List<Object?> get props => [quote, distanceKm];
}

/// The quote call failed — retryable.
final class CheckoutQuoteError extends CheckoutQuote {
  final Failure failure;

  const CheckoutQuoteError(this.failure);

  @override
  List<Object?> get props => [failure];
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
