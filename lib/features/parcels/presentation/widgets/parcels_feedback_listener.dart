import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';

/// One-shot snack bars for the drop-off result and a failed refresh.
/// Never rebuilds [child].
///
/// Sits at the parcels route, above both the list and a parcel's details,
/// so each result is announced once whichever screen sent it.
class ParcelsFeedbackListener extends StatelessWidget {
  final Widget child;

  const ParcelsFeedbackListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<ParcelsCubit, ParcelsState>>[
        BlocListener<ParcelsCubit, ParcelsState>(
          listenWhen: (ParcelsState previous, ParcelsState current) =>
              current is ParcelsLoaded &&
              previous is ParcelsLoaded &&
              previous.dropoff != current.dropoff,
          listener: (BuildContext context, ParcelsState state) {
            switch ((state as ParcelsLoaded).dropoff) {
              case DropoffSent():
                showAppSnackBar(
                  context: context,
                  message: Strings.parcelsDropoffSent,
                  type: ToastType.success,
                );
              case DropoffFailed(:final failure):
                showAppSnackBar(
                  context: context,
                  message: failure.userMessage,
                  type: ToastType.error,
                );
              case DropoffIdle() || DropoffInProgress():
                break;
            }
          },
        ),
        BlocListener<ParcelsCubit, ParcelsState>(
          listenWhen: (ParcelsState previous, ParcelsState current) =>
              current is ParcelsLoaded && current.refreshFailure != null,
          listener: (BuildContext context, ParcelsState state) =>
              showAppSnackBar(
                context: context,
                message: (state as ParcelsLoaded).refreshFailure!.userMessage,
                type: ToastType.error,
              ),
        ),
      ],
      child: child,
    );
  }
}
