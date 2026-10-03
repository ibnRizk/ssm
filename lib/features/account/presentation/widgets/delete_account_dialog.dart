import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Spells out what deleting the account loses, and only enables the
/// destructive action once the customer ticks that they understand it's
/// permanent. True only when they confirm.
Future<bool> confirmDeleteAccount(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return confirmed ?? false;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AlertDialog(
      title: Text(Strings.accountDeleteTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Strings.accountDeleteConsequences,
              style: AppTextStyles.body(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.md.h),
            CheckboxListTile(
              value: _acknowledged,
              onChanged: (bool? value) =>
                  setState(() => _acknowledged = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: c.error,
              title: Text(
                Strings.accountDeleteAcknowledge,
                style: AppTextStyles.body(color: c.textPrimary),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(Strings.cancel),
        ),
        TextButton(
          onPressed: _acknowledged ? () => Navigator.pop(context, true) : null,
          style: TextButton.styleFrom(foregroundColor: c.error),
          child: Text(Strings.accountDeleteConfirm),
        ),
      ],
    );
  }
}
