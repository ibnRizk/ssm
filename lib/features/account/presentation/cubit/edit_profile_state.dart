import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_profile.dart';

sealed class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

final class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

final class EditProfileSubmitting extends EditProfileState {
  const EditProfileSubmitting();
}

/// Carries the profile as it now stands server-side, for the screen to hand
/// to [ProfileCubit] before popping.
final class EditProfileSuccess extends EditProfileState {
  final CustomerProfile profile;

  const EditProfileSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

final class EditProfileError extends EditProfileState {
  final Failure failure;

  const EditProfileError(this.failure);

  @override
  List<Object?> get props => [failure];
}
