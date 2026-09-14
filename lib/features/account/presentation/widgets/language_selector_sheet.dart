import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/enum_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/modal_bottom_sheet_scaffold.dart';

/// Bottom sheet listing the app's supported languages — opened from the
/// Account tab's "Language" settings row. Picking one updates [LocaleCubit],
/// which flips `MaterialApp.router`'s `locale`; Flutter mirrors
/// `Directionality` for the whole app on its own from there, so nothing here
/// manually flips layout.
class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final Locale current = Localizations.localeOf(context);
    return ModalBottomSheetScaffold(
      title: Strings.language,
      child: Column(
        children: <Widget>[
          for (final LanguageCode code
              in LanguageCode.values) ...<Widget>[
            _LanguageOption(
              code: code,
              selected: current.languageCode == code.name,
            ),
            if (code != LanguageCode.values.last)
              SizedBox(height: 4.h),
          ],
          SizedBox(height: AppSpacing.sm.h),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final LanguageCode code;
  final bool selected;

  const _LanguageOption({
    required this.code,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<LocaleCubit>().changeLocale(code);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? c.primaryLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppRadius.md.r,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                code.displayName,
                style: AppTextStyles.titleSmall(
                  color: selected
                      ? c.primary
                      : c.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: c.primary,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }
}
