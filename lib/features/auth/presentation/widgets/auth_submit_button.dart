import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// The orange CTA; spins and disables itself while a request is in flight.
/// Only this widget rebuilds on auth state changes.
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, bool>(
      selector: (AuthState state) => state is AuthLoading,
      builder: (BuildContext context, bool isLoading) =>
          AppButton(btnText: label, isLoading: isLoading, onPressed: onPressed),
    );
  }
}
