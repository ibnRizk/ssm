import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../catalog/domain/entities/store_item.dart';

/// A single menu item: image tile, name/description/price (with the list
/// price struck through when discounted), and the orange "add to cart"
/// button. The running total shows up in the floating cart bar.
class RestaurantProductCard extends StatelessWidget {
  final StoreItem item;

  /// The store whose menu this is — the item itself may not say, and the
  /// cart needs it to keep to one store.
  final int storeId;

  const RestaurantProductCard({
    super.key,
    required this.item,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? description = item.description;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AppNetworkImage(
            url: item.imageUrl,
            width: 64.r,
            height: 64.r,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
            fallback: ColoredBox(
              color: c.secondaryLight,
              child: Icon(
                Icons.fastfood_outlined,
                color: c.secondary,
                size: 28.r,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null) ...<Widget>[
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: AppTextStyles.caption(color: c.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: AppSpacing.xs.h),
                Row(
                  children: <Widget>[
                    Text(
                      formatSar(item.finalPrice),
                      style: AppTextStyles.titleSmall(color: c.textPrimary),
                    ),
                    if (item.hasDiscount) ...<Widget>[
                      SizedBox(width: AppSpacing.xs.w),
                      Text(
                        formatSar(item.price),
                        style: AppTextStyles.caption(
                          color: c.textHint,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          _AddButton(item: item, storeId: storeId),
        ],
      ),
    );
  }
}

/// Rebuilds alone when this item starts or stops being added.
class _AddButton extends StatelessWidget {
  final StoreItem item;
  final int storeId;

  const _AddButton({required this.item, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<CartCubit, CartState, bool>(
      selector: (CartState state) =>
          state is CartLoaded && state.addingItemIds.contains(item.id),
      builder: (BuildContext context, bool adding) => GestureDetector(
        onTap: adding
            ? null
            : () => context.read<CartCubit>().addItem(
                CartItemRequest(
                  itemId: item.id,
                  storeId: item.storeId ?? storeId,
                  unitPrice: item.finalPrice,
                ),
              ),
        child: Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.secondary),
          child: adding
              ? Padding(
                  padding: EdgeInsets.all(8.r),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
