import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/// Greeting + question on the start side; the notifications bell and the
/// avatar on the end side. The order
/// is deliberate: [Row] lays children start-to-end, and under the app's RTL
/// Arabic layout "start" is the right edge — so text-first/avatar-last is
/// what puts the avatar on the physical left without hardcoding a side.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BlocSelector<HomeCubit, HomeState, String?>(
                selector: (HomeState state) =>
                    state is HomeLoaded ? state.customerName : null,
                builder: (BuildContext context, String? name) => Text(
                  name == null
                      ? Strings.homeGreetingGeneric
                      : Strings.homeGreeting(name),
                  style: AppTextStyles.body(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              Text(
                Strings.homeQuestion,
                style: AppTextStyles.h1(color: c.textPrimary),
              ),
              if (kDebugMode) const _ZoneDebugLabel(),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        const NotificationBellButton(),
        SizedBox(width: AppSpacing.xs.w),
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          child: const Icon(Icons.person_outline, color: Colors.white),
        ),
      ],
    );
  }
}

/// Debug builds only: the zone the catalog below was loaded for, so a
/// wrong `zoneId` header is visible at a glance. Not localized on purpose.
class _ZoneDebugLabel extends StatelessWidget {
  const _ZoneDebugLabel();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<HomeCubit, HomeState, List<int>>(
        selector: (HomeState state) =>
            state is HomeLoaded ? state.zoneIds : const <int>[],
        builder: (BuildContext context, List<int> zoneIds) => zoneIds.isEmpty
            ? const SizedBox.shrink()
            : Text(
                'Zone: ${zoneIds.join(', ')}',
                style: AppTextStyles.caption(color: context.colors.textHint),
              ),
      );
}
