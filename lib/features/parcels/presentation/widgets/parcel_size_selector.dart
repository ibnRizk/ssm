import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/c2c_parcel_quote.dart';

/// Small / medium / large, as equal-width chips.
class ParcelSizeSelector extends StatelessWidget {
  final ParcelSize selected;
  final ValueChanged<ParcelSize> onChanged;

  const ParcelSizeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static String _label(ParcelSize size) => switch (size) {
    ParcelSize.small => Strings.sendParcelSizeSmall,
    ParcelSize.medium => Strings.sendParcelSizeMedium,
    ParcelSize.large => Strings.sendParcelSizeLarge,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      children: <Widget>[
        for (final ParcelSize size in ParcelSize.values) ...<Widget>[
          if (size != ParcelSize.values.first) SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: ChoiceChip(
              label: SizedBox(
                width: double.infinity,
                child: Text(
                  _label(size),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    color: size == selected ? Colors.white : c.textPrimary,
                  ),
                ),
              ),
              selected: size == selected,
              showCheckmark: false,
              selectedColor: c.primary,
              backgroundColor: c.surface,
              side: BorderSide(color: size == selected ? c.primary : c.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
              onSelected: (_) => onChanged(size),
            ),
          ),
        ],
      ],
    );
  }
}
