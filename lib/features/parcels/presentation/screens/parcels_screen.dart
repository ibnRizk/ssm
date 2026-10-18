import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';
import '../widgets/parcel_dropoff_card.dart';
import '../widgets/parcel_otp_card.dart';
import '../widgets/parcels_header.dart';
import '../widgets/parcels_tracking_section.dart';

/// Parcels tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
/// Expects a [ParcelsCubit] above it (provided at the route, together with
/// the drop-off / refresh snack bars).
///
/// Polling is managed by [ParcelsPollingScope], which sits at the ShellRoute
/// level above this widget so it also covers the parcel detail page.
class ParcelsScreen extends StatelessWidget {
  const ParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
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
            ParcelOtpCard(parcel: parcel),
            SizedBox(height: AppSpacing.lg.h),
          ],
        if (target != null) ...<Widget>[
          ParcelDropoffCard(parcel: target),
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
