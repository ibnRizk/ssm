import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/location/geo_point.dart';
import '../../domain/entities/c2c_parcel_quote.dart';

/// Which end of the trip a location belongs to.
enum ParcelEnd { pickup, dropoff }

class SendParcelState extends Equatable {
  final GeoPoint? pickup;
  final GeoPoint? dropoff;
  final ParcelCategory category;
  final bool isFragile;

  /// The end whose GPS position is being read; null when idle.
  final ParcelEnd? locating;

  final QuoteStatus quote;

  /// A location failure (GPS off, access denied) — one-shot, for a snack
  /// bar. Every [copyWith] clears it unless passed again.
  final Failure? notice;

  const SendParcelState({
    this.pickup,
    this.dropoff,
    this.category = ParcelCategory.medium,
    this.isFragile = false,
    this.locating,
    this.quote = const QuoteIdle(),
    this.notice,
  });

  GeoPoint? pointOf(ParcelEnd end) => switch (end) {
    ParcelEnd.pickup => pickup,
    ParcelEnd.dropoff => dropoff,
  };

  SendParcelState copyWith({
    GeoPoint? pickup,
    GeoPoint? dropoff,
    ParcelCategory? category,
    bool? isFragile,
    ParcelEnd? Function()? locating,
    QuoteStatus? quote,
    Failure? notice,
  }) => SendParcelState(
    pickup: pickup ?? this.pickup,
    dropoff: dropoff ?? this.dropoff,
    category: category ?? this.category,
    isFragile: isFragile ?? this.isFragile,
    locating: locating == null ? this.locating : locating(),
    quote: quote ?? this.quote,
    notice: notice,
  );

  @override
  List<Object?> get props => [
    pickup,
    dropoff,
    category,
    isFragile,
    locating,
    quote,
    notice,
  ];
}

// --- The price for the current inputs ---

sealed class QuoteStatus extends Equatable {
  const QuoteStatus();

  @override
  List<Object?> get props => [];
}

/// Not asked for yet, or the inputs changed since.
final class QuoteIdle extends QuoteStatus {
  const QuoteIdle();
}

final class QuoteLoading extends QuoteStatus {
  const QuoteLoading();
}

/// [quote] is the price of [request] — what the create step books.
final class QuoteReady extends QuoteStatus {
  final C2cParcelQuote quote;
  final C2cQuoteRequest request;

  const QuoteReady(this.quote, this.request);

  @override
  List<Object?> get props => [quote, request];
}

/// E.g. 422 for a parcel beyond the allowed distance or weight, with the
/// server's message.
final class QuoteFailed extends QuoteStatus {
  final Failure failure;

  const QuoteFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
