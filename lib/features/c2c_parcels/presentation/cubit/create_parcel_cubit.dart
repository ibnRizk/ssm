import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/uuid.dart';
import '../../../account/domain/entities/customer_profile.dart';
import '../../../account/domain/repos/account_repository.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_draft.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import '../../domain/repos/c2c_parcels_repository.dart';
import '../utils/c2c_parcel_labels.dart';
import 'create_parcel_state.dart';

/// What the quote step hands the create step: the priced request and its
/// price.
class CreateParcelArgs {
  final C2cQuoteRequest request;
  final C2cParcelQuote quote;

  const CreateParcelArgs({required this.request, required this.quote});
}

/// The contact and parcel details the form collects — everything in a
/// [C2cParcelDraft] except what the cubit holds (photos, payment, quote),
/// the sender's name and phone, which are the signed-in customer's, and
/// the title, which is the parcel's type.
class CreateParcelForm {
  /// Building and apartment are written into the address itself.
  final String senderAddress;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final double? declaredValue;

  /// The one free-text note for the driver.
  final String? driverNotes;
  final bool prohibitedItemsAcknowledged;

  const CreateParcelForm({
    required this.senderAddress,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.prohibitedItemsAcknowledged,
    this.declaredValue,
    this.driverNotes,
  });
}

/// Screen-scoped (provided at the create route with the accepted quote).
/// Collects photos and sends the parcel at the quoted price, from the
/// signed-in customer.
class CreateParcelCubit extends Cubit<CreateParcelState> {
  final C2cParcelsRepository repository;
  final AccountRepository accountRepository;
  final String Function() newIdempotencyKey;
  final DateTime Function() now;

  /// The parcel's title, from its type — the localized label by default.
  final String Function(ParcelCategory) titleFor;

  CreateParcelCubit({
    required this.repository,
    required this.accountRepository,
    required C2cQuoteRequest request,
    required C2cParcelQuote quote,
    this.newIdempotencyKey = uuidV4,
    this.now = DateTime.now,
    this.titleFor = _categoryLabel,
  }) : super(CreateParcelState(request: request, quote: quote));

  /// The key of a create attempt whose outcome is unknown. Kept for the
  /// next attempt even if the form changed meanwhile: if the first one
  /// landed, the server replays it (same body) or answers
  /// `idempotency_conflict` (changed body) — never a second parcel.
  String? _pendingKey;

  /// The sender's identity, fetched on the first send and kept so a retry
  /// sends the same body under the same key.
  CustomerProfile? _sender;

  Future<void> pickPhotos(C2cPhotoSource source) async {
    if (state.isBusy || !state.canAddPhotos) return;
    emit(state.copyWith(picking: true));
    final Either<Failure, List<C2cParcelPhoto>> result = await repository
        .pickPhotos(
          source,
          limit: C2cParcelPhoto.maxCount - state.photos.length,
        );
    if (isClosed) return;
    result.fold(
      (Failure failure) =>
          emit(state.copyWith(picking: false, notice: CreateFailed(failure))),
      (List<C2cParcelPhoto> picked) {
        final List<C2cParcelPhoto> accepted = <C2cParcelPhoto>[
          for (final C2cParcelPhoto photo in picked)
            if (photo.issue == null) photo,
        ];
        final C2cPhotoIssue? issue = picked
            .map((C2cParcelPhoto p) => p.issue)
            .whereType<C2cPhotoIssue>()
            .firstOrNull;
        emit(
          state.copyWith(
            picking: false,
            photos: <C2cParcelPhoto>[
              ...state.photos,
              ...accepted,
            ].take(C2cParcelPhoto.maxCount).toList(growable: false),
            notice: issue == null ? null : PhotosRejected(issue),
          ),
        );
      },
    );
  }

  void removePhoto(C2cParcelPhoto photo) {
    if (state.submitting) return;
    emit(
      state.copyWith(
        photos: <C2cParcelPhoto>[
          for (final C2cParcelPhoto p in state.photos)
            if (p != photo) p,
        ],
      ),
    );
  }

  void setPaymentMethod(C2cPaymentMethod method) {
    if (state.submitting || method == state.paymentMethod) return;
    emit(state.copyWith(paymentMethod: method));
  }

