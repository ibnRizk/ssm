import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/delivery_otp_card.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';

/// The code the customer reads to the courier, for a parcel that is out
/// for delivery. Rebuilds only when this parcel's code changes.
class ParcelOtpCard extends StatelessWidget {
  final Parcel parcel;

  const ParcelOtpCard({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ParcelsCubit, ParcelsState, DeliveryOtpState>(
      selector: (ParcelsState state) =>
          (state is ParcelsLoaded ? state.otps[parcel.id] : null) ??
          const OtpIdle(),
      builder: (BuildContext context, DeliveryOtpState otp) => DeliveryOtpCard(
        otp: otp,
        subtitle: parcel.reference,
        hint: Strings.parcelsOtpHint,
        onRequest: () =>
            context.read<ParcelsCubit>().requestDeliveryOtp(parcel.id),
      ),
    );
  }
}
