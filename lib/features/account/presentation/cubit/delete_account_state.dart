import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

sealed class DeleteAccountState extends Equatable {
  const DeleteAccountState();

  @override
  List<Object?> get props => [];
}

final class DeleteAccountIdle extends DeleteAccountState {
  const DeleteAccountIdle();
}

final class DeleteAccountInProgress extends DeleteAccountState {
  const DeleteAccountInProgress();
}

/// The account is gone and the session discarded — leave for Login.
final class DeleteAccountDone extends DeleteAccountState {
  const DeleteAccountDone();
}

/// Carries the typed [Failure] so the UI can tell the "order in progress"
/// refusal apart from other errors.
final class DeleteAccountError extends DeleteAccountState {
  final Failure failure;

  const DeleteAccountError(this.failure);

  @override
  List<Object?> get props => [failure];
}
