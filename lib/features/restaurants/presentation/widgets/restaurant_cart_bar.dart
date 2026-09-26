import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';

/// The fixed "view cart" button docked under the scrollable body, with the
/// live number of units in the server-side cart.
class RestaurantCartBar extends StatelessWidget {
  final VoidCallback? onViewCart;

  const RestaurantCartBar({super.key, this.onViewCart});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen.w,
          AppSpacing.sm.h,
          AppSpacing.screen.w,
          AppSpacing.sm.h,
        ),
        child: BlocSelector<CartCubit, CartState, int>(
          selector: (CartState state) =>
              state is CartLoaded ? state.cart.itemCount : 0,
          builder: (BuildContext context, int itemCount) {
            return GestureDetector(
              onTap: onViewCart,
              child: Container(
                height: AppSizes.buttonHeight.h,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                decoration: BoxDecoration(
                  color: c.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.lg.r),
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      Strings.storeDetailsCartCount(itemCount),
                      style: AppTextStyles.body(color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      Strings.storeDetailsCartViewButton,
                      style: AppTextStyles.button(color: Colors.white),
                    ),
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
