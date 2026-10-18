import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/no_data_found.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../core/widgets/vertical_timeline.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';
import '../utils/parcel_labels.dart';
import '../widgets/parcel_dropoff_card.dart';
import '../widgets/parcel_otp_card.dart';
import '../widgets/parcel_summary.dart';

/// What the details screen shows: the parcel, else why there's none.
typedef _DetailView = ({Parcel? parcel, Failure? failure, bool listLoaded});

/// Details of one admin-created (warehouse) parcel, pushed from the
/// Parcels tab.
///
/// Shares the tab's [ParcelsCubit] (provided around both routes in
/// `AppRoutes`), so a drop-off sent or a delivery code fetched here is the
/// same one the list shows — a second cubit would request its own code,
/// invalidating the list's. Opening refetches this parcel from the server.
class ParcelDetailScreen extends StatefulWidget {
  final int parcelId;

  /// The tapped parcel, shown until the cubit has this one.
  final Parcel? initialParcel;

  const ParcelDetailScreen({
    super.key,
    required this.parcelId,
    this.initialParcel,
  });

  @override
  State<ParcelDetailScreen> createState() => _ParcelDetailScreenState();
}

class _ParcelDetailScreenState extends State<ParcelDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ParcelsCubit>().refreshParcel(widget.parcelId);
  }

  _DetailView _select(ParcelsState state) => switch (state) {
    ParcelsLoaded(:final parcels) => (
      parcel:
          parcels.where((Parcel p) => p.id == widget.parcelId).firstOrNull ??
          widget.initialParcel,
      failure: null,
      listLoaded: true,
    ),
    ParcelsError(:final failure) => (
      parcel: widget.initialParcel,
      failure: failure,
      listLoaded: false,
    ),
    ParcelsInitial() || ParcelsLoading() => (
      parcel: widget.initialParcel,
      failure: null,
      listLoaded: false,
    ),
  };

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
        child: BlocSelector<ParcelsCubit, ParcelsState, _DetailView>(
          selector: _select,
          builder: (BuildContext context, _DetailView view) => switch (view) {
            (parcel: final Parcel parcel, failure: _, listLoaded: _) =>
              _ParcelDetailContent(parcel: parcel),
            (parcel: null, failure: final Failure failure, listLoaded: _) =>
              ErrorText(
                message: failure.userMessage,
                onRetry: () => context.read<ParcelsCubit>().fetchParcels(),
              ),
            (parcel: null, failure: null, listLoaded: true) => Center(
              child: NoDataFound(text: Strings.parcelsNotFound),
            ),
            (parcel: null, failure: null, listLoaded: false) => const Center(
              child: CircularProgressIndicator(),
            ),
          },
        ),
      ),
    );
  }
}

class _ParcelDetailContent extends StatelessWidget {
  final Parcel parcel;

  const _ParcelDetailContent({required this.parcel});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ParcelsCubit>().refreshParcel(parcel.id),
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
            if (parcel.needsDeliveryOtp) ...<Widget>[
              ParcelOtpCard(parcel: parcel),
              SizedBox(height: AppSpacing.lg.h),
            ],
            if (parcel.offersDropoffAction) ...<Widget>[
              ParcelDropoffCard(parcel: parcel),
              SizedBox(height: AppSpacing.lg.h),
            ],
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    Strings.parcelsTrackingTitle,
                    style: AppTextStyles.title(color: context.colors.textPrimary),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  VerticalTimeline(steps: parcel.timeline),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            _Card(child: ParcelSummary(parcel: parcel)),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(context.colors),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: child,
    );
  }
}
