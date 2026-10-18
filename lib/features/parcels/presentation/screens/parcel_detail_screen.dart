import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/delivery_otp/delivery_otp.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/delivery_otp_card.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';
import '../utils/parcel_labels.dart';
import '../widgets/dropoff_details_sheet.dart';
import '../widgets/parcel_action_card.dart';

/// Detail view for a single admin-created (warehouse) parcel.
///
/// Pushed from the Parcels tab. The route provides its **own**
/// [ParcelsCubit] instance (see `AppRoutes`) so that [BlocBuilder] never
/// throws a [ProviderNotFoundException] — GoRouter child routes do not
/// inherit the parent route's providers.
///
/// [initialParcel] is the parcel passed via `state.extra` on navigation;
/// it is displayed immediately while the cubit fetches fresh data, avoiding
/// a loading-spinner flash on entry.
class ParcelDetailScreen extends StatelessWidget {
  final int parcelId;

  /// Shown instantly on open; replaced by the cubit's data once loaded.
  final Parcel? initialParcel;

  const ParcelDetailScreen({
    super.key,
    required this.parcelId,
    this.initialParcel,
  });

  Future<void> _onSendLocation(BuildContext context, Parcel parcel) async {
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
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: SimpleAppBar(
        title: Strings.parcelsTrackingTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocBuilder<ParcelsCubit, ParcelsState>(
          builder: (BuildContext context, ParcelsState state) {
            // Prefer fresh data from cubit; fall back to the parcel passed
            // via navigation extra while the first fetch is in flight.
            final Parcel? parcel = (state is ParcelsLoaded
                    ? state.parcels
                        .where((Parcel p) => p.id == parcelId)
                        .firstOrNull
                    : null) ??
                initialParcel;

            if (parcel == null) {
              if (state is ParcelsLoading || state is ParcelsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Text(
                  Strings.parcelsEmpty,
                  style: AppTextStyles.body(color: c.textSecondary),
                ),
              );
            }

            final DeliveryOtpState? otp = state is ParcelsLoaded
                ? state.otps[parcelId]
                : null;
            final bool dropoffBusy = state is ParcelsLoaded &&
                state.dropoff is DropoffInProgress &&
                (state.dropoff as DropoffInProgress).parcelId == parcelId;

            return RefreshIndicator(
              onRefresh: () => context.read<ParcelsCubit>().fetchParcels(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen.w,
                  AppSpacing.lg.h,
                  AppSpacing.screen.w,
                  AppSpacing.xxl.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // OTP card — only when driver is out for delivery
                    if (parcel.needsDeliveryOtp && otp != null) ...<Widget>[
                      DeliveryOtpCard(
                        otp: otp,
                        subtitle: parcel.reference,
                        hint: Strings.parcelsOtpHint,
                        onRequest: () => context
                            .read<ParcelsCubit>()
                            .requestDeliveryOtp(parcel.id),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                    ],

                    // Drop-off action card (warehouse or awaiting location)
                    if (parcel.acceptsDropoffLocation &&
                        parcel.status != ParcelStatus.delivered) ...<Widget>[
                      ParcelActionCard(
                        reference: parcel.reference,
                        locationSent: parcel.hasDropoffLocation,
                        isBusy: dropoffBusy,
                        onSendLocation: () =>
                            _onSendLocation(context, parcel),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                    ],

                    // Timeline card
                    _TimelineCard(parcel: parcel),
                    SizedBox(height: AppSpacing.lg.h),

                    // Payment & reference info
                    _PaymentCard(parcel: parcel),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Parcel parcel;

  const _TimelineCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            Strings.parcelsTrackingTitle,
            style: AppTextStyles.title(color: c.textPrimary),
          ),
          SizedBox(height: AppSpacing.md.h),
          VerticalTimeline(steps: parcel.timeline),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Parcel parcel;

  const _PaymentCard({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final DateTime? updatedAt = parcel.updatedAt;
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  Strings.parcelsShipmentReference(parcel.reference),
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (updatedAt != null)
                Text(
                  parcelUpdatedLabel(
                    updatedAt,
                    DateTime.now(),
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          Wrap(
            spacing: AppSpacing.xs.w,
            runSpacing: AppSpacing.xxs.h,
            children: <Widget>[
              _Chip(
                label: parcel.paymentLabel,
                background: parcel.paymentType == ParcelPaymentType.cod
                    ? c.secondaryLight
                    : c.successLight,
                foreground: parcel.paymentType == ParcelPaymentType.cod
                    ? c.secondaryDark
                    : c.success,
              ),
              if (parcel.deliveryFee == 0)
                _Chip(
                  label: Strings.parcelsFreeDelivery,
                  background: c.primaryLight,
                  foreground: c.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTextStyles.label(color: foreground)),
    );
  }
}
