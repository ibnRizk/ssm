import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../utils/auth_failure_message.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/forgot_password_code_step.dart';
import '../widgets/forgot_password_new_password_step.dart';
import '../widgets/forgot_password_phone_step.dart';

/// Phone → code → new password, one route. Back (button or system) steps
/// back through the flow before leaving it.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  static void goBack(BuildContext context) {
    if (context.read<ForgotPasswordCubit>().back()) return;
    // Pushed from Login normally; reached any other way, there's nothing to
    // pop to.
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.loginName);
    }
  }

  void _onStateChanged(BuildContext context, ForgotPasswordState state) {
    if (state case ForgotPasswordState(:final Failure failure)) {
      showAppSnackBar(
        context: context,
        message: failure.passwordResetMessage,
        type: ToastType.error,
      );
    } else if (state is ForgotPasswordDone) {
      showAppSnackBar(
        context: context,
        message: Strings.forgotPasswordSuccess,
        type: ToastType.success,
      );
      context.goNamed(AppRoutes.loginName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) goBack(context);
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
            listenWhen: (_, ForgotPasswordState current) =>
                current.failure != null || current is ForgotPasswordDone,
            listener: _onStateChanged,
          ),
          BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
            listenWhen:
                (ForgotPasswordState previous, ForgotPasswordState current) =>
                    previous is ForgotPasswordEnterCode &&
                    current is ForgotPasswordEnterCode &&
                    current.resends > previous.resends,
            listener: (BuildContext context, _) => showAppSnackBar(
              context: context,
              message: Strings.forgotPasswordCodeResent,
              type: ToastType.success,
            ),
          ),
        ],
        child: AuthScaffold(
          // Rebuilds only when the step changes; each step watches its own
          // submit state.
          child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            buildWhen:
                (ForgotPasswordState previous, ForgotPasswordState current) =>
                    previous.runtimeType != current.runtimeType,
            builder: (_, ForgotPasswordState state) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (state) {
                ForgotPasswordEnterPhone(:final String phone) =>
                  ForgotPasswordPhoneStep(initialPhone: phone),
                ForgotPasswordEnterCode(:final String phone) =>
                  ForgotPasswordCodeStep(phone: phone),
                // Done shows the last step while Login takes over.
                ForgotPasswordEnterNewPassword() ||
                ForgotPasswordDone() => const ForgotPasswordNewPasswordStep(),
              },
            ),
          ),
        ),
      ),
    );
  }
}
