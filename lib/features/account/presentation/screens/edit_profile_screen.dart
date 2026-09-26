import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/error_text.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/edit_profile_form.dart';

/// Pushed from the Account tab's profile card, outside the bottom-nav shell.
///
/// Expects the Account tab's [ProfileCubit] (handed over through the
/// route's `extra`, so a save updates the card behind this screen) and an
/// `EditProfileCubit` above it — both provided at the route.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: SimpleAppBar(
        title: Strings.editProfileTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          // Only switch between loading/error/form — a save re-emits
          // ProfileLoaded, and rebuilding then would reset the form mid-pop.
          buildWhen: (ProfileState previous, ProfileState current) =>
              previous.runtimeType != current.runtimeType,
          builder: (BuildContext context, ProfileState state) =>
              switch (state) {
                ProfileLoaded(:final profile) => EditProfileForm(
                  initial: profile,
                ),
                ProfileError(:final failure) => ErrorText(
                  message: failure.userMessage,
                  onRetry: () => context.read<ProfileCubit>().load(),
                ),
                ProfileInitial() || ProfileLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              },
        ),
      ),
    );
  }
}
