import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/values/strings.dart';
import 'app_button.dart';

/// What a guest picked on [LoginRequiredSheet]; null when dismissed.
enum LoginRequiredChoice { login, createAccount }

/// Shows [LoginRequiredSheet]. Prefer `ensureSignedIn` (core/session),
/// which also opens the chosen screen and reports whether it worked.
Future<LoginRequiredChoice?> showLoginRequiredSheet(BuildContext context) =>
    showModalBottomSheet<LoginRequiredChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // The sheet draws its own rounded surface.
      backgroundColor: Colors.transparent,
      builder: (_) => const LoginRequiredSheet(),
    );

/// "Login required" — shown when a guest opens an account-based feature
/// (profile, orders, parcels, checkout…). Pops a [LoginRequiredChoice], or
/// nothing for "Not now".
class LoginRequiredSheet extends StatelessWidget {
  const LoginRequiredSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl.r + 4.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            AppSpacing.sm.h,
            AppSpacing.xl.w,
            AppSpacing.lg.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DragHandle(),
              SizedBox(height: AppSpacing.xl.h),
              const Center(child: _LockBadge()),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                Strings.signInRequiredTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1(color: c.textPrimary),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                Strings.signInRequiredMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: c.textSecondary),
              ),
              SizedBox(height: AppSpacing.xxl.h),
              AppButton(
                btnText: Strings.authLoginButton,
                height: AppSizes.buttonHeight.h,
                borderRadius: AppRadius.lg.r,
                onPressed: () =>
                    Navigator.pop(context, LoginRequiredChoice.login),
              ),
              SizedBox(height: AppSpacing.sm.h),
              SizedBox(
                height: AppSizes.buttonHeight.h,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pop(context, LoginRequiredChoice.createAccount),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.primary,
                    side: BorderSide(color: c.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg.r),
                    ),
                  ),
                  child: Text(
                    Strings.signInRequiredCreateAccount,
                    style: AppTextStyles.button(color: c.primary),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: c.textSecondary),
                child: Text(Strings.notNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    ),
  );
}

/// The brand-orange lock in a soft halo, so the sheet reads at a glance.
class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: 96.r,
      height: 96.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.secondary.withValues(alpha: 0.12),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 68.r,
        height: 68.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[c.secondaryLight, c.secondary],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: c.secondary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.lock_person_rounded, color: Colors.white, size: 34.r),
      ),
    );
  }
}
