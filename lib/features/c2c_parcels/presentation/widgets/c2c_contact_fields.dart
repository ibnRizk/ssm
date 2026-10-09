import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/phone_field.dart';

/// The text controllers of one side (sender or recipient). Owned and
/// disposed by the screen's State.
class C2cContactControllers {
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController building = TextEditingController();
  final TextEditingController floor = TextEditingController();
  final TextEditingController apartment = TextEditingController();
  final TextEditingController notes = TextEditingController();

  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      name,
      phone,
      address,
      building,
      floor,
      apartment,
      notes,
    ]) {
      c.dispose();
    }
  }
}

/// One side of the parcel: name, phone, the address in words (the pin was
/// set on the quote step), and the optional building / floor / apartment
/// and notes.
class C2cContactFields extends StatelessWidget {
  final String title;
  final IconData icon;
  final C2cContactControllers controllers;

  const C2cContactFields({
    super.key,
    required this.title,
    required this.icon,
    required this.controllers,
  });

  static String? _required(String? value) =>
      Validator.call(value: value, type: ValidatorType.standard);

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final TextStyle inputStyle = AppTextStyles.bodyLarge(color: c.textPrimary);
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: c.secondary, size: 20.r),
              SizedBox(width: AppSpacing.xs.w),
              Text(title, style: AppTextStyles.title(color: c.textPrimary)),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          LabeledField(
            label: Strings.createParcelNameLabel,
            child: TextFormField(
              controller: controllers.name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              style: inputStyle,
              validator: _required,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          LabeledField(
            label: Strings.createParcelPhoneLabel,
            child: PhoneField(controller: controllers.phone),
          ),
          SizedBox(height: AppSpacing.md.h),
          LabeledField(
            label: Strings.createParcelAddressLabel,
            child: TextFormField(
              controller: controllers.address,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.streetAddress,
              minLines: 2,
              maxLines: 3,
              style: inputStyle,
              decoration: InputDecoration(
                hintText: Strings.createParcelAddressHint,
              ),
              validator: _required,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: <Widget>[
              Expanded(
                child: _ShortField(
                  label: Strings.createParcelBuildingLabel,
                  controller: controllers.building,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: _ShortField(
                  label: Strings.createParcelFloorLabel,
                  controller: controllers.floor,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: _ShortField(
                  label: Strings.createParcelApartmentLabel,
                  controller: controllers.apartment,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          LabeledField(
            label: Strings.createParcelNotesLabel,
            child: TextFormField(
              controller: controllers.notes,
              textInputAction: TextInputAction.next,
              maxLength: 500,
              style: inputStyle,
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ShortField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        textInputAction: TextInputAction.next,
        maxLength: 20,
        style: AppTextStyles.bodyLarge(color: context.colors.textPrimary),
        decoration: const InputDecoration(counterText: ''),
      ),
    );
  }
}
