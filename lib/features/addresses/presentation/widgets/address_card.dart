import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/address.dart';
import '../cubit/addresses_cubit.dart';
import '../utils/address_messages.dart';

/// One saved address: type chip, street text, contact line, and a delete
/// button (a spinner while its request runs).
class AddressCard extends StatelessWidget {
  final Address address;
  final bool isDeleting;

  const AddressCard({
    super.key,
    required this.address,
    required this.isDeleting,
  });

  IconData get _icon => switch (address.type) {
    AddressType.home => Icons.home_outlined,
    AddressType.office => Icons.work_outline,
    AddressType.other => Icons.location_on_outlined,
  };

  Future<void> _confirmDelete(BuildContext context) async {
    final AddressesCubit cubit = context.read<AddressesCubit>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(Strings.addressDeleteConfirmTitle),
        content: Text(Strings.addressDeleteConfirmMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.error,
            ),
            child: Text(Strings.delete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.delete(address.id);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String contact = <String>[
      address.contactPersonName,
      SaudiPhone.toLocal(address.contactPersonNumber),
    ].where((String part) => part.isNotEmpty).join(' · ');

    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md.w,
        AppSpacing.md.h,
        AppSpacing.xs.w,
        AppSpacing.md.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: c.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 20.r, color: c.secondary),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  address.type.label,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  address.address,
                  style: AppTextStyles.body(color: c.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (contact.isNotEmpty) ...<Widget>[
                  SizedBox(height: 2.h),
                  Text(
                    contact,
                    style: AppTextStyles.caption(color: c.textHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 44.r,
            height: 44.r,
            child: isDeleting
                ? Center(
                    child: SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: Strings.delete,
                    onPressed: () => _confirmDelete(context),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 22.r,
                      color: c.error,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
