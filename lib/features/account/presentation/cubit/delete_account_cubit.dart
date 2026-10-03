import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/repos/auth_repository.dart';
import '../../domain/repos/account_repository.dart';
import 'delete_account_state.dart';

/// Screen-scoped (provided at the profile route). Deletes the account on the
/// server, then signs out locally through the same path as Log out.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AccountRepository accountRepository;
  final AuthRepository authRepository;

  DeleteAccountCubit({
    required this.accountRepository,
    required this.authRepository,
  }) : super(const DeleteAccountIdle());

  Future<void> deleteAccount() async {
    if (state is DeleteAccountInProgress) return;
    emit(const DeleteAccountInProgress());

    final Either<Failure, Unit> result = await accountRepository
        .deleteAccount();
    if (result.isRight()) {
      // Even if the screen closed meanwhile: the account is gone, so the
      // local session must go too. A storage failure here is not reported —
      // the server already revoked the token, and the first request that
      // sends it gets a 401, which clears the session app-wide.
      await authRepository.logout();
    }

    if (isClosed) return;
    emit(result.fold(DeleteAccountError.new, (_) => const DeleteAccountDone()));
  }
}
