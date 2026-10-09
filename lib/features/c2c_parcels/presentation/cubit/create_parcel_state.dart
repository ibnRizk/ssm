import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_draft.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/entities/c2c_parcel_status.dart';

class CreateParcelState extends Equatable {
  /// What was priced — fixed for this screen.
  final C2cQuoteRequest request;

  /// The current price; replaced when the server says it changed.
  final C2cParcelQuote quote;

  final List<C2cParcelPhoto> photos;
  final bool picking;
  final C2cPaymentMethod paymentMethod;
  final bool submitting;

  /// A fresh price is being fetched after the old one lapsed.
  final bool requoting;

  /// Set once the server created the parcel.
  final C2cParcelDetails? created;

  /// One-shot, for a snack bar or dialog. Every [copyWith] clears it
  /// unless passed again.
  final CreateParcelNotice? notice;

  const CreateParcelState({
    required this.request,
    required this.quote,
    this.photos = const <C2cParcelPhoto>[],
    this.picking = false,
    this.paymentMethod = C2cPaymentMethod.cashBySender,
    this.submitting = false,
    this.requoting = false,
    this.created,
    this.notice,
  });

  bool get canAddPhotos => photos.length < C2cParcelPhoto.maxCount;

  bool get isBusy => submitting || requoting || picking;

  CreateParcelState copyWith({
    C2cParcelQuote? quote,
    List<C2cParcelPhoto>? photos,
    bool? picking,
    C2cPaymentMethod? paymentMethod,
    bool? submitting,
    bool? requoting,
    C2cParcelDetails? created,
    CreateParcelNotice? notice,
  }) => CreateParcelState(
    request: request,
    quote: quote ?? this.quote,
    photos: photos ?? this.photos,
    picking: picking ?? this.picking,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    submitting: submitting ?? this.submitting,
    requoting: requoting ?? this.requoting,
    created: created ?? this.created,
    notice: notice,
  );

  @override
  List<Object?> get props => [
    request,
    quote,
    photos,
    picking,
    paymentMethod,
    submitting,
    requoting,
    created,
    notice,
  ];
}

sealed class CreateParcelNotice extends Equatable {
  const CreateParcelNotice();

  @override
  List<Object?> get props => [];
}

/// Some picked photos were left out — too large or of an unsupported type.
final class PhotosRejected extends CreateParcelNotice {
  final C2cPhotoIssue issue;

  const PhotosRejected(this.issue);

  @override
  List<Object?> get props => [issue];
}

/// The parcel needs at least one photo.
final class PhotosRequired extends CreateParcelNotice {
  const PhotosRequired();
}

/// The quoted price lapsed or changed; [quote] is the new one, to accept
/// before sending again.
final class PriceChanged extends CreateParcelNotice {
  final C2cParcelQuote quote;

  const PriceChanged(this.quote);

  @override
  List<Object?> get props => [quote];
}

/// An earlier attempt whose answer was lost did create the parcel: the
/// server refused the changed form under its key (`idempotency_conflict`).
/// The customer should look in Sent rather than send again.
final class MaybeAlreadySent extends CreateParcelNotice {
  const MaybeAlreadySent();
}

/// Picking photos, re-quoting or creating failed.
final class CreateFailed extends CreateParcelNotice {
  final Failure failure;

  const CreateFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
