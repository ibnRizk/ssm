import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/parcel.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';
import 'dropoff_details_sheet.dart';
import 'parcel_action_card.dart';

/// The action card bound to the drop-off flow: asks for the address
/// details, then the cubit reads the GPS position and sends both. The
/// result is announced by `ParcelsFeedbackListener`.
class ParcelDropoffCard extends StatelessWidget {
  final Parcel parcel;

  const ParcelDropoffCard({super.key, required this.parcel});

  Future<void> _start(BuildContext context) async {
    final ParcelsCubit cubit = context.read<ParcelsCubit>();
    final (String, String)? details = await DropoffDetailsSheet.show(
      context,
      initialAddress: parcel.deliveryAddress,
    );
    if (details == null) return;
    final (String address, String notes) = details;
    await cubit.sendDropoffLocation(
      parcel.id,
      deliveryAddress: address,
      notes: notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Busy for any parcel: the cubit runs one drop-off at a time.
    return BlocSelector<ParcelsCubit, ParcelsState, bool>(
      selector: (ParcelsState state) =>
          state is ParcelsLoaded && state.dropoff is DropoffInProgress,
      builder: (BuildContext context, bool isBusy) => ParcelActionCard(
        reference: parcel.reference,
        locationSent: parcel.hasDropoffLocation,
        isBusy: isBusy,
        onSendLocation: () => _start(context),
      ),
    );
  }
}
