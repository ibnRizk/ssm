import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/address.dart';

sealed class AddressesState extends Equatable {
  const AddressesState();

  @override
  List<Object?> get props => [];
}

final class AddressesInitial extends AddressesState {
  const AddressesInitial();
}

final class AddressesLoading extends AddressesState {
  const AddressesLoading();
}

final class AddressesLoaded extends AddressesState {
  final List<Address> addresses;

  /// Ids with a delete request in flight — their rows show a spinner.
  final Set<int> deletingIds;

  /// The last delete that failed, for a one-shot snack bar. Cleared by the
  /// next emission, so the list itself stays on screen.
  final Failure? deleteFailure;

  const AddressesLoaded({
    required this.addresses,
    this.deletingIds = const <int>{},
    this.deleteFailure,
  });

  @override
  List<Object?> get props => [addresses, deletingIds, deleteFailure];
}

final class AddressesError extends AddressesState {
  final Failure failure;

  const AddressesError(this.failure);

  @override
  List<Object?> get props => [failure];
}
