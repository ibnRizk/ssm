import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/location/geo_point.dart';
import '../../../../core/location/location_repository.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/repos/c2c_parcels_repository.dart';
import 'send_parcel_state.dart';

/// Screen-scoped (provided at the send-parcel route). Holds the inputs a
/// quote depends on, so changing any of them drops a quote that no longer
/// matches.
class SendParcelCubit extends Cubit<SendParcelState> {
  final C2cParcelsRepository repository;
  final LocationRepository locationRepository;

  SendParcelCubit({required this.repository, required this.locationRepository})
    : super(const SendParcelState());

  /// Bumped by every input change and every quote request; an answer for
  /// an older value is stale and dropped.
  int _generation = 0;

  void setPoint(ParcelEnd end, GeoPoint point) {
    _invalidate();
    emit(switch (end) {
      ParcelEnd.pickup => state.copyWith(pickup: point, quote: _idle),
      ParcelEnd.dropoff => state.copyWith(dropoff: point, quote: _idle),
    });
  }

  /// Sets [end] to the device position. One end at a time.
  Future<void> useCurrentLocation(ParcelEnd end) async {
    if (state.locating != null) return;
    emit(state.copyWith(locating: () => end));
    final Either<Failure, GeoPoint> result = await locationRepository
        .getCurrentLocation();
    if (isClosed) return;
    emit(state.copyWith(locating: () => null));
    result.fold(
      (Failure failure) => emit(state.copyWith(notice: failure)),
      (GeoPoint point) => setPoint(end, point),
    );
  }

  void setCategory(ParcelCategory category) {
    if (category == state.category) return;
    _invalidate();
    emit(state.copyWith(category: category, quote: _idle));
  }

  void setFragile(bool isFragile) {
    if (isFragile == state.isFragile) return;
    _invalidate();
    emit(state.copyWith(isFragile: isFragile, quote: _idle));
  }

  /// For inputs the screen keeps itself (weight, title): the shown quote no
  /// longer matches them.
  void inputsChanged() {
    if (state.quote is QuoteIdle) return;
    _invalidate();
    emit(state.copyWith(quote: _idle));
  }

  /// Does nothing until both ends are set, or while a quote is on its way.
  Future<void> requestQuote({required double weightKg, String? title}) async {
    final GeoPoint? pickup = state.pickup;
    final GeoPoint? dropoff = state.dropoff;
    if (pickup == null || dropoff == null || state.quote is QuoteLoading) {
      return;
    }
    final int generation = ++_generation;
    emit(state.copyWith(quote: const QuoteLoading()));

    final String? trimmedTitle = title?.trim();
    final C2cQuoteRequest request = C2cQuoteRequest(
      sender: pickup,
      recipient: dropoff,
      category: state.category,
      weightKg: weightKg,
      isFragile: state.isFragile,
      title: trimmedTitle == null || trimmedTitle.isEmpty ? null : trimmedTitle,
    );
    final Either<Failure, C2cParcelQuote> result = await repository.getQuote(
      request,
    );
    if (isClosed || generation != _generation) return;
    emit(
      state.copyWith(
        quote: result.fold<QuoteStatus>(
          QuoteFailed.new,
          (C2cParcelQuote quote) => QuoteReady(quote, request),
        ),
      ),
    );
  }

  static const QuoteStatus _idle = QuoteIdle();

  void _invalidate() => _generation++;
}
