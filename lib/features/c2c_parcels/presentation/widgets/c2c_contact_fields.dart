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
  /// Null on an [C2cContactControllers.addressOnly] side.
  final TextEditingController? name;
  final TextEditingController? phone;
  final TextEditingController address = TextEditingController();

  C2cContactControllers()
    : name = TextEditingController(),
      phone = TextEditingController();

  /// For the sender, whose name and phone are the signed-in customer's.
  C2cContactControllers.addressOnly() : name = null, phone = null;

  void dispose() {
    name?.dispose();
    phone?.dispose();
    address.dispose();
  }
}

/// One side of the parcel: the address in words, building and apartment
/// included (the pin was set on the quote step), and the name and phone
/// when [controllers] has them.
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
          if ((controllers.name, controllers.phone) case (
            final TextEditingController name,
            final TextEditingController phone,
          )) ...<Widget>[
            LabeledField(
              label: Strings.createParcelNameLabel,
              child: TextFormField(
                controller: name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                style: inputStyle,
                validator: _required,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            LabeledField(
              label: Strings.createParcelPhoneLabel,
              child: PhoneField(controller: phone),
            ),
            SizedBox(height: AppSpacing.md.h),
          ],
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
        ],
      ),
    );
  }
}
