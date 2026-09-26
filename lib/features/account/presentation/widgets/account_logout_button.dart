import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/widgets/auth_state_listener.dart';

/// "Log out" card. Signing out is local-only (the customer API has no logout
/// endpoint); [AuthStateListener] then sends the user to Login with the
/// navigation stack cleared. Only this widget rebuilds while it runs.
class AccountLogoutButton extends StatelessWidget {
  const AccountLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AuthStateListener(
      child: BlocSelector<AuthCubit, AuthState, bool>(
        selector: (AuthState state) => state is AuthLoading,
        builder: (BuildContext context, bool isLoading) => GestureDetector(
          onTap: isLoading ? null : () => context.read<AuthCubit>().logout(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
            decoration: AppDecorations.card(c),
            child: Center(
              child: Text(
                Strings.accountLogoutButton,
                style: AppTextStyles.title(
                  color: isLoading ? c.textHint : c.error,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
