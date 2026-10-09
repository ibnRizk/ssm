import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_repository.dart';
import '../../../../core/utils/uuid.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../../domain/entities/c2c_parcel_status.dart';
import '../../domain/repos/c2c_parcels_repository.dart';
import 'c2c_parcel_tracking_state.dart';

/// Makes a periodic timer; swapped in tests to fire ticks by hand.
typedef C2cPeriodicTimerFactory =
    Timer Function(Duration interval, void Function(Timer) onTick);

/// Screen-scoped (one per parcel route). Shows one parcel live:
///
/// * **Realtime** — status events on `private-c2c-parcel.{id}` trigger a
///   refetch (REST stays the source of truth); driver positions on
///   `….tracking` move the map directly. The tracking channel is only
///   watched while the viewer may see the driver.
/// * **Polling fallback** — every `polling_interval_seconds` (15 s until
///   the server says), `/tracking` is polled while the socket is down. A
///   connected socket doesn't prove this parcel's channel was authorized,
///   so the parcel is still synced at least every
///   [connectedPollInterval]. Stops once the parcel is final.
/// * **Commands** — cancel, retry dispatch and support send the
///   `status_version` the customer saw as `expected_version`, with one
///   Idempotency-Key per attempt, reused while its outcome is unknown and
///   the request is the same.
class C2cParcelTrackingCubit extends Cubit<C2cParcelTrackingState> {
  final int parcelId;
  final C2cParcelsRepository repository;
  final RealtimeRepository realtime;
  final C2cPeriodicTimerFactory _periodicTimer;
  final String Function() newIdempotencyKey;
  final DateTime Function() now;

  C2cParcelTrackingCubit({
    required this.parcelId,
    required this.repository,
    required this.realtime,
    C2cPeriodicTimerFactory periodicTimer = Timer.periodic,
    this.newIdempotencyKey = uuidV4,
    this.now = DateTime.now,
  }) : _periodicTimer = periodicTimer,
       super(const C2cTrackingLoading()) {
    realtime.watchParcel(parcelId);
    _realtimeSub = realtime.events.listen(_onRealtime);
  }

  static const Duration defaultPollInterval = Duration(seconds: 15);

  /// While the socket is up, the longest the parcel goes unsynced — in
  /// case its channel's authorization failed and no event will ever come.
  static const Duration connectedPollInterval = Duration(seconds: 60);

  /// The API guide's floor for a sane poll; anything faster is clamped.
  static const Duration _minPollInterval = Duration(seconds: 5);

  StreamSubscription<RealtimeEvent>? _realtimeSub;
  Timer? _timer;
  Duration? _timerInterval;
  bool _paused = false;
  bool _watchingTracking = false;
  bool _refreshing = false;

  /// A refresh was asked for while one was in flight — run once more.
  bool _refreshAgain = false;

  /// When the parcel was last known to be current: a successful read, or
  /// an event for it on the socket.
  DateTime? _lastSync;

  /// The key of a command whose outcome is unknown, with what it was for —
  /// see [_keyFor].
  (C2cCommand, int, Object?, String)? _pendingCommand;

  /// Details and live view, concurrently. Without the details there's
  /// nothing to show; without the live view, the details stand in.
  Future<void> load() async {
    emit(const C2cTrackingLoading());
    final (
      Either<Failure, C2cParcelDetails> details,
      Either<Failure, C2cParcelTracking> tracking,
    ) = await (
      repository.getParcelDetails(parcelId),
      repository.getTracking(parcelId),
    ).wait;
    if (isClosed) return;
    details.fold((Failure failure) => emit(C2cTrackingError(failure)), (
      C2cParcelDetails parcel,
    ) {
      _lastSync = now();
      emit(
        C2cTrackingLoaded(
          details: parcel,
          tracking: tracking.fold((_) => null, (C2cParcelTracking t) => t),
        ),
      );
      _afterChange();
    });
  }

