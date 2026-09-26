import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../loyalty/domain/entities/loyalty_progress.dart';
import '../../domain/entities/customer_profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final CustomerProfile profile;

  /// Null when only the loyalty call failed — the profile is still worth
  /// showing, and the loyalty row falls back to its generic subtitle.
  final LoyaltyProgress? loyalty;

  const ProfileLoaded({required this.profile, this.loyalty});

  @override
  List<Object?> get props => [profile, loyalty];
}

final class ProfileError extends ProfileState {
  final Failure failure;

  const ProfileError(this.failure);

  @override
  List<Object?> get props => [failure];
}
