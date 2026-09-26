import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/string_extension.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repos/account_repository.dart';
import 'edit_profile_state.dart';

/// Screen-scoped (one instance per Edit Profile route). Takes raw form input
/// and normalises it into a [ProfileUpdate] before calling the repository.
class EditProfileCubit extends Cubit<EditProfileState> {
  final AccountRepository repository;

  EditProfileCubit({required this.repository})
    : super(const EditProfileInitial());

  /// [current] supplies the fields the form doesn't edit (join date), so the
  /// success state holds the complete updated profile.
  Future<void> submit({
    required CustomerProfile current,
    required String name,
    required String phone,
    required String email,
  }) async {
    if (state is EditProfileSubmitting) return;
    final ProfileUpdate update = ProfileUpdate(
      name: name.collapseWhitespace(),
      phone: SaudiPhone.toE164(phone),
      email: email.trim(),
    );

    emit(const EditProfileSubmitting());
    final Either<Failure, Unit> result = await repository.updateProfile(update);
    if (isClosed) return;
    result.fold(
      (Failure failure) => emit(EditProfileError(failure)),
      (_) => emit(EditProfileSuccess(current.applying(update))),
    );
  }
}
