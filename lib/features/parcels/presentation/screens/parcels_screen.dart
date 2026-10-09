import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/delivery_otp_card.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';
import '../widgets/dropoff_details_sheet.dart';
import '../widgets/parcel_action_card.dart';
import '../widgets/parcels_header.dart';
import '../widgets/parcels_tracking_section.dart';

/// Parcels tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
/// Expects a [ParcelsCubit] above it (provided at the route).
class ParcelsScreen extends StatelessWidget {
  const ParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: _ParcelsFeedbackListener(
        child: RefreshIndicator(
          onRefresh: () => context.read<ParcelsCubit>().fetchParcels(),
          child: SingleChildScrollView(
            // Pull-to-refresh must work even on a short page.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen.w,
              AppSpacing.lg.h,
              AppSpacing.screen.w,
              AppSpacing.xxl.h,
            ),
            child: BlocBuilder<ParcelsCubit, ParcelsState>(
              // The drop-off flow and "Update now" rebuild their own widgets.
              buildWhen: (ParcelsState previous, ParcelsState current) =>
                  previous.runtimeType != current.runtimeType ||
                  (previous is ParcelsLoaded &&
                      current is ParcelsLoaded &&
                      previous.parcels != current.parcels),
              builder: (BuildContext context, ParcelsState state) =>
                  switch (state) {
                    ParcelsLoaded(:final parcels) => _ParcelsContent(
                      parcels: parcels,
                    ),
                    ParcelsError(:final failure) => Column(
                      children: <Widget>[
                        const ParcelsHeader(),
                        ErrorText(
                          message: failure.userMessage,
                          onRetry: () =>
                              context.read<ParcelsCubit>().fetchParcels(),
                        ),
                      ],
                    ),
                    ParcelsInitial() || ParcelsLoading() => Column(
                      children: <Widget>[
                        const ParcelsHeader(),
                        SizedBox(height: AppSpacing.xxl.h),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  },
            ),
          ),
        ),
      ),
    );
  }
}

class _ParcelsContent extends StatelessWidget {
  final List<Parcel> parcels;

  const _ParcelsContent({required this.parcels});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Parcel? target = Parcel.dropoffTarget(parcels);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ParcelsHeader(
          newCount: parcels.where((Parcel p) => p.awaitsDropoffLocation).length,
        ),
        SizedBox(height: AppSpacing.lg.h),
        // Door-to-door parcels live in their own feature; these lead there.
        Row(
          children: <Widget>[
            Expanded(
              child: AppOutlinedButton(
                text: Strings.parcelsSendButton,
                icon: Icon(Icons.local_shipping_outlined, color: c.secondary),
                onPressed: () => context.push(AppRoutes.sendParcel),
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: AppOutlinedButton(
                text: Strings.parcelsMyC2cButton,
                icon: Icon(Icons.inventory_outlined, color: c.secondary),
                onPressed: () => context.push(AppRoutes.c2cParcels),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg.h),
        for (final Parcel parcel in parcels)
          if (parcel.needsDeliveryOtp) ...<Widget>[
            _ParcelOtpCard(parcel: parcel),
            SizedBox(height: AppSpacing.lg.h),
          ],
        if (target != null) ...<Widget>[
          _DropoffCard(parcel: target),
          SizedBox(height: AppSpacing.xl.h),
        ],
        if (parcels.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxl.h),
            child: NoDataFound(text: Strings.parcelsEmpty),
          )
        else
          ParcelsTrackingSection(parcels: parcels),
      ],
    );
  }
}

/// The code the customer reads to the courier, for a parcel that is out
/// for delivery. Rebuilds only when this parcel's code changes.
class _ParcelOtpCard extends StatelessWidget {
  final Parcel parcel;

  const _ParcelOtpCard({required this.parcel});

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

/// The action card bound to the drop-off flow: asks for the address
/// details, then the cubit reads the GPS position and sends both.
class _DropoffCard extends StatelessWidget {
  final Parcel parcel;

  const _DropoffCard({required this.parcel});

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

/// One-shot snack bars for the drop-off result and a failed refresh.
/// Never rebuilds [child].
class _ParcelsFeedbackListener extends StatelessWidget {
  final Widget child;

  const _ParcelsFeedbackListener({required this.child});

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
