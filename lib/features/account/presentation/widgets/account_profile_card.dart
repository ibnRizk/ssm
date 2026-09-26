import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Dark navy hero card at the top of the Account tab: avatar, name, phone,
/// join date and an "edit" pill, over a layered orange wave accent.
class AccountProfileCard extends StatelessWidget {
  final String name;
  final String avatarLetter;
  final String phone;

  /// Hidden when null — the backend's `created_at` is optional.
  final int? memberSinceYear;
  final VoidCallback onEdit;

  const AccountProfileCard({
    super.key,
    required this.name,
    required this.avatarLetter,
    required this.phone,
    required this.memberSinceYear,
    required this.onEdit,
  });

  /// The pill is the card's only action, so it's sized well above a plain
  /// badge: larger text, roomier padding and a minimum height.
  static const double _editMinHeight = 36;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // Decorative wave accent — deliberately plain `Positioned`, not
          // `PositionedDirectional`: a brand flourish stays put regardless of
          // locale, unlike the real content below it.
          Positioned(
            bottom: -50.r,
            left: -30.r,
            child: Container(
              width: 170.r,
              height: 170.r,
              decoration: BoxDecoration(
                color: c.secondary.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -75.r,
            left: 45.r,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                color: c.secondaryDark.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: onEdit,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      constraints: BoxConstraints(minHeight: _editMinHeight.h),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md.w,
                        vertical: AppSpacing.xs.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        Strings.accountEditButton,
                        style: AppTextStyles.body(color: c.textPrimary),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                Row(
                  children: <Widget>[
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: c.secondaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md.r),
                      ),
                      child: Center(
                        child: Text(
                          avatarLetter,
                          style: AppTextStyles.h1(color: c.secondaryDark),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            style: AppTextStyles.h2(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            phone,
                            style: AppTextStyles.body(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          if (memberSinceYear case final int year) ...<Widget>[
                            SizedBox(height: 2.h),
                            Text(
                              Strings.accountMemberSince(year),
                              style: AppTextStyles.caption(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
