import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/parcel.dart';
import '../cubit/parcels_cubit.dart';
import '../cubit/parcels_state.dart';
import 'parcel_tracking_card.dart';
import 'pending_shipment_card.dart';

/// "Track shipment" title with its "Update now" link, then one card per
/// parcel: a timeline once it reached the warehouse, a simple "being
/// processed" row before that.
class ParcelsTrackingSection extends StatelessWidget {
  final List<Parcel> parcels;

  const ParcelsTrackingSection({super.key, required this.parcels});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.parcelsTrackingTitle,
                style: AppTextStyles.h2(color: c.textPrimary),
              ),
            ),
            const _UpdateNowLink(),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        for (int i = 0; i < parcels.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: AppSpacing.md.h),
          if (parcels[i].status == ParcelStatus.processing)
            PendingShipmentCard(
              key: ValueKey<int>(parcels[i].id),
              reference: parcels[i].reference,
            )
          else
            ParcelTrackingCard(
              key: ValueKey<int>(parcels[i].id),
              parcel: parcels[i],
            ),
        ],
      ],
    );
  }
}

/// Only this link rebuilds while a manual refresh runs.
class _UpdateNowLink extends StatelessWidget {
  const _UpdateNowLink();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<ParcelsCubit, ParcelsState, bool>(
      selector: (ParcelsState state) =>
          state is ParcelsLoaded && state.isRefreshing,
      builder: (BuildContext context, bool isRefreshing) => isRefreshing
          ? SizedBox(
              width: 18.r,
              height: 18.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.secondary,
              ),
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.read<ParcelsCubit>().fetchParcels(),
              child: Text(
                Strings.parcelsUpdateNow,
                style: AppTextStyles.titleSmall(color: c.secondary),
              ),
            ),
    );
  }
}
