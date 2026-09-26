import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extension.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../domain/entities/prescription_image.dart';

/// The dashed-outline "attach the prescription photo" prompt; once a photo
/// is attached, its thumbnail and name with a remove button.
class PharmacyAttachmentBox extends StatelessWidget {
  final PrescriptionImage? image;

  /// The camera or gallery is open.
  final bool picking;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  const PharmacyAttachmentBox({
    super.key,
    required this.image,
    required this.picking,
    this.onPick,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final PrescriptionImage? image = this.image;
    if (image != null) return _Attached(image: image, onRemove: onRemove);
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: picking ? null : onPick,
      child: DashedBorderBox(
        borderColor: c.secondary,
        backgroundColor: c.secondaryLight,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
        child: Center(
          child: picking
              ? SizedBox.square(
                  dimension: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.secondary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.attach_file, color: c.secondary, size: 18.r),
                    SizedBox(width: AppSpacing.xs.w),
                    Text(
                      Strings.pharmacyAttachmentLabel,
                      style: AppTextStyles.body(color: c.secondary),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Attached extends StatelessWidget {
  final PrescriptionImage image;
  final VoidCallback? onRemove;

  const _Attached({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final double side = 56.r;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm.r),
      decoration: AppDecorations.card(c),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            child: Image.file(
              File(image.path),
              width: side,
              height: side,
              fit: BoxFit.cover,
              cacheWidth: side.cacheSize(context),
              errorBuilder: (_, _, _) => SizedBox.square(
                dimension: side,
                child: Icon(Icons.image_outlined, color: c.textHint),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Text(
              image.fileName,
              style: AppTextStyles.body(color: c.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: Strings.pharmacyRemovePhoto,
            icon: Icon(Icons.close, color: c.error, size: 20.r),
          ),
        ],
      ),
    );
  }
}
