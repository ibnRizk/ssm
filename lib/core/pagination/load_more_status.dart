import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Progress of fetching the next page of a paginated list.
sealed class LoadMoreStatus extends Equatable {
  const LoadMoreStatus();

  @override
  List<Object?> get props => [];
}

final class LoadMoreIdle extends LoadMoreStatus {
  const LoadMoreIdle();
}

final class LoadMoreInProgress extends LoadMoreStatus {
  const LoadMoreInProgress();
}

/// Shown as a tap-to-retry row at the end of the list.
final class LoadMoreFailed extends LoadMoreStatus {
  final Failure failure;

  const LoadMoreFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
