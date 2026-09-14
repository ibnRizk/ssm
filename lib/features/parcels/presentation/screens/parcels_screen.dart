import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../widgets/parcel_action_card.dart';
import '../widgets/parcel_tracking_card.dart';
import '../widgets/parcels_header.dart';
import '../widgets/pending_shipment_card.dart';

/// Parcels tab body. The bottom navigation bar and its Scaffold live in
/// [MainScaffold] — this widget is only the scrollable content for that tab.
class ParcelsScreen extends StatelessWidget {
  const ParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.lg.h,
          AppSpacing.screen.w,
          AppSpacing.xxl.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const ParcelsHeader(),
            SizedBox(height: AppSpacing.lg.h),
            ParcelActionCard(
              // TODO: request the device location and send it to the
              // parcels API once that flow exists.
              onSendLocation: () {},
            ),
            SizedBox(height: AppSpacing.xl.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    Strings.parcelsTrackingTitle,
                    style: AppTextStyles.h2(color: c.textPrimary),
                  ),
                ),
                // TODO: trigger a real tracking refresh once that exists.
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    Strings.parcelsUpdateNow,
                    style: AppTextStyles.titleSmall(color: c.secondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            const ParcelTrackingCard(),
            SizedBox(height: AppSpacing.xl.h),
            PendingShipmentCard(
              // TODO: open that shipment's own tracking once it exists.
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
