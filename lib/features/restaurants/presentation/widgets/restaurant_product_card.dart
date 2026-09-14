import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/store_cart_cubit.dart';

/// A single menu item: image tile, name/description/price, and the orange
/// "add to cart" button. Tapping "+" dispatches to [StoreCartCubit] — the
/// running total shows up in the floating cart bar, not on the card itself.
class RestaurantProductCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  /// The line item's subtitle once it's in the cart — the store name, so a
  /// cart with items from multiple stores (once that's possible) still
  /// shows where each one came from.
  final String storeName;

  const RestaurantProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg.r),
            ),
            child: Icon(icon, color: iconColor, size: 28.r),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: AppTextStyles.caption(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  '$price ر.س',
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          GestureDetector(
            onTap: () => context.read<StoreCartCubit>().addProduct(
              productId: id,
              name: name,
              subtitle: storeName,
              unitPrice: price,
            ),
            child: Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.secondary,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
