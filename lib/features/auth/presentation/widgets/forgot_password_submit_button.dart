import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_button.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

/// The orange CTA of a recovery step; spins while its request is in flight.
/// Only this widget rebuilds on submit state changes.
class ForgotPasswordSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ForgotPasswordSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState, bool>(
      selector: (ForgotPasswordState state) => state.isSubmitting,
      builder: (_, bool isSubmitting) => AppButton(
        btnText: label,
        isLoading: isSubmitting,
        onPressed: onPressed,
      ),
    );
  }
}
