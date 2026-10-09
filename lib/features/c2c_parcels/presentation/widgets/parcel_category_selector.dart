import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/c2c_parcel_quote.dart';
import '../utils/c2c_parcel_labels.dart';

/// The six parcel categories the server prices, as a wrapping row of chips
/// with an icon each.
class ParcelCategorySelector extends StatelessWidget {
  final ParcelCategory selected;
  final ValueChanged<ParcelCategory> onChanged;

  const ParcelCategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static IconData _icon(ParcelCategory category) => switch (category) {
    ParcelCategory.documents => Icons.description_outlined,
    ParcelCategory.small => Icons.inventory_2_outlined,
    ParcelCategory.medium => Icons.all_inbox_outlined,
    ParcelCategory.large => Icons.local_shipping_outlined,
    ParcelCategory.fragile => Icons.wine_bar_outlined,
    ParcelCategory.other => Icons.category_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm.w,
      runSpacing: AppSpacing.sm.h,
      children: <Widget>[
        for (final ParcelCategory category in ParcelCategory.values)
          ChoiceChip(
            avatar: Icon(
              _icon(category),
              size: 18.r,
              color: category == selected ? Colors.white : c.secondary,
            ),
            label: Text(
              category.label,
              style: AppTextStyles.body(
                color: category == selected ? Colors.white : c.textPrimary,
              ),
            ),
            selected: category == selected,
            showCheckmark: false,
            selectedColor: c.primary,
            backgroundColor: c.surface,
            side: BorderSide(
              color: category == selected ? c.primary : c.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
            onSelected: (_) => onChanged(category),
          ),
      ],
    );
  }
}
