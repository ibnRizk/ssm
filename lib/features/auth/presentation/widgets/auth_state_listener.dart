import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../utils/auth_failure_message.dart';

/// One-shot side effects shared by Login, Register and Logout: enter the app
/// once the session is stored, leave it once the session is discarded, or
/// surface the failure in a snack bar. Never rebuilds [child].
///
/// Expects the app-wide [SessionCubit] above it, which is refreshed before
/// navigating so the screens behind see the new session.
///
/// After sign-out: Home as a guest (through the splash, see [_onSignedOut]).
///
/// After sign-in:
/// - Login *pushed* by a guest's sign-in gate (`ensureSignedIn`) pops
///   `true`, returning the guest to what they were doing.
/// - Otherwise `go` (not `push`) replaces the whole route stack — the auth
///   screens are top-level routes outside the bottom-nav shell, so the
///   Android back button has nothing to return to.
class AuthStateListener extends StatelessWidget {
  final Widget child;

  const AuthStateListener({super.key, required this.child});

  Future<void> _onSignedIn(BuildContext context) async {
    await context.read<SessionCubit>().refresh();
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop(true);
    } else {
      context.goNamed(AppRoutes.homeName);
    }
  }

  /// Guest by default: back to Home as a guest, via the splash — leaving
  /// the bottom-nav shell disposes the signed-out customer's tabs and their
  /// notification hub, so nothing of theirs lingers for the next session.
  Future<void> _onSignedOut(BuildContext context) async {
    await context.read<SessionCubit>().refresh();
    if (context.mounted) context.goNamed(AppRoutes.splashName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        switch (state) {
          case AuthSuccess():
            _onSignedIn(context);
          case AuthUnauthenticated():
            _onSignedOut(context);
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
