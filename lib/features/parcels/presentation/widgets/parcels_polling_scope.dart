import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/parcels_cubit.dart';

/// Manages the polling lifecycle for the Parcels tab at the [ShellRoute]
/// level — above both [ParcelsScreen] and [ParcelDetailScreen].
///
/// Because this widget sits above the Parcels branch's nested [Navigator],
/// it stays onstage while a parcel's detail page is pushed on top of the
/// list. Polling therefore continues without interruption on the detail
/// screen, where fresh status is equally useful.
///
/// Two signals stop and resume polling:
///
/// * **Tab switches** — `go_router`'s `StatefulShellRoute.indexedStack`
///   wraps offstage branches in `TickerMode(enabled: false)`. When the
///   user leaves the Parcels tab, [didChangeDependencies] detects the
///   disabled [TickerMode] and stops the timer. Returning to the tab
///   re-enables it and restarts polling with an immediate refresh so
///   data isn't up to 30 s stale.
///
/// * **App lifecycle** — [AppLifecycleListener] stops polling when the
///   app is hidden and resumes it (with an immediate refresh) when it
///   comes back to the foreground.
class ParcelsPollingScope extends StatefulWidget {
  const ParcelsPollingScope({super.key, required this.child});

  final Widget child;

  @override
  State<ParcelsPollingScope> createState() => _ParcelsPollingState();
}

class _ParcelsPollingState extends State<ParcelsPollingScope> {
  // Cached in initState: context.read is unsafe in dispose (element
  // is already deactivated).
  late final ParcelsCubit _cubit;
  late final AppLifecycleListener _lifecycle;

  /// Tracks the last known TickerMode enabled value so
  /// [didChangeDependencies] only acts on actual transitions.
  bool _tickerEnabled = true;

  /// False while the app is in the background.
  bool _appVisible = true;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ParcelsCubit>();
    _lifecycle = AppLifecycleListener(
      onHide: _onHide,
      onShow: _onShow,
    );
    // The ShellRoute builder already issued fetchParcels() for the initial
    // load; just start the periodic timer here.
    _cubit.startPolling();
  }

  void _onHide() {
    _appVisible = false;
    _cubit.stopPolling();
  }

  void _onShow() {
    _appVisible = true;
    if (_tickerEnabled) _resumePolling();
  }

  /// Refreshes data immediately (so the customer never sees stale info on
  /// return) and restarts the 30-second periodic timer.
  void _resumePolling() {
    unawaited(_cubit.fetchParcels(silent: true));
    _cubit.startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool enabled = TickerMode.valuesOf(context).enabled;
    if (enabled == _tickerEnabled) return;
    _tickerEnabled = enabled;
    if (enabled && _appVisible) {
      _resumePolling();
    } else {
      _cubit.stopPolling();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _cubit.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
