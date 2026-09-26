import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/address.dart';
import '../utils/address_messages.dart';

/// Home / Office / Other as a row of pill chips.
class AddressTypeSelector extends StatelessWidget {
  final AddressType selected;
  final ValueChanged<AddressType> onChanged;

  const AddressTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm.w,
      children: <Widget>[
        for (final AddressType type in AddressType.values)
          ChoiceChip(
            label: Text(type.label),
            selected: type == selected,
            onSelected: (_) => onChanged(type),
            showCheckmark: false,
            selectedColor: c.secondaryLight,
            backgroundColor: c.surface,
            side: BorderSide(color: type == selected ? c.secondary : c.border),
            shape: const StadiumBorder(),
            labelStyle: AppTextStyles.body(
              color: type == selected ? c.secondaryDark : c.textPrimary,
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
          ),
      ],
    );
  }
}
