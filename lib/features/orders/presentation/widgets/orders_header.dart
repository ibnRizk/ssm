import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// A [Stack], not a [Row]: the avatar and the count pill are different
/// widths, so centering the title in the space *between* them would put it
/// visibly off-centre — same trick [RestaurantsHeader] uses.
///
/// TODO: pull the user's real initial once auth is wired up — 'ع' is a
/// static placeholder for now (see [HomeHeader]'s equivalent TODO).
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
        ],
      ),
    );
  }
}
