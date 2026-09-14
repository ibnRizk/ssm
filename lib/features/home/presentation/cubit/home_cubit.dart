import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

/// Cubit template — copy this shape for every new feature.
///
/// A cubit depends only on use cases (never on a repository or data source
/// directly), emits a loading state before the call, and folds the
/// `Either<Failure, T>` into a success or error state. Example with a use case:
///
/// ```dart
/// class HomeCubit extends Cubit<HomeState> {
///   final GetItemsUseCase getItemsUseCase;
///   HomeCubit({required this.getItemsUseCase}) : super(const HomeInitial());
///
///   Future<void> getItems() async {
///     emit(const HomeLoading());
///     final Either<Failure, List<Item>> result =
///         await getItemsUseCase(NoParams());
///     result.fold(
///       (Failure f) => emit(HomeError(message: f.message ?? '')),
///       (List<Item> items) => emit(HomeSuccess(items: items)),
///     );
///   }
/// }
/// ```
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial());

  void getHome() {
    try {
      emit(const HomeLoading());
      // TODO: Implement business logic here.
      emit(const HomeSuccess());
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
