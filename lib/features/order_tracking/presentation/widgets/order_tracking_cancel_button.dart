import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../cubit/order_tracking_cubit.dart';
import '../cubit/order_tracking_state.dart';
import 'order_tracking_cancel_sheet.dart';

/// "Cancel order" while the merchant hasn't accepted yet. Asks for a
/// reason, then cancels; the outcome is announced by the screen. Only this
/// widget rebuilds while the request runs.
class OrderTrackingCancelButton extends StatelessWidget {
  const OrderTrackingCancelButton({super.key});

  Future<void> _onTap(BuildContext context) async {
    final OrderTrackingCubit cubit = context.read<OrderTrackingCubit>();
    final String? reason = await askCancelReason(context);
    if (reason != null) await cubit.cancelOrder(reason);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<OrderTrackingCubit, OrderTrackingState, bool>(
      selector: (OrderTrackingState state) =>
          state is OrderTrackingLoaded &&
          state.cancellation is CancellationInProgress,
      builder: (BuildContext context, bool inProgress) => AppOutlinedButton(
        text: Strings.orderCancelButton,
        textColor: c.error,
        borderColor: c.error,
        buttonRadius: AppRadius.lg.r,
        onPressed: inProgress ? null : () => _onTap(context),
        icon: inProgress
            ? SizedBox.square(
                dimension: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: c.error,
                ),
              )
            : null,
      ),
    );
  }
}
