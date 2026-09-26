import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../loyalty/domain/entities/loyalty_progress.dart';
import '../../../loyalty/domain/repos/loyalty_repository.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repos/account_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AccountRepository accountRepository;
  final LoyaltyRepository loyaltyRepository;

  ProfileCubit({
    required this.accountRepository,
    required this.loyaltyRepository,
  }) : super(const ProfileInitial());

  bool _inFlight = false;

  /// Fetches the profile and loyalty progress concurrently. A refresh while
  /// data is already on screen keeps it visible instead of flashing the
  /// skeleton; only a failure to load the *profile* is an error state.
  Future<void> load() async {
    if (_inFlight) return;
    _inFlight = true;
    if (state is! ProfileLoaded) emit(const ProfileLoading());

    final (
      Either<Failure, CustomerProfile> profile,
      Either<Failure, LoyaltyProgress> loyalty,
    ) = await (
      accountRepository.getProfile(),
      loyaltyRepository.getProgress(),
    ).wait;

    _inFlight = false;
    if (isClosed) return;
    profile.fold(
      (Failure failure) => emit(ProfileError(failure)),
      (CustomerProfile profile) => emit(
        ProfileLoaded(
          profile: profile,
          loyalty: loyalty.fold((_) => null, (LoyaltyProgress l) => l),
        ),
      ),
    );
  }
}
