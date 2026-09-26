import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/modal_bottom_sheet_scaffold.dart';

/// What the driver needs besides the GPS point: a readable address and
/// optional notes. Pops `(address, notes)` on confirm, null on dismiss —
/// the location itself is read after, by the cubit.
class DropoffDetailsSheet extends StatefulWidget {
  /// Pre-fills the address when a drop-off was sent before.
  final String? initialAddress;

  const DropoffDetailsSheet({super.key, this.initialAddress});

  static Future<(String, String)?> show(
    BuildContext context, {
    String? initialAddress,
  }) => showModalBottomSheet<(String, String)>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DropoffDetailsSheet(initialAddress: initialAddress),
    ),
  );

  @override
  State<DropoffDetailsSheet> createState() => _DropoffDetailsSheetState();
}

class _DropoffDetailsSheetState extends State<DropoffDetailsSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, (_addressController.text, _notesController.text));
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle inputStyle = AppTextStyles.bodyLarge(
      color: context.colors.textPrimary,
    );
    return ModalBottomSheetScaffold(
      title: Strings.parcelsActionButton,
      subTitle: Strings.parcelsDropoffSheetSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LabeledField(
              label: Strings.addressDetailsLabel,
              child: TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.streetAddress,
                style: inputStyle,
                decoration: InputDecoration(
                  hintText: Strings.addressDetailsHint,
                ),
                validator: (String? value) =>
                    Validator.call(value: value, type: ValidatorType.standard),
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            LabeledField(
              label: Strings.parcelsDropoffNotesLabel,
              child: TextFormField(
                controller: _notesController,
                textInputAction: TextInputAction.done,
                style: inputStyle,
                decoration: InputDecoration(
                  hintText: Strings.parcelsDropoffNotesHint,
                ),
                onFieldSubmitted: (_) => _confirm(),
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppButton(
              btnText: Strings.parcelsDropoffConfirm,
              onPressed: _confirm,
            ),
            SizedBox(height: AppSpacing.md.h),
          ],
        ),
      ),
    );
  }
}
