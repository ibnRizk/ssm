import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../utils/auth_failure_message.dart';

/// One-shot side effects shared by Login and Register: enter the app once
/// the session is stored, or surface the failure in a snack bar. Never
/// rebuilds [child].
class AuthStateListener extends StatelessWidget {
  final Widget child;

  const AuthStateListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        switch (state) {
          case AuthSuccess():
            context.goNamed(AppRoutes.homeName);
          case AuthError(:final failure):
            showAppSnackBar(
              context: context,
              message: failure.authMessage,
              type: ToastType.error,
            );
          case AuthInitial() || AuthLoading():
            break;
        }
      },
      child: child,
    );
  }
}
