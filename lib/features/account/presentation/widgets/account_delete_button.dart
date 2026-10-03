import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/repos/account_repository.dart';
import '../cubit/delete_account_cubit.dart';
import '../cubit/delete_account_state.dart';
import 'delete_account_dialog.dart';

/// Store-required "Delete account" action, deliberately quieter than Log
/// out. Confirms first, then leaves for Login with the stack cleared once
/// the account is gone. Only this widget rebuilds while it runs.
class AccountDeleteButton extends StatelessWidget {
  const AccountDeleteButton({super.key});

  Future<void> _onTap(BuildContext context) async {
    final DeleteAccountCubit cubit = context.read<DeleteAccountCubit>();
    if (await confirmDeleteAccount(context)) cubit.deleteAccount();
  }

  void _onStateChanged(BuildContext context, DeleteAccountState state) {
    switch (state) {
      case DeleteAccountDone():
        showAppSnackBar(
          context: context,
          message: Strings.accountDeleted,
          type: ToastType.success,
        );
        context.goNamed(AppRoutes.loginName);
      case DeleteAccountError(:final Failure failure):
        final bool ongoingOrder =
            failure is ForbiddenFailure &&
            failure.code == AccountRefusalCode.ongoingOrder;
        showAppSnackBar(
          context: context,
          message: ongoingOrder
              ? Strings.accountDeleteOngoingOrder
              : failure.message ?? Strings.somethingWentWrong,
          type: ongoingOrder ? ToastType.warning : ToastType.error,
        );
      case DeleteAccountIdle() || DeleteAccountInProgress():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: _onStateChanged,
      builder: (BuildContext context, DeleteAccountState state) {
        final bool inProgress = state is DeleteAccountInProgress;
        return Center(
          child: TextButton(
            onPressed: inProgress ? null : () => _onTap(context),
            style: TextButton.styleFrom(foregroundColor: c.error),
            child: inProgress
                ? SizedBox.square(
                    dimension: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: c.error,
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs.h),
                    child: Text(
                      Strings.accountDeleteButton,
                      style: AppTextStyles.body(color: c.error),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
