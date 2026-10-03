import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

/// Asks why the customer is cancelling. The reason, trimmed, or null when
/// they keep the order.
Future<String?> askCancelReason(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CancelSheet(),
    );

class _CancelSheet extends StatefulWidget {
  const _CancelSheet();

  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> {
  /// The backend stores the reason in a 255-character column.
  static const int _maxLength = 255;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _reasonController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      // Keeps the field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen.w,
            0,
            AppSpacing.screen.w,
            AppSpacing.lg.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  Strings.orderCancelSheetTitle,
                  style: AppTextStyles.h2(color: c.textPrimary),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  Strings.orderCancelSheetSubtitle,
                  style: AppTextStyles.body(color: c.textSecondary),
                ),
                SizedBox(height: AppSpacing.lg.h),
                TextFormField(
                  controller: _reasonController,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: _maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyLarge(color: c.textPrimary),
                  decoration: InputDecoration(
                    labelText: Strings.orderCancelReasonLabel,
                    hintText: Strings.orderCancelReasonHint,
                  ),
                  validator: (String? value) => (value?.trim().isEmpty ?? true)
                      ? Strings.fieldRequired
                      : null,
                ),
                SizedBox(height: AppSpacing.lg.h),
                AppButton(
                  btnText: Strings.orderCancelButton,
                  color: c.error,
                  onPressed: _submit,
                ),
                SizedBox(height: AppSpacing.sm.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(Strings.orderCancelKeep),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
