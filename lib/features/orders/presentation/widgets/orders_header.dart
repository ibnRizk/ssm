import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ssm/features/account/presentation/cubit/profile_cubit.dart';
import 'package:ssm/features/account/presentation/cubit/profile_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// A [Stack], not a [Row]: the avatar and the count pill are different
/// widths, so centering the title in the space *between* them would put it
/// visibly off-centre — same trick [RestaurantsHeader] uses.
class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Text(
            Strings.ordersTitle,
            style: AppTextStyles.h1(color: c.textPrimary),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child:
                BlocSelector<
                  ProfileCubit,
                  ProfileState,
                  String
                >(
                  selector: (ProfileState state) =>
                      state is ProfileLoaded
                      ? state.profile.initial
                      : '?',
                  builder:
                      (
                        BuildContext context,
                        String initial,
                      ) => Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: c.secondaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: AppTextStyles.h2(
                              color: c.secondaryDark,
                            ),
                          ),
                        ),
                      ),
                ),
          ),
        ],
      ),
    );
  }
}