  /// Sends the parcel. A lapsed price is refreshed first and shown to the
  /// customer instead of being sent — they confirm the new one by sending
  /// again.
  Future<void> submit(CreateParcelForm form) async {
    if (state.isBusy || state.created != null) return;
    if (state.photos.isEmpty) {
      emit(state.copyWith(notice: const PhotosRequired()));
      return;
    }
    if (!state.quote.isValidAt(now())) {
      await _requote();
      return;
    }

    emit(state.copyWith(submitting: true));
    final CustomerProfile? sender = _sender ??= await _fetchSender();
    if (sender == null) return;

    final C2cParcelDraft draft = _draftFrom(form, sender);
    final String key = _pendingKey ??= newIdempotencyKey();

    final Either<Failure, C2cParcelDetails> result = await repository
        .createParcel(draft, idempotencyKey: key);
    if (!result.fold(_outcomeUnknown, (_) => false)) _pendingKey = null;
    if (isClosed) return;

    await result.fold(
      (Failure failure) async {
        emit(state.copyWith(submitting: false));
        if (_isStalePrice(failure)) {
          await _requote();
        } else if (_isIdempotencyConflict(failure)) {
          emit(state.copyWith(notice: const MaybeAlreadySent()));
        } else {
          emit(state.copyWith(notice: CreateFailed(failure)));
        }
      },
      (C2cParcelDetails parcel) async =>
          emit(state.copyWith(submitting: false, created: parcel)),
    );
  }

  Future<void> _requote() async {
    emit(state.copyWith(requoting: true));
    final Either<Failure, C2cParcelQuote> result = await repository.getQuote(
      state.request,
    );
    if (isClosed) return;
    result.fold(
      (Failure failure) =>
          emit(state.copyWith(requoting: false, notice: CreateFailed(failure))),
      (C2cParcelQuote quote) => emit(
        state.copyWith(
          requoting: false,
          quote: quote,
          notice: PriceChanged(quote),
        ),
      ),
    );
  }

  /// The signed-in customer, or null after reporting why it couldn't be
  /// read (the send is then dropped, nothing reached the server).
  Future<CustomerProfile?> _fetchSender() async {
    final Either<Failure, CustomerProfile> result = await accountRepository
        .getProfile();
    if (isClosed) return null;
    return result.fold((Failure failure) {
      emit(state.copyWith(submitting: false, notice: CreateFailed(failure)));
      return null;
    }, (CustomerProfile profile) => profile);
  }

  /// The required title is the chosen type's name (e.g. "مستندات").
  /// Building, floor and apartment live in each address, and the driver's
  /// note goes out as `pickup_instructions`; the fields the form no longer
  /// asks for stay null, which the request leaves out.
  C2cParcelDraft _draftFrom(
    CreateParcelForm form,
    CustomerProfile sender,
  ) => C2cParcelDraft(
    request: state.request,
    sender: C2cContact(
      name: sender.name.trim(),
      phone: SaudiPhone.toE164(sender.phone),
      address: form.senderAddress.trim(),
      location: state.request.sender,
    ),
    recipient: C2cContact(
      name: form.recipientName.trim(),
      phone: SaudiPhone.toE164(form.recipientPhone),
      address: form.recipientAddress.trim(),
      location: state.request.recipient,
    ),
    title: titleFor(state.request.category),
    declaredValue: form.declaredValue,
    pickupInstructions: form.driverNotes,
    paymentMethod: state.paymentMethod,
    photos: state.photos,
    prohibitedItemsAcknowledged: form.prohibitedItemsAcknowledged,
    quoteToken: state.quote.quoteToken,
  );

  static String _categoryLabel(ParcelCategory category) => category.label;

  static bool _isStalePrice(Failure failure) => switch (failure) {
    ConflictFailure(:final String? code) =>
      code == C2cParcelErrorCode.priceChanged ||
          code == C2cParcelErrorCode.quoteExpired,
    _ => false,
  };

  static bool _isIdempotencyConflict(Failure failure) =>
      failure is ConflictFailure &&
      failure.code == C2cParcelErrorCode.idempotencyConflict;

  /// The parcel may or may not exist — keep the key for the retry.
  static bool _outcomeUnknown(Failure failure) => switch (failure) {
    NetworkFailure() => true,
    ServerFailure(:final String? code) => code == null,
    ConflictFailure(:final String? code) =>
      code == C2cParcelErrorCode.requestInProgress,
    _ => false,
  };
}
