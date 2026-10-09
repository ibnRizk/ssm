import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/active_subscription.dart';
import '../../domain/entities/delivery_zone.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repos/subscriptions_repository.dart';
import 'subscriptions_state.dart';

/// Screen-scoped (provided at the Subscriptions tab's route).
class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionsRepository repository;

  SubscriptionsCubit({required this.repository})
    : super(const SubscriptionsInitial());

  bool _loading = false;

  /// Fetches the zones and the current subscription concurrently, then the
  /// plans of the selected zone — the first one on a first load, the same
  /// one on a refresh if it still exists. A refresh keeps the screen (and
  /// the plans, if the zone didn't change) visible while it runs.
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    final SubscriptionsState previous = state;
    final SubscriptionsLoaded? before = previous is SubscriptionsLoaded
        ? previous
        : null;
    if (before == null) emit(const SubscriptionsLoading());

    final (
      Either<Failure, List<DeliveryZone>> zonesResult,
      Either<Failure, ActiveSubscription?> currentResult,
    ) = await (
      repository.getZones(),
      repository.getCurrentSubscription(),
    ).wait;

    _loading = false;
    if (isClosed) return;

    final List<DeliveryZone>? zones = zonesResult.fold((Failure failure) {
      // A failed refresh isn't worth replacing the screen with an error.
      if (before == null) emit(SubscriptionsError(failure));
      return null;
    }, (List<DeliveryZone> zones) => zones);
    if (zones == null) return;

    final int? keptZoneId = before?.selectedZoneId;
    final int? selectedZoneId =
        zones.any((DeliveryZone z) => z.id == keptZoneId)
        ? keptZoneId
        : zones.isEmpty
        ? null
        : zones.first.id;
    final bool sameZone =
        before != null && before.selectedZoneId == selectedZoneId;
    // Parcel data is refreshed only once the customer has opened that side.
    final PlansStatus? parcelPlans = before?.parcelPlans;
    final bool parcelsOpened = parcelPlans != null;

    emit(
      SubscriptionsLoaded(
        zones: zones,
        selectedZoneId: selectedZoneId,
        plans: _initialPlans(selectedZoneId, sameZone ? before.plans : null),
        // Keep the banner through a failed refresh of the current plan.
        current: currentResult.fold(
          (_) => before?.current,
          (ActiveSubscription? current) => current,
        ),
        purchase: before?.purchase ?? const PurchaseIdle(),
        product: before?.product ?? SubscriptionProduct.delivery,
        parcelPlans: parcelsOpened
            ? _initialPlans(selectedZoneId, sameZone ? parcelPlans : null)
            : null,
        parcelSubscriptions:
            before?.parcelSubscriptions ?? const <ActiveSubscription>[],
      ),
    );
    await Future.wait(<Future<void>>[
      if (selectedZoneId != null) _loadPlans(selectedZoneId),
      if (parcelsOpened) _loadParcels(selectedZoneId),
    ]);
  }

  Future<void> selectZone(int zoneId) async {
    final SubscriptionsState current = state;
    if (current is! SubscriptionsLoaded || current.selectedZoneId == zoneId) {
      return;
    }
    final bool parcelsOpened = current.parcelPlans != null;
    emit(
      current.copyWith(
        selectedZoneId: zoneId,
        plans: const PlansLoading(),
        parcelPlans: parcelsOpened ? const PlansLoading() : null,
      ),
    );
    await Future.wait(<Future<void>>[
      _loadPlans(zoneId),
      if (parcelsOpened) _loadParcelPlans(zoneId),
    ]);
  }

  /// Switches between store-delivery and parcel plans. The parcel side is
  /// fetched the first time it's opened.
  Future<void> selectProduct(SubscriptionProduct product) async {
    final SubscriptionsState current = state;
    if (current is! SubscriptionsLoaded || current.product == product) return;
    final bool firstOpen =
        product == SubscriptionProduct.parcels && current.parcelPlans == null;
    emit(
      current.copyWith(
        product: product,
        parcelPlans: firstOpen
            ? _initialPlans(current.selectedZoneId, null)
            : null,
      ),
    );
    if (firstOpen) await _loadParcels(current.selectedZoneId);
  }

  /// After a failed parcel plans load.
  Future<void> retryParcelPlans() async {
    final SubscriptionsState current = state;
    if (current is! SubscriptionsLoaded) return;
    final int? zoneId = current.selectedZoneId;
    if (zoneId == null || current.parcelPlans == null) return;
    emit(current.copyWith(parcelPlans: const PlansLoading()));
    await _loadParcelPlans(zoneId);
  }

  /// After a failed plans load.
  Future<void> retryPlans() async {
    final SubscriptionsState current = state;
    if (current is! SubscriptionsLoaded) return;
    final int? zoneId = current.selectedZoneId;
    if (zoneId == null) return;
    emit(current.copyWith(plans: const PlansLoading()));
    await _loadPlans(zoneId);
  }

  /// Creates a purchase intent. Success means *pending admin approval*,
  /// not an active subscription.
  Future<void> subscribe(int planId) async {
    final SubscriptionsState before = state;
    if (before is! SubscriptionsLoaded ||
        before.purchase is PurchaseInProgress) {
      return;
    }
    emit(before.copyWith(purchase: PurchaseInProgress(planId)));

    final Either<Failure, Unit> result = await repository.createPurchaseIntent(
      planId,
    );
    if (isClosed) return;
    final SubscriptionsState after = state;
    if (after is! SubscriptionsLoaded) return;
    emit(
      after.copyWith(
        purchase: result.fold(
          PurchaseFailed.new,
          (_) => PurchasePendingApproval(planId),
        ),
      ),
    );
  }

  Future<void> _loadPlans(int zoneId) async {
    final Either<Failure, List<SubscriptionPlan>> result = await repository
        .getPlans(zoneId);
    if (isClosed) return;
    final SubscriptionsState current = state;
    // The customer switched zones meanwhile — this answer is stale.
    if (current is! SubscriptionsLoaded || current.selectedZoneId != zoneId) {
      return;
    }
    emit(current.copyWith(plans: _plansStatus(result)));
  }

  Future<void> _loadParcels(int? zoneId) => Future.wait(<Future<void>>[
    if (zoneId != null) _loadParcelPlans(zoneId),
    _loadParcelSubscriptions(),
  ]);

  Future<void> _loadParcelPlans(int zoneId) async {
    final Either<Failure, List<SubscriptionPlan>> result = await repository
        .getParcelPlans(zoneId);
    if (isClosed) return;
    final SubscriptionsState current = state;
    // The customer switched zones meanwhile — this answer is stale.
    if (current is! SubscriptionsLoaded || current.selectedZoneId != zoneId) {
      return;
    }
    emit(current.copyWith(parcelPlans: _plansStatus(result)));
  }

  /// A failure keeps the balances already shown.
  Future<void> _loadParcelSubscriptions() async {
    final Either<Failure, List<ActiveSubscription>> result = await repository
        .getParcelSubscriptions();
    if (isClosed) return;
    final SubscriptionsState current = state;
    if (current is! SubscriptionsLoaded) return;
    result.fold(
      (_) {},
      (List<ActiveSubscription> subscriptions) =>
          emit(current.copyWith(parcelSubscriptions: subscriptions)),
    );
  }

  /// What a zone's plans show before (re)loading: nothing to load without a
  /// zone, the [kept] plans on a same-zone refresh, else a spinner.
  static PlansStatus _initialPlans(int? zoneId, PlansStatus? kept) =>
      zoneId == null
      ? const PlansLoaded(<SubscriptionPlan>[])
      : kept ?? const PlansLoading();

  static PlansStatus _plansStatus(
    Either<Failure, List<SubscriptionPlan>> result,
  ) => result.fold(
    PlansError.new,
    (List<SubscriptionPlan> plans) =>
        PlansLoaded(plans, bestValueId: SubscriptionPlan.bestValueId(plans)),
  );
}
