import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/saudi_phone.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'account_profile_card.dart';

/// The hero card bound to [ProfileCubit]: a card-shaped placeholder while
/// loading, an inline retry on failure, the real profile once loaded.
class AccountProfileSection extends StatelessWidget {
  const AccountProfileSection({super.key});

  /// Matches the loaded card's height so the list below doesn't jump.
  static const double _placeholderHeight = 150;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (ProfileState previous, ProfileState current) =>
          current is! ProfileLoaded ||
          previous is! ProfileLoaded ||
          previous.profile != current.profile,
      builder: (BuildContext context, ProfileState state) => switch (state) {
        ProfileLoaded(:final profile) => AccountProfileCard(
          name: profile.name,
          avatarLetter: profile.initial,
          phone: SaudiPhone.toLocal(profile.phone),
          memberSinceYear: profile.memberSinceYear,
          // Hand over this tab's cubit so a save updates this card.
          onEdit: () => context.push(
            AppRoutes.editProfile,
            extra: context.read<ProfileCubit>(),
          ),
        ),
        ProfileError(:final failure) => _ProfileErrorCard(failure: failure),
        ProfileInitial() || ProfileLoading() => const _ProfilePlaceholder(),
      },
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AccountProfileSection._placeholderHeight.h,
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl.r),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 24.r,
        height: 24.r,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ProfileErrorCard extends StatelessWidget {
  final Failure failure;

  const _ProfileErrorCard({required this.failure});

  String get _message => switch (failure) {
    NetworkFailure(:final String? message) =>
      message ?? Strings.noInternetConnection,
    _ => failure.message ?? Strings.somethingWentWrong,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      constraints: BoxConstraints(
        minHeight: AccountProfileSection._placeholderHeight.h,
      ),
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: Colors.white),
          ),
          SizedBox(height: AppSpacing.sm.h),
          TextButton(
            onPressed: () => context.read<ProfileCubit>().load(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: c.textPrimary,
              shape: const StadiumBorder(),
            ),
            child: Text(Strings.retry),
          ),
        ],
      ),
    );
  }
}