  /// Re-reads both — after a status event, a command, or pull-to-refresh.
  /// A call made while one is in flight runs once more after it, so an
  /// event that lands mid-request is never lost.
  Future<void> refresh() async {
    if (state is! C2cTrackingLoaded) return;
    if (_refreshing) {
      _refreshAgain = true;
      return;
    }
    _refreshing = true;
    try {
      do {
        _refreshAgain = false;
        await _refreshOnce();
      } while (_refreshAgain && !isClosed);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _refreshOnce() async {
    final (
      Either<Failure, C2cParcelDetails> details,
      Either<Failure, C2cParcelTracking> tracking,
    ) = await (
      repository.getParcelDetails(parcelId),
      repository.getTracking(parcelId),
    ).wait;
    final C2cParcelTrackingState current = state;
    if (isClosed || current is! C2cTrackingLoaded) return;
    final C2cParcelDetails? fresh = details.fold(
      (_) => null,
      (C2cParcelDetails d) => d,
    );
    if (fresh != null) _lastSync = now();
    // Never step back to an older version than the one shown.
    final bool useFresh =
        fresh != null && fresh.statusVersion >= current.details.statusVersion;
    final C2cParcelDetails shown = useFresh ? fresh : current.details;
    // A code belongs to the stage it was issued in: a delivery code is void
    // once the parcel turns back to the sender.
    final bool stageChanged = shown.status != current.details.status;
    emit(
      current.copyWith(
        details: useFresh ? fresh : null,
        tracking: tracking.fold((_) => null, (C2cParcelTracking t) => t),
        otp: stageChanged || !_otpStillUseful(shown) ? _otpIdle : null,
      ),
    );
    _afterChange();
  }

  /// The polling fallback: the live view only, and the details too when
  /// it reveals a newer status.
  Future<void> _poll() async {
    if (_refreshing) return;
    final DateTime? last = _lastSync;
    if (realtime.isConnected &&
        last != null &&
        now().difference(last) < connectedPollInterval) {
      return;
    }
    final C2cParcelTrackingState before = state;
    if (before is! C2cTrackingLoaded) return;
    final Either<Failure, C2cParcelTracking> result = await repository
        .getTracking(parcelId);
    final C2cParcelTrackingState current = state;
    if (isClosed || current is! C2cTrackingLoaded) return;
    await result.fold((_) async {}, (C2cParcelTracking tracking) async {
      _lastSync = now();
      if (tracking.statusVersion > current.details.statusVersion) {
        await refresh();
      } else {
        emit(current.copyWith(tracking: tracking));
        _afterChange();
      }
    });
  }

  void _onRealtime(RealtimeEvent event) {
    final C2cParcelTrackingState current = state;
    switch (event) {
      case ParcelStatusChanged(:final int parcelId, :final int? statusVersion)
          when parcelId == this.parcelId:
        // The channel works; this parcel is being followed.
        _lastSync = now();
        // Already showing this version (e.g. after our own command).
        if (current is C2cTrackingLoaded &&
            statusVersion != null &&
            statusVersion <= current.details.statusVersion) {
          return;
        }
        unawaited(refresh());
      case ParcelDriverLocationUpdated(
            :final int parcelId,
            :final location,
            :final heading,
            :final recordedAt,
          )
          when parcelId == this.parcelId:
        _lastSync = now();
        if (current is! C2cTrackingLoaded) return;
        final C2cParcelTracking? tracking = current.tracking;
        if (tracking == null || tracking.isTerminal) return;
        // The socket doesn't guarantee order: never move the driver back
        // to an older position.
        final DateTime? shownAt = tracking.driverLocation?.recordedAt;
        if (shownAt != null &&
            recordedAt != null &&
            !recordedAt.isAfter(shownAt)) {
          return;
        }
        emit(
          current.copyWith(
            tracking: tracking.withDriverLocation(
              C2cDriverLocation(
                point: location,
                heading: heading,
                recordedAt: recordedAt,
              ),
            ),
          ),
        );
      case RealtimeReconnected():
        // Events sent while the socket was down were missed.
        unawaited(refresh());
      case ParcelRealtimeEvent() ||
          OrderRealtimeEvent() ||
          NotificationCreated():
        break;
    }
  }

  // --- Commands ---

  /// Sender only, before pickup.
  Future<void> cancel(C2cCancelReason reason, {String? note}) => _runCommand(
    C2cCommand.cancel,
    (reason, note?.trim() ?? ''),
    (C2cParcelDetails parcel) {
      if (!parcel.canCancel) return null;
      return (String key) => repository.cancelParcel(
        parcelId,
        reason: reason,
        note: note,
        expectedVersion: parcel.statusVersion,
        idempotencyKey: key,
      );
    },
  );

  /// Sender only, after no driver could be found.
  Future<void> retryDispatch() =>
      _runCommand(C2cCommand.retryDispatch, null, (C2cParcelDetails parcel) {
        if (!parcel.canRetryDispatch) return null;
        return (String key) => repository.retryDispatch(
          parcelId,
          expectedVersion: parcel.statusVersion,
          idempotencyKey: key,
        );
      });

  Future<void> openSupportCase(C2cSupportReason reason, String description) {
    final String text = description.trim();
    return _runCommand(C2cCommand.support, (reason, text), (
      C2cParcelDetails parcel,
    ) {
      if (!parcel.canOpenSupportCase || text.length < 5) return null;
      return (String key) => repository.openSupportCase(
        parcelId,
        reason: reason,
        description: text,
        idempotencyKey: key,
      );
    });
  }

  /// Runs [build]'s request unless it declines (returns null) or another
  /// command is running. [body] identifies what is sent, so a retry reuses
  /// the key only for the very same request. Success re-reads the parcel;
  /// so does any refusal, since the server's view then differs from the
  /// one shown.
  Future<void> _runCommand(
    C2cCommand command,
    Object? body,
    Future<Either<Failure, Unit>> Function(String key)? Function(
      C2cParcelDetails parcel,
    )
    build,
  ) async {
    final C2cParcelTrackingState current = state;
    if (current is! C2cTrackingLoaded ||
        current.command is C2cCommandInProgress) {
      return;
    }
    final int version = current.details.statusVersion;
    final Future<Either<Failure, Unit>> Function(String key)? send = build(
      current.details,
    );
    if (send == null) return;

    final String key = _keyFor(command, version, body);
    emit(current.copyWith(command: C2cCommandInProgress(command)));
    final Either<Failure, Unit> result = await send(key);
    if (!result.fold(_outcomeUnknown, (_) => false)) _pendingCommand = null;
    final C2cParcelTrackingState latest = state;
    if (isClosed || latest is! C2cTrackingLoaded) return;

    emit(
      latest.copyWith(
        command: result.fold(
          (Failure failure) => C2cCommandFailed(command, failure),
          (_) => C2cCommandDone(command),
        ),
      ),
    );
    final bool reread = result.fold(
      _isRefusal,
      (_) => command != C2cCommand.support,
    );
    if (reread) await refresh();
  }

  /// The same request (command, version and body) reuses the key of an
  /// attempt whose outcome is unknown; anything else gets a new one — a
  /// changed body under the old key would be refused as
  /// `idempotency_conflict`.
  String _keyFor(C2cCommand command, int version, Object? body) {
    final (C2cCommand, int, Object?, String)? pending = _pendingCommand;
    if (pending != null &&
        pending.$1 == command &&
        pending.$2 == version &&
        pending.$3 == body) {
      return pending.$4;
    }
    final String key = newIdempotencyKey();
    _pendingCommand = (command, version, body, key);
    return key;
  }

  /// Acknowledges a finished command so its result isn't announced again.
  void clearCommand() {
    final C2cParcelTrackingState current = state;
    if (current is C2cTrackingLoaded && current.command is! C2cCommandIdle) {
      emit(current.copyWith(command: const C2cCommandIdle()));
    }
  }

  // --- The delivery / return code ---

  /// A new code invalidates the previous one, so this only runs on the
  /// customer's request — and not while one is on its way.
  Future<void> requestOtp() async {
    final C2cParcelTrackingState current = state;
    if (current is! C2cTrackingLoaded ||
        !current.details.canRequestOtp ||
        current.otp is OtpLoading) {
      return;
    }
    final C2cParcelStatus askedAt = current.details.status;
    emit(current.copyWith(otp: const OtpLoading()));
    final Either<Failure, C2cParcelOtp> result = await repository.requestOtp(
      parcelId,
    );
    final C2cParcelTrackingState latest = state;
    if (isClosed || latest is! C2cTrackingLoaded) return;
    // The parcel changed stage meanwhile: the code is for the stage it left.
    if (latest.details.status != askedAt) {
      emit(latest.copyWith(otp: _otpIdle));
      return;
    }
    emit(
      latest.copyWith(
        otp: result.fold<DeliveryOtpState>(
          (Failure failure) => _otpUnavailable(failure)
              ? const OtpUnavailable()
              : OtpFailed(failure),
          (C2cParcelOtp otp) =>
              OtpReady(DeliveryOtp(code: otp.code, expiresAt: otp.expiresAt)),
        ),
      ),
    );
  }

  /// The parcel moved past the stage where a code can be issued.
  static bool _otpUnavailable(Failure failure) => switch (failure) {
    ServerFailure(:final String? code) ||
    ConflictFailure(:final String? code) =>
      code == C2cParcelErrorCode.otpNotAvailable ||
          code == C2cParcelErrorCode.invalidTransition,
    _ => false,
  };

  // --- Lifecycle ---

  /// Stops polling while the app is in the background.
  void pausePolling() {
    _paused = true;
    _stopTimer();
  }

  /// Back in the foreground: catches up at once, then polls again.
  Future<void> resumePolling() async {
    if (!_paused) return;
    _paused = false;
    await refresh();
  }

  /// Keeps the tracking channel and the poll timer in line with the
  /// parcel's current stage.
  void _afterChange() {
    final C2cParcelTrackingState current = state;
    if (current is! C2cTrackingLoaded) return;
    final C2cParcelDetails parcel = current.details;
    final C2cParcelStatus status = parcel.status;

    final bool showsDriver =
        !status.isTerminal && status.showsDriverTo(parcel.viewerRole);
    if (showsDriver && !_watchingTracking) {
      realtime.watchParcelTracking(parcelId);
      _watchingTracking = true;
    } else if (!showsDriver && _watchingTracking) {
      realtime.unwatchParcelTracking(parcelId);
      _watchingTracking = false;
    }

    if (status.isTerminal || _paused) {
      _stopTimer();
      return;
    }
    final int? seconds = current.tracking?.pollingIntervalSeconds;
    Duration interval = seconds == null
        ? defaultPollInterval
        : Duration(seconds: seconds);
    if (interval < _minPollInterval) interval = _minPollInterval;
    if (_timer != null && _timerInterval == interval) return;
    _stopTimer();
    _timerInterval = interval;
    _timer = _periodicTimer(interval, (_) => unawaited(_poll()));
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _timerInterval = null;
  }

  static const DeliveryOtpState _otpIdle = OtpIdle();

  /// A shown code only means something while it can still be used.
  static bool _otpStillUseful(C2cParcelDetails parcel) =>
      parcel.status.allowsDeliveryOtp || parcel.status.allowsReturnOtp;

  /// The server refused on purpose (it sent a code), so its view of the
  /// parcel differs from the one shown — `stale_version`, a status that no
  /// longer allows the command, and the like.
  static bool _isRefusal(Failure failure) => switch (failure) {
    ConflictFailure(:final String? code) =>
      code != null && code != C2cParcelErrorCode.requestInProgress,
    ServerFailure(:final String? code) => code != null,
    _ => false,
  };

  /// The command may or may not have gone through — keep the key.
  static bool _outcomeUnknown(Failure failure) => switch (failure) {
    NetworkFailure() => true,
    ServerFailure(:final String? code) => code == null,
    ConflictFailure(:final String? code) =>
      code == C2cParcelErrorCode.requestInProgress,
    _ => false,
  };

  @override
  Future<void> close() async {
    _stopTimer();
    await _realtimeSub?.cancel();
    realtime.unwatchParcel(parcelId);
    if (_watchingTracking) realtime.unwatchParcelTracking(parcelId);
    return super.close();
  }
}
