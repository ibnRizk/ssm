import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/push/notification_target.dart';
import '../cubit/notification_hub_cubit.dart';
import '../cubit/notification_hub_state.dart';
import '../utils/notification_navigation.dart';

/// Opens the screen a tapped push points to — whether the tap resumed the
/// app or launched it from killed (the hub replays that one at start).
/// Sits at the shell, below the router, so it can navigate.
class NotificationHubListener extends StatelessWidget {
  final Widget child;

  const NotificationHubListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationHubCubit, NotificationHubState>(
      listenWhen: (NotificationHubState previous, NotificationHubState next) =>
          next.pendingTarget != null &&
          next.pendingTarget != previous.pendingTarget,
      listener: (BuildContext context, NotificationHubState state) {
        final NotificationTarget target = state.pendingTarget!;
        context.read<NotificationHubCubit>().targetOpened();
        openNotificationTarget(context, target);
      },
      child: child,
    );
  }
}
