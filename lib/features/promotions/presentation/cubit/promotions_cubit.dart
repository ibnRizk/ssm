import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/zone/zone_repository.dart';
import '../../domain/entities/store_promotion.dart';
import '../../domain/repos/promotions_repository.dart';
import 'promotions_state.dart';

/// Screen-scoped (provided at the Home tab's route).
class PromotionsCubit extends Cubit<PromotionsState> {
  final PromotionsRepository promotionsRepository;
  final ZoneRepository zoneRepository;

  /// Promotions belong to one zone — a new zone reloads them.
  late final StreamSubscription<List<int>> _zoneChanges;

  PromotionsCubit({
    required this.promotionsRepository,
    required this.zoneRepository,
  }) : super(const PromotionsInitial()) {
    _zoneChanges = zoneRepository.zoneChanges.listen((_) => _reloadForZone());
  }

  /// Bumped by every fetch, so an answer for an older one is dropped.
  int _request = 0;
  bool _loading = false;

  /// A refresh keeps what's shown (banners, or nothing) while it runs, and a
  /// failed refresh keeps it too.
  Future<void> load() async {
    if (_loading) return;
    final bool showing = state is PromotionsLoaded || state is PromotionsEmpty;
    await _fetch(keepOnFailure: showing, showLoading: !showing);
  }

  /// The old zone's banners would open stores that don't deliver here, so
  /// they're cleared, and an in-flight fetch for the old zone is dropped.
  Future<void> _reloadForZone() =>
      _fetch(keepOnFailure: false, showLoading: true);

  Future<void> _fetch({
    required bool keepOnFailure,
    required bool showLoading,
  }) async {
    final int request = ++_request;
    _loading = true;
    if (showLoading) emit(const PromotionsLoading());

    final Either<Failure, List<StorePromotion>> result =
        await promotionsRepository.getFeaturedPromotions();

    if (isClosed || request != _request) return;
    _loading = false;

    result.fold(
      (Failure failure) {
        if (!keepOnFailure) emit(PromotionsError(failure));
      },
      (List<StorePromotion> promotions) => emit(
        promotions.isEmpty
            ? const PromotionsEmpty()
            : PromotionsLoaded(promotions),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _zoneChanges.cancel();
    return super.close();
  }
}
