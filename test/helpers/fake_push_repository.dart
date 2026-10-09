import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm/core/error/failures.dart';
import 'package:ssm/core/push/notification_target.dart';
import 'package:ssm/core/push/push_payload.dart';
import 'package:ssm/core/push/push_repository.dart';

/// Streams are driven by the test; [unregister] can be held open with a
/// [Completer] to test timeouts and ordering.
class FakePushRepository implements PushRepository {
  final StreamController<PushPayload> foreground =
      StreamController<PushPayload>.broadcast(sync: true);
  final StreamController<NotificationTarget> tapsController =
      StreamController<NotificationTarget>.broadcast(sync: true);
  final StreamController<void> refreshes = StreamController<void>.broadcast(
    sync: true,
  );

  NotificationTarget? launchTarget;
  int registerCalls = 0;
  int unregisterCalls = 0;
  Completer<Either<Failure, Unit>>? unregister;

  /// Called on every [unregisterDevice] — lets a test check what had (or
  /// hadn't) happened yet at that moment.
  void Function()? onUnregister;

  @override
  Future<void> initialize() async {}

  @override
  Stream<PushPayload> get foregroundMessages => foreground.stream;

  @override
  Stream<NotificationTarget> get taps => tapsController.stream;

  @override
  Future<NotificationTarget?> takeLaunchTarget() async {
    final NotificationTarget? target = launchTarget;
    launchTarget = null;
    return target;
  }

  @override
  Stream<void> get tokenRefreshes => refreshes.stream;

  @override
  Future<Either<Failure, Unit>> registerDevice() async {
    registerCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> unregisterDevice() {
    unregisterCalls++;
    onUnregister?.call();
    return unregister?.future ?? Future.value(const Right(unit));
  }
}
