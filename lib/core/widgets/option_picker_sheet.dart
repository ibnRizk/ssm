import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'modal_bottom_sheet_scaffold.dart';

/// One choice in a [OptionPickerSheet].
class PickerOption {
  final int id;
  final String title;
  final String? subtitle;

  const PickerOption({required this.id, required this.title, this.subtitle});
}

/// A list of [options], the current one checked. Pops the picked id.
class OptionPickerSheet extends StatelessWidget {
  final String title;
  final List<PickerOption> options;
  final int? selectedId;

  /// Shown instead of the list when there's nothing to pick.
  final String emptyText;

  const OptionPickerSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.emptyText,
  });

  static Future<int?> show(
    BuildContext context, {
    required String title,
    required List<PickerOption> options,
    required int? selectedId,
    required String emptyText,
  }) => showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => OptionPickerSheet(
      title: title,
      options: options,
      selectedId: selectedId,
      emptyText: emptyText,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ModalBottomSheetScaffold(
      title: title,
      child: options.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: c.textSecondary),
              ),
            )
          : ConstrainedBox(
              // Long lists scroll instead of pushing the sheet off-screen.
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: AppSpacing.md.h),
                itemCount: options.length,
                separatorBuilder: (_, _) => SizedBox(height: 4.h),
                itemBuilder: (BuildContext context, int index) => _OptionTile(
                  option: options[index],
                  selected: options[index].id == selectedId,
                ),
              ),
            ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final PickerOption option;
  final bool selected;

  const _OptionTile({required this.option, required this.selected});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? subtitle = option.subtitle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context, option.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: selected ? c.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md.r),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    option.title,
                    style: AppTextStyles.titleSmall(color: c.textPrimary),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTextStyles.caption(color: c.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: c.primary, size: 20.r),
          ],
        ),
      ),
    );
  }
}
