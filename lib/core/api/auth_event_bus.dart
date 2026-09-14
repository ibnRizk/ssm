import 'dart:async';

class AuthEventBus {
  static final AuthEventBus instance = AuthEventBus._internal();
  AuthEventBus._internal();

  final _unauthorizedController = StreamController<void>.broadcast();

  Stream<void> get unauthorizedStream => _unauthorizedController.stream;

  void emitUnauthorized() {
    _unauthorizedController.add(null);
  }
}
