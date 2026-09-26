import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/loyalty_history.dart';
import '../../domain/entities/loyalty_progress.dart';
import '../../domain/repos/loyalty_repository.dart';
import 'loyalty_state.dart';

/// Screen-scoped (one instance per Loyalty route).
class LoyaltyCubit extends Cubit<LoyaltyState> {
  final LoyaltyRepository repository;

  LoyaltyCubit({required this.repository}) : super(const LoyaltyInitial());

  bool _inFlight = false;

  /// Fetches progress and history concurrently. A refresh while data is on
  /// screen keeps it visible; only a failure to load the *progress* is an
  /// error state.
  Future<void> load() async {
    if (_inFlight) return;
    _inFlight = true;
    if (state is! LoyaltyLoaded) emit(const LoyaltyLoading());

    final (
      Either<Failure, LoyaltyProgress> progress,
      Either<Failure, LoyaltyHistory> history,
    ) = await (
      repository.getProgress(),
      repository.getHistory(),
    ).wait;

    _inFlight = false;
    if (isClosed) return;
    progress.fold(
      (Failure failure) => emit(LoyaltyError(failure)),
      (LoyaltyProgress progress) => emit(
        LoyaltyLoaded(
          progress: progress,
          history: history.fold((_) => null, (LoyaltyHistory h) => h),
        ),
      ),
    );
  }
}
